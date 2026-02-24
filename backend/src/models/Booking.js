const pool = require('../database/connection');

class BookingModel {
  static async create(data) {
    const {
      bookingCode, userId, scheduleId, lineId,
      passengerName, passengerPhone, passengerEmail, numPassengers, travelDate, seatNumbers,
      luggageWeightKg, totalPrice, luggagePrice, serviceFee, paymentMethod, specialRequests
    } = data;

    const query = `
      INSERT INTO bookings
      (booking_code, user_id, schedule_id, line_id,
       passenger_name, passenger_phone, passenger_email, num_passengers, travel_date, seat_numbers,
       luggage_weight_kg, total_price, luggage_price, service_fee, payment_method, special_requests)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
      RETURNING *;
    `;

    const result = await pool.query(query, [
      bookingCode, userId, scheduleId, lineId,
      passengerName, passengerPhone, passengerEmail, numPassengers || 1, travelDate, seatNumbers || [],
      luggageWeightKg || 0, totalPrice, luggagePrice || 0, serviceFee || 0, paymentMethod, specialRequests
    ]);

    return result.rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM bookings WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async findByCode(bookingCode) {
    const query = 'SELECT * FROM bookings WHERE booking_code = $1';
    const result = await pool.query(query, [bookingCode]);
    return result.rows[0] || null;
  }

  static async findByUserId(userId, status = null, limit = 20, offset = 0) {
    let query = `
      SELECT b.*, l.origin_city, l.destination_city, l.company_id,
        c.name as company_name, c.logo_url
      FROM bookings b
      JOIN lines l ON b.line_id = l.id
      JOIN companies c ON l.company_id = c.id
      WHERE b.user_id = $1
    `;
    const values = [userId];
    let paramIndex = 2;

    if (status) {
      query += ` AND b.booking_status = $${paramIndex}`;
      values.push(status);
      paramIndex++;
    }

    query += ` ORDER BY b.travel_date DESC, b.created_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    values.push(limit, offset);

    const result = await pool.query(query, values);
    return result.rows;
  }

  static async getMyBookings(userId) {
    const today = new Date().toISOString().split('T')[0];

    const query = `
      SELECT 
        b.*, 
        l.origin_city, l.destination_city, l.company_id,
        c.name as company_name, c.logo_url,
        s.departure_time
      FROM bookings b
      JOIN lines l ON b.line_id = l.id
      JOIN companies c ON l.company_id = c.id
      JOIN schedules s ON b.schedule_id = s.id
      WHERE b.user_id = $1 AND b.booking_status != 'CANCELLED'
      ORDER BY 
        CASE WHEN b.travel_date >= $2 THEN 1 ELSE 2 END,
        b.travel_date DESC;
    `;

    const result = await pool.query(query, [userId, today]);
    
    const upcoming = result.rows.filter(b => new Date(b.travel_date) >= new Date(today));
    const past = result.rows.filter(b => new Date(b.travel_date) < new Date(today));

    return { upcoming, past };
  }

  static async updatePaymentStatus(bookingId, status, transactionId = null) {
    const query = `
      UPDATE bookings
      SET payment_status = $1, transaction_id = COALESCE($2, transaction_id), updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *;
    `;
    const result = await pool.query(query, [status, transactionId, bookingId]);
    return result.rows[0] || null;
  }

  static async updateBookingStatus(bookingId, status) {
    const query = `
      UPDATE bookings
      SET booking_status = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING *;
    `;
    const result = await pool.query(query, [status, bookingId]);
    return result.rows[0] || null;
  }

  static async cancelBooking(bookingId, reason) {
    const query = `
      UPDATE bookings
      SET booking_status = 'CANCELLED', cancellation_reason = $1, cancelled_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING *;
    `;
    const result = await pool.query(query, [reason, bookingId]);
    return result.rows[0] || null;
  }

  static async countBookingsByStatus(status) {
    const query = 'SELECT COUNT(*) as count FROM bookings WHERE booking_status = $1';
    const result = await pool.query(query, [status]);
    return parseInt(result.rows[0].count, 10);
  }
}

module.exports = BookingModel;
