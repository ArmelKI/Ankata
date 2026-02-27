const express = require('express');
const UsersController = require('../controllers/users.controller');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.put('/:id', authMiddleware, UsersController.updateUser);
router.get('/referral/stats', authMiddleware, UsersController.getReferralStats);

module.exports = router;
