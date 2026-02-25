const UserModel = require('../models/User');
const { generateToken, formatPhoneNumber } = require('../utils/helpers');
const bcrypt = require('bcryptjs');
const admin = require('../config/firebase');

class AuthController {
  // Register with Password
  static async register(req, res) {
    try {
      const { phoneNumber, firstName, lastName, password, securityQ1, securityA1, securityQ2, securityA2 } = req.body;

      if (!phoneNumber || !firstName || !lastName || !password || !securityQ1 || !securityA1 || !securityQ2 || !securityA2) {
        return res.status(400).json({ error: 'All fields are required.' });
      }

      const formattedPhone = formatPhoneNumber(phoneNumber);
      
      const existingUser = await UserModel.findByPhone(formattedPhone);
      if (existingUser) {
        return res.status(400).json({ error: 'Phone number already registered.' });
      }

      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(password, salt);
      const secA1Hash = await bcrypt.hash(securityA1.toLowerCase().trim(), salt);
      const secA2Hash = await bcrypt.hash(securityA2.toLowerCase().trim(), salt);

      const user = await UserModel.create({
        phoneNumber: formattedPhone,
        firstName,
        lastName,
        passwordHash,
        securityQ1,
        securityA1: secA1Hash,
        securityQ2,
        securityA2: secA2Hash,
        isVerified: true,
      });

      const token = generateToken(user.id, formattedPhone);
      await UserModel.updateLastLogin(user.id);

      res.status(201).json({
        message: 'Registered successfully',
        token,
        user: { ...user, isVerified: true },
        expiresIn: 604800,
      });
    } catch (error) {
      console.error('Register error:', error);
      res.status(500).json({ error: 'Registration failed', details: error.message });
    }
  }

  // Login with Password
  static async login(req, res) {
    try {
      const { phoneNumber, password } = req.body;

      if (!phoneNumber || !password) {
        return res.status(400).json({ error: 'Phone number and password are required.' });
      }

      const formattedPhone = formatPhoneNumber(phoneNumber);
      const user = await UserModel.findByPhone(formattedPhone);

      if (!user) {
        return res.status(400).json({ error: 'Invalid credentials.' });
      }

      if (!user.password_hash) {
        return res.status(400).json({ error: 'This account was created with Google. Please use Google Login.' });
      }

      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) {
        return res.status(400).json({ error: 'Invalid credentials.' });
      }

      const token = generateToken(user.id, formattedPhone);
      await UserModel.updateLastLogin(user.id);

      res.status(200).json({
        message: 'Login successful',
        token,
        user: {
          id: user.id,
          phoneNumber: user.phone_number,
          firstName: user.first_name,
          lastName: user.last_name,
          dateOfBirth: user.date_of_birth,
          cnib: user.cnib,
          gender: user.gender,
          email: user.email,
          profilePictureUrl: user.profile_picture_url,
          isVerified: user.is_verified,
        },
        expiresIn: 604800,
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ error: 'Login failed', details: error.message });
    }
  }

  // Google Auth Login/Register
  static async googleAuth(req, res) {
    try {
      const { idToken, phoneNumber } = req.body; // Phone number optional depending on what info user gave Firebase

      if (!idToken) {
        return res.status(400).json({ error: 'Google ID token is required.' });
      }

      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const { uid, email, name, picture } = decodedToken;

      let user = await UserModel.findByGoogleId(uid);
      let [firstName, ...lastNames] = (name || '').split(' ');
      const lastName = lastNames.join(' ');

      // Also check if email exists if not found by GoogleId?
      // In this case we mostly rely on GoogleId.
      
      let formattedPhone = null;
      if (phoneNumber) {
        formattedPhone = formatPhoneNumber(phoneNumber);
        // If user not found by googleId, check by phone? We can link them if needed.
        if (!user) {
          user = await UserModel.findByPhone(formattedPhone);
        }
      }

      if (!user) {
        // Create new user via Google
        user = await UserModel.create({
          phoneNumber: formattedPhone || null, // Might be null for Google users initially
          firstName: firstName || 'GoogleUser',
          lastName: lastName || '',
          passwordHash: null,
          securityQ1: null,
          securityA1: null,
          securityQ2: null,
          securityA2: null,
          googleId: uid,
          email: email || null,
        });

        if (picture) {
           await UserModel.update(user.id, { profile_picture_url: picture, is_verified: true });
           user.profile_picture_url = picture;
        }
      } else if (!user.google_id) {
        // Link Google ID if user already exists
        await UserModel.update(user.id, { googleId: uid, is_verified: true });
      }

      const token = generateToken(user.id, formattedPhone);
      await UserModel.updateLastLogin(user.id);

      res.status(200).json({
        message: 'Google login successful',
        token,
        user: {
          id: user.id || user.id,
          phoneNumber: user.phone_number || formattedPhone,
          firstName: user.first_name || firstName,
          lastName: user.last_name || lastName,
          dateOfBirth: user.date_of_birth,
          cnib: user.cnib,
          gender: user.gender,
          email: user.email || email,
          profilePictureUrl: user.profile_picture_url || picture,
          isVerified: true,
        },
        expiresIn: 604800,
      });

    } catch (error) {
      console.error('Google Auth error:', error);
      res.status(500).json({ error: 'Google login failed', details: error.message });
    }
  }

  // Get Security Questions for Forgot Password
  static async getSecurityQuestions(req, res) {
    try {
      const { phoneNumber } = req.params;
      const formattedPhone = formatPhoneNumber(phoneNumber);

      const user = await UserModel.findByPhone(formattedPhone);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      if (!user.security_q1 || !user.security_q2) {
        return res.status(400).json({ error: 'No security questions set for this user. If registered via Google, use Google Login.' });
      }

      res.status(200).json({
        securityQ1: user.security_q1,
        securityQ2: user.security_q2,
      });
    } catch (error) {
      console.error('Get security questions error:', error);
      res.status(500).json({ error: 'Failed to fetch questions', details: error.message });
    }
  }

  // Reset Password
  static async resetPassword(req, res) {
    try {
      const { phoneNumber, securityA1, securityA2, newPassword } = req.body;

      if (!phoneNumber || !securityA1 || !securityA2 || !newPassword) {
        return res.status(400).json({ error: 'All fields are required.' });
      }

      const formattedPhone = formatPhoneNumber(phoneNumber);
      const user = await UserModel.findByPhone(formattedPhone);

      if (!user) {
        return res.status(404).json({ error: 'User not found.' });
      }

      const isA1Match = await bcrypt.compare(securityA1.toLowerCase().trim(), user.security_a1);
      const isA2Match = await bcrypt.compare(securityA2.toLowerCase().trim(), user.security_a2);

      if (!isA1Match || !isA2Match) {
         return res.status(400).json({ error: 'Incorrect answers to security questions.' });
      }

      const salt = await bcrypt.genSalt(10);
      const newPasswordHash = await bcrypt.hash(newPassword, salt);

      await UserModel.updatePassword(user.id, newPasswordHash);

      res.status(200).json({ message: 'Password reset successful. You can now login with your new password.' });
    } catch (error) {
      console.error('Reset password error:', error);
      res.status(500).json({ error: 'Password reset failed', details: error.message });
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
          firstName: user.first_name,
          lastName: user.last_name,
          dateOfBirth: user.date_of_birth,
          cnib: user.cnib,
          gender: user.gender,
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
      const { firstName, lastName, dateOfBirth, cnib, gender, email, profilePictureUrl } = req.body;

      const updatedUser = await UserModel.update(userId, {
        first_name: firstName,
        last_name: lastName,
        date_of_birth: dateOfBirth,
        cnib,
        gender,
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
          firstName: updatedUser.first_name,
          lastName: updatedUser.last_name,
          dateOfBirth: updatedUser.date_of_birth,
          cnib: updatedUser.cnib,
          gender: updatedUser.gender,
          email: updatedUser.email,
          profilePictureUrl: updatedUser.profile_picture_url,
          isVerified: updatedUser.is_verified,
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
