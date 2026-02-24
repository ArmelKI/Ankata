const express = require('express');
const PaymentController = require('../controllers/payments.controller');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Initiate payment
router.post('/', authMiddleware, PaymentController.initiatePayment);

// Verify payment (webhook endpoint - might need different auth)
router.post('/:paymentId/verify', PaymentController.verifyPayment);
router.post('/:paymentId/status', PaymentController.verifyPayment);

// Get payment details
router.get('/:paymentId', authMiddleware, PaymentController.getPaymentDetails);
router.get('/:paymentId/status', authMiddleware, PaymentController.getPaymentDetails);

module.exports = router;
