const pool = require('../config/db');

class Feedback {
  static async create({ userId, type, subject, message, deviceInfo }) {
    const result = await pool.query(
      `INSERT INTO feedback (user_id, type, subject, message, device_info)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userId, type, subject, message, deviceInfo]
    );
    return result.rows[0];
  }

  static async getByUserId(userId) {
    const result = await pool.query(
      'SELECT * FROM feedback WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );
    return result.rows;
  }
}

module.exports = Feedback;
