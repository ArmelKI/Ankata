const express = require('express');
const router = express.Router();
const FeedbackController = require('../controllers/feedback.controller');
const auth = require('../middleware/auth');

router.post('/', auth, FeedbackController.submit);
router.get('/my', auth, FeedbackController.getMyFeedback);

module.exports = router;
