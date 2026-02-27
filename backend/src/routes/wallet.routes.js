const express = require('express');
const router = express.Router();
const WalletController = require('../controllers/wallet.controller');
const { verifyToken } = require('../middleware/auth.middleware');

router.get('/transactions', verifyToken, WalletController.getTransactions);

module.exports = router;
