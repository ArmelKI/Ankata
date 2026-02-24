const pool = require('../database/connection');

class UserModel {
  static async findByPhone(phoneNumber) {
    const query = 'SELECT * FROM users WHERE phone_number = $1';
    const result = await pool.query(query, [phoneNumber]);
    return result.rows[0] || null;
  }

  static async findById(id) {
    const query = 'SELECT * FROM users WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async create(phoneNumber, fullName = null, email = null) {
    const query = `
      INSERT INTO users (phone_number, full_name, email, is_verified)
      VALUES ($1, $2, $3, false)
      RETURNING *;
    `;
    const result = await pool.query(query, [phoneNumber, fullName, email]);
    return result.rows[0];
  }

  static async update(id, data) {
    const allowedFields = ['full_name', 'email', 'profile_picture_url', 'is_verified'];
    const updateFields = [];
    const values = [];
    let paramIndex = 1;

    for (const [key, value] of Object.entries(data)) {
      if (allowedFields.includes(key)) {
        updateFields.push(`${key} = $${paramIndex}`);
        values.push(value);
        paramIndex++;
      }
    }

    if (updateFields.length === 0) return null;

    values.push(id);
    const query = `
      UPDATE users
      SET ${updateFields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramIndex}
      RETURNING *;
    `;
    const result = await pool.query(query, values);
    return result.rows[0] || null;
  }

  static async updateLastLogin(id) {
    const query = `
      UPDATE users
      SET last_login = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *;
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async getAllUsers(limit = 10, offset = 0) {
    const query = `
      SELECT id, phone_number, full_name, email, is_verified, created_at
      FROM users
      ORDER BY created_at DESC
      LIMIT $1 OFFSET $2;
    `;
    const result = await pool.query(query, [limit, offset]);
    return result.rows;
  }

  static async countUsers() {
    const query = 'SELECT COUNT(*) as count FROM users';
    const result = await pool.query(query);
    return parseInt(result.rows[0].count, 10);
  }
}

module.exports = UserModel;
