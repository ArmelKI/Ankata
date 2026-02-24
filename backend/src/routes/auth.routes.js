const express = require('express');
const AuthController = require('../controllers/auth.controller');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Public endpoints
router.post('/request-otp', AuthController.requestOTP);
router.post('/verify-otp', AuthController.verifyOTP);

// Protected endpoints
router.get('/me', authMiddleware, AuthController.getCurrentUser);
router.put('/profile', authMiddleware, AuthController.updateProfile);

module.exports = router;
