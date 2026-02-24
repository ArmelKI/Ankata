const pool = require('../database/connection');

class PaymentModel {
  static async create(data) {
    const {
      bookingId, userId, amount, currency = 'XOF',
      paymentMethod, paymentProvider, metadata = {},
    } = data;

    const query = `
      INSERT INTO payments
      (booking_id, user_id, amount, currency, payment_method, payment_provider, metadata)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;

    const result = await pool.query(query, [
      bookingId, userId, amount, currency,
      paymentMethod, paymentProvider, JSON.stringify(metadata),
    ]);

    return result.rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM payments WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async findByBookingId(bookingId) {
    const query = 'SELECT * FROM payments WHERE booking_id = $1 ORDER BY created_at DESC LIMIT 1';
    const result = await pool.query(query, [bookingId]);
    return result.rows[0] || null;
  }

  static async updateStatus(paymentId, status, transactionId = null, providerReference = null) {
    let updateFields = ['payment_status = $1', 'updated_at = CURRENT_TIMESTAMP'];
    const values = [status, paymentId];
    let index = 3;

    if (transactionId) {
      updateFields.push(`transaction_id = $${index}`);
      values.push(transactionId);
      index++;
    }
    
    if (providerReference) {
      updateFields.push(`provider_reference = $${index}`);
      values.push(providerReference);
      index++;
    }

    if (status === 'COMPLETED') {
        updateFields.push(`payment_date = CURRENT_TIMESTAMP`);
    }

    const query = `
      UPDATE payments
      SET ${updateFields.join(', ')}
      WHERE id = $2
      RETURNING *;
    `;
    const result = await pool.query(query, values);
    return result.rows[0] || null;
  }

  static async countByStatus(status) {
    const query = 'SELECT COUNT(*) as count FROM payments WHERE payment_status = $1';
    const result = await pool.query(query, [status]);
    return parseInt(result.rows[0].count, 10);
  }
}

module.exports = PaymentModel;
