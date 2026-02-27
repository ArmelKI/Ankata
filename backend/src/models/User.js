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

  static async findByGoogleId(googleId) {
    const query = 'SELECT * FROM users WHERE google_id = $1';
    const result = await pool.query(query, [googleId]);
    return result.rows[0] || null;
  }

  static async findByReferralCode(referralCode) {
    const query = 'SELECT * FROM users WHERE referral_code = $1';
    const result = await pool.query(query, [referralCode]);
    return result.rows[0] || null;
  }

  static async addWalletBalance(userId, amount) {
    const query = `
      UPDATE users
      SET wallet_balance = COALESCE(wallet_balance, 0) + $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING id, wallet_balance;
    `;
    const result = await pool.query(query, [amount, userId]);
    return result.rows[0] || null;
  }

  static async addXP(userId, amount) {
    const query = `
      UPDATE users
      SET xp = COALESCE(xp, 0) + $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING id, xp, level;
    `;
    const result = await pool.query(query, [amount, userId]);
    const user = result.rows[0];

    if (user) {
      // Formula: Level = floor(sqrt(XP / 100)) + 1
      const newLevel = Math.floor(Math.sqrt(user.xp / 100)) + 1;

      if (parseInt(user.level) !== newLevel) {
        await pool.query('UPDATE users SET level = $1 WHERE id = $2', [newLevel, userId]);
        user.level = newLevel;
      }
    }

    return user;
  }

  static async create(data) {
    const {
      phoneNumber, firstName, lastName, passwordHash, securityQ1, securityA1,
      securityQ2, securityA2, googleId, email, referralCode, referredBy,
    } = data;

    const query = `
      INSERT INTO users (phone_number, first_name, last_name, password_hash, security_q1, security_a1, security_q2, security_a2, google_id, email, is_verified, referral_code, referred_by)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING id, phone_number, first_name, last_name, email, is_verified, referral_code, created_at;
    `;
    const result = await pool.query(query, [
      phoneNumber, firstName, lastName, passwordHash,
      securityQ1 || null, securityA1 || null, securityQ2 || null, securityA2 || null,
      googleId || null, email || null,
      !!(googleId || true),
      referralCode || null, referredBy || null,
    ]);
    return result.rows[0];
  }

  static async update(id, data) {
    const allowedFields = [
      'first_name', 'last_name', 'date_of_birth', 'cnib', 'gender',
      'profile_picture_url', 'is_verified', 'email', 'city',
    ];
    const updateFields = [];
    const values = [];
    let paramIndex = 1;

    for (const [key, value] of Object.entries(data)) {
      if (allowedFields.includes(key) && value !== undefined) {
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

  static async updatePassword(id, passwordHash) {
    const query = `
      UPDATE users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2 RETURNING id;
    `;
    const result = await pool.query(query, [passwordHash, id]);
    return result.rows[0] || null;
  }

  static async updateLastLogin(id) {
    const query = `
      UPDATE users SET last_login = CURRENT_TIMESTAMP
      WHERE id = $1 RETURNING *;
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async getAllUsers(limit = 10, offset = 0) {
    const query = `
      SELECT id, phone_number, first_name, last_name, email, date_of_birth, cnib, gender,
             city, is_verified, referral_code, wallet_balance, created_at
      FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2;
    `;
    const result = await pool.query(query, [limit, offset]);
    return result.rows;
  }

  static async countUsers() {
    const query = 'SELECT COUNT(*) as count FROM users';
    const result = await pool.query(query);
    return parseInt(result.rows[0].count, 10);
  }

  static async getReferralStats(id) {
    const user = await this.findById(id);
    if (!user || !user.referral_code) return { count: 0, totalEarned: 0 };

    const countQuery = 'SELECT COUNT(*) as count FROM users WHERE referred_by = $1';
    const countResult = await pool.query(countQuery, [user.referral_code]);
    
    // Sum of referral bonus transactions for this user
    const earnQuery = "SELECT SUM(amount) as total FROM transactions WHERE user_id = $1 AND type = 'referral_bonus'";
    const earnResult = await pool.query(earnQuery, [id]);

    return {
      referralCode: user.referral_code,
      referralCount: parseInt(countResult.rows[0].count, 10),
      totalEarned: parseFloat(earnResult.rows[0].total || 0)
    };
  }
}

module.exports = UserModel;
