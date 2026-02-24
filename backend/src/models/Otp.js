const pool = require('../database/connection');

class OtpModel {
  static async create(phoneNumber, otpCode, expiresAt, purpose = 'LOGIN') {
    const query = `
      INSERT INTO otp_codes (phone_number, otp_code, expires_at, purpose)
      VALUES ($1, $2, $3, $4)
      RETURNING *;
    `;
    const result = await pool.query(query, [phoneNumber, otpCode, expiresAt, purpose]);
    return result.rows[0];
  }

  static async findLatestByPhone(phoneNumber, purpose = 'LOGIN') {
    const query = `
      SELECT * FROM otp_codes
      WHERE phone_number = $1 AND purpose = $2
      ORDER BY created_at DESC
      LIMIT 1;
    `;
    const result = await pool.query(query, [phoneNumber, purpose]);
    return result.rows[0] || null;
  }

  static async findById(id) {
    const query = 'SELECT * FROM otp_codes WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async updateAttempts(id) {
    const query = `
      UPDATE otp_codes
      SET attempts = attempts + 1
      WHERE id = $1
      RETURNING *;
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async markVerified(id) {
    const query = `
      UPDATE otp_codes
      SET is_verified = true, verified_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *;
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async deleteExpired() {
    const query = `
      DELETE FROM otp_codes
      WHERE expires_at < CURRENT_TIMESTAMP;
    `;
    await pool.query(query);
  }
}

module.exports = OtpModel;
