const UserModel = require('../models/User');
const OtpModel = require('../models/Otp');
const { generateOTP, generateToken, formatPhoneNumber } = require('../utils/helpers');
const twilio = require('twilio');

const twilioAccountSid = process.env.TWILIO_ACCOUNT_SID;
const twilioAuthToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;
const hasTwilioConfig = Boolean(
  twilioAccountSid &&
  twilioAccountSid.startsWith('AC') &&
  twilioAuthToken &&
  twilioPhoneNumber
);
const client = hasTwilioConfig ? twilio(twilioAccountSid, twilioAuthToken) : null;

class AuthController {
  // Request OTP via WhatsApp
  static async requestOTP(req, res) {
    try {
      const { phoneNumber } = req.body;

      if (!phoneNumber) {
        return res.status(400).json({ error: 'Phone number is required' });
      }

      const formattedPhone = formatPhoneNumber(phoneNumber);
      const otp = generateOTP(6);
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

      // Save OTP to database
      await OtpModel.create(formattedPhone, otp, expiresAt);

      // Send OTP via WhatsApp using Twilio when configured
      if (client) {
        try {
          await client.messages.create({
            from: `whatsapp:${twilioPhoneNumber}`,
            to: `whatsapp:${formattedPhone}`,
            body: `Your Ankata verification code is: ${otp}. Valid for 10 minutes.`,
          });
        } catch (smsError) {
          console.error('WhatsApp message error:', smsError);
          // In development, we might want to still proceed
          if (process.env.NODE_ENV === 'production') {
            throw smsError;
          }
        }
      } else if (process.env.NODE_ENV === 'production') {
        return res.status(500).json({
          error: 'OTP service is not configured',
        });
      }

      res.status(200).json({
        message: 'OTP sent successfully',
        phoneNumber: formattedPhone,
        expiresIn: 600, // 10 minutes in seconds
      });
    } catch (error) {
      console.error('Request OTP error:', error);
      res.status(500).json({
        error: 'Failed to send OTP',
        details: error.message,
      });
    }
  }

  // Verify OTP
  static async verifyOTP(req, res) {
    try {
      const { phoneNumber, otp } = req.body;

      if (!phoneNumber || !otp) {
        return res.status(400).json({
          error: 'Phone number and OTP are required',
        });
      }

      const formattedPhone = formatPhoneNumber(phoneNumber);

      // 🔧 DEV MODE: Accept test OTP 123456
      if (process.env.NODE_ENV === 'development' && otp === '123456') {
        let user = await UserModel.findByPhone(formattedPhone);
        if (!user) {
          user = await UserModel.create(formattedPhone);
        }
        await UserModel.update(user.id, { is_verified: true });
        const token = generateToken(user.id, formattedPhone);
        await UserModel.updateLastLogin(user.id);

        return res.status(200).json({
          message: 'OTP verified successfully (DEV MODE)',
          token,
          user: {
            id: user.id,
            phoneNumber: user.phone_number,
            fullName: user.full_name,
            email: user.email,
            isVerified: true,
          },
          expiresIn: 604800,
        });
      }

      // Verify OTP
      const otpRecord = await OtpModel.findLatestByPhone(formattedPhone);

      if (!otpRecord) {
        return res.status(400).json({
          error: 'No OTP found for this phone number',
        });
      }

      if (otpRecord.is_verified) {
        return res.status(400).json({
          error: 'OTP already verified',
        });
      }

      if (new Date() > new Date(otpRecord.expires_at)) {
        return res.status(400).json({
          error: 'OTP has expired',
        });
      }

      if (otpRecord.otp_code !== otp) {
        // Increment attempts
        await OtpModel.updateAttempts(otpRecord.id);
        
        if (otpRecord.attempts >= otpRecord.max_attempts - 1) {
          return res.status(400).json({
            error: 'Maximum OTP attempts exceeded. Request a new OTP.',
          });
        }

        return res.status(400).json({
          error: 'Invalid OTP',
          attemptsRemaining: otpRecord.max_attempts - otpRecord.attempts - 1,
        });
      }

      // Mark OTP as verified
      await OtpModel.markVerified(otpRecord.id);

      // Find or create user
      let user = await UserModel.findByPhone(formattedPhone);
      if (!user) {
        user = await UserModel.create(formattedPhone);
      }

      // Update user verification status
      await UserModel.update(user.id, { is_verified: true });

      // Generate JWT token
      const token = generateToken(user.id, formattedPhone);

      // Update last login
      await UserModel.updateLastLogin(user.id);

      res.status(200).json({
        message: 'OTP verified successfully',
        token,
        user: {
          id: user.id,
          phoneNumber: user.phone_number,
          fullName: user.full_name,
          email: user.email,
          isVerified: true,
        },
        expiresIn: 604800, // 7 days in seconds
      });
    } catch (error) {
      console.error('Verify OTP error:', error);
      res.status(500).json({
        error: 'Failed to verify OTP',
        details: error.message,
      });
    }
  }

  // Get current user profile
  static async getCurrentUser(req, res) {
    try {
      const userId = req.user.userId;
      const user = await UserModel.findById(userId);

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.status(200).json({
        user: {
          id: user.id,
          phoneNumber: user.phone_number,
          fullName: user.full_name,
          email: user.email,
          profilePictureUrl: user.profile_picture_url,
          isVerified: user.is_verified,
          createdAt: user.created_at,
          lastLogin: user.last_login,
        },
      });
    } catch (error) {
      console.error('Get current user error:', error);
      res.status(500).json({
        error: 'Failed to fetch user',
        details: error.message,
      });
    }
  }

  // Update user profile
  static async updateProfile(req, res) {
    try {
      const userId = req.user.userId;
      const { fullName, email, profilePictureUrl } = req.body;

      const updatedUser = await UserModel.update(userId, {
        full_name: fullName,
        email,
        profile_picture_url: profilePictureUrl,
      });

      if (!updatedUser) {
        return res.status(400).json({ error: 'Failed to update profile' });
      }

      res.status(200).json({
        message: 'Profile updated successfully',
        user: {
          id: updatedUser.id,
          phoneNumber: updatedUser.phone_number,
          fullName: updatedUser.full_name,
          email: updatedUser.email,
          profilePictureUrl: updatedUser.profile_picture_url,
        },
      });
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({
        error: 'Failed to update profile',
        details: error.message,
      });
    }
  }
}

module.exports = AuthController;
