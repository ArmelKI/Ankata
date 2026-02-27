const pool = require('../database/connection');

class PassengerModel {
  static async findByUserId(userId) {
    const query = 'SELECT * FROM saved_passengers WHERE user_id = $1 ORDER BY created_at DESC';
    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async findById(id) {
    const query = 'SELECT * FROM saved_passengers WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async create(data) {
    const {
      userId, firstName, lastName, phoneNumber, idType, idNumber,
    } = data;

    const query = `
      INSERT INTO saved_passengers (user_id, first_name, last_name, phone_number, id_type, id_number)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *;
    `;
    const result = await pool.query(query, [
      userId, firstName, lastName, phoneNumber || null, idType || null, idNumber || null,
    ]);
    return result.rows[0];
  }

  static async update(id, data) {
    const allowedFields = [
      'first_name', 'last_name', 'phone_number', 'id_type', 'id_number',
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
      UPDATE saved_passengers
      SET ${updateFields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramIndex}
      RETURNING *;
    `;
    const result = await pool.query(query, values);
    return result.rows[0] || null;
  }

  static async delete(id) {
    const query = 'DELETE FROM saved_passengers WHERE id = $1 RETURNING id;';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }
}

module.exports = PassengerModel;
