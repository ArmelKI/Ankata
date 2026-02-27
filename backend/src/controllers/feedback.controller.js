const Feedback = require('../models/Feedback');

class FeedbackController {
  static async submit(req, res) {
    const { type, subject, message, deviceInfo } = req.body;
    const userId = req.user.id;

    if (!type || !message) {
      return res.status(400).json({ error: 'Type and message are required' });
    }

    const feedback = await Feedback.create({
      userId,
      type,
      subject,
      message,
      deviceInfo
    });

    res.status(201).json({
      message: 'Feedback submitted successfully',
      feedback
    });
  }

  static async getMyFeedback(req, res) {
    const userId = req.user.id;
    const feedbacks = await Feedback.getByUserId(userId);
    res.json({ feedbacks });
  }
}

module.exports = FeedbackController;
