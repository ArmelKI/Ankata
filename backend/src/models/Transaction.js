const pool = require('../database/connection');

class TransactionModel {
  static async create(data) {
    const { userId, amount, type, status, description } = data;
    const query = `
      INSERT INTO transactions (user_id, amount, type, status, description)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const result = await pool.query(query, [userId, amount, type, status || 'completed', description]);
    return result.rows[0];
  }

  static async findByUserId(userId, limit = 50, offset = 0) {
    const query = `
      SELECT * FROM transactions
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3;
    `;
    const result = await pool.query(query, [userId, limit, offset]);
    return result.rows;
  }
}

module.exports = TransactionModel;
