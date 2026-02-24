const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const pool = require('../database/connection');

const router = express.Router();

// Get user notifications
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { limit = 20, offset = 0 } = req.query;
    
    const parsedLimit = Math.min(parseInt(limit, 10) || 20, 100);
    const parsedOffset = parseInt(offset, 10) || 0;

    const query = `
      SELECT * FROM notifications
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3;
    `;
    const result = await pool.query(query, [userId, parsedLimit, parsedOffset]);

    res.status(200).json({
      notifications: result.rows,
      count: result.rows.length,
    });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({
      error: 'Failed to fetch notifications',
      details: error.message,
    });
  }
});

// Mark notification as read
router.patch('/:id/read', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const query = `
      UPDATE notifications
      SET is_read = true, read_at = CURRENT_TIMESTAMP
      WHERE id = $1 AND user_id = $2
      RETURNING *;
    `;
    const result = await pool.query(query, [id, userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    res.status(200).json({
      notification: result.rows[0],
    });
  } catch (error) {
    console.error('Mark notification read error:', error);
    res.status(500).json({
      error: 'Failed to update notification',
      details: error.message,
    });
  }
});

module.exports = router;
