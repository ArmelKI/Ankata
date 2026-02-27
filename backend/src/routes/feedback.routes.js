const express = require('express');
const router = express.Router();
const FeedbackController = require('../controllers/feedback.controller');
const { verifyToken } = require('../middleware/auth.middleware');

router.post('/', verifyToken, FeedbackController.submit);
router.get('/my', verifyToken, FeedbackController.getMyFeedback);

module.exports = router;
