const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const generateToken = (userId, phoneNumber, expiresIn = process.env.JWT_EXPIRATION || '7d') => {
  return jwt.sign(
    {
      userId,
      phoneNumber,
      iat: Math.floor(Date.now() / 1000),
    },
    process.env.JWT_SECRET,
    { expiresIn }
  );
};

const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw new Error(`Token verification failed: ${error.message}`);
  }
};

const generateOTP = (length = 6) => {
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += digits[Math.floor(Math.random() * 10)];
  }
  return otp;
};

const generateBookingCode = () => {
  return Math.floor(10000000 + Math.random() * 90000000).toString();
};

const generateReferralCode = () => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sans O, 0, I, 1 pour eviter confusion
  let code = '';
  for (let i = 0; i < 8; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
};

const generateUniqueId = () => {
  return crypto.randomUUID();
};

const hashPassword = (password) => {
  return require('bcryptjs').hashSync(password, 10);
};

const comparePassword = (password, hash) => {
  return require('bcryptjs').compareSync(password, hash);
};

const formatPhoneNumber = (phone) => {
  // Remove spaces and dashes
  let cleaned = phone.replace(/[\s-]/g, '');
  
  // Add +226 for Burkina Faso if not present
  if (!cleaned.startsWith('+')) {
    cleaned = '+226' + cleaned;
  }
  
  return cleaned;
};

const calculateAge = (dateOfBirth) => {
  const today = new Date();
  let age = today.getFullYear() - dateOfBirth.getFullYear();
  const monthDiff = today.getMonth() - dateOfBirth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dateOfBirth.getDate())) {
    age--;
  }
  return age;
};

const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

module.exports = {
  generateToken,
  verifyToken,
  generateOTP,
  generateBookingCode,
  generateReferralCode,
  generateUniqueId,
  hashPassword,
  comparePassword,
  formatPhoneNumber,
  calculateAge,
  calculateDistance,
};
