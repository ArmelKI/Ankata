const express = require('express');
const AuthController = require('../controllers/auth.controller');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Public endpoints
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/google', AuthController.googleAuth);
router.get('/security-questions/:phoneNumber', AuthController.getSecurityQuestions);
router.post('/reset-password', AuthController.resetPassword);

// Protected endpoints
router.get('/me', authMiddleware, AuthController.getCurrentUser);
router.put('/profile', authMiddleware, AuthController.updateProfile);

module.exports = router;
