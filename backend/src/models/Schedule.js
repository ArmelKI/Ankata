const pool = require('../database/connection');

class ScheduleModel {
  static async findById(id) {
    const query = 'SELECT * FROM schedules WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async decrementAvailableSeats(scheduleId, count = 1) {
    // Safely convert count to integer, minimum 1
    const safeCount = Math.max(1, parseInt(count, 10) || 1);
    const query = `
      UPDATE schedules
      SET available_seats = available_seats - $2
      WHERE id = $1 AND available_seats >= $2
      RETURNING *;
    `;
    const result = await pool.query(query, [scheduleId, safeCount]);
    return result.rows[0] || null;
  }

  static async decrementAvailableSeatsBy(scheduleId, count) {
    const query = `
      UPDATE schedules
      SET available_seats = available_seats - $2
      WHERE id = $1 AND available_seats >= $2
      RETURNING *;
    `;
    const result = await pool.query(query, [scheduleId, count]);
    return result.rows[0] || null;
  }

  static async incrementAvailableSeats(scheduleId) {
    const query = `
      UPDATE schedules
      SET available_seats = available_seats + 1
      WHERE id = $1
      RETURNING *;
    `;
    const result = await pool.query(query, [scheduleId]);
    return result.rows[0] || null;
  }

  static async incrementAvailableSeatsBy(scheduleId, count) {
    const query = `
      UPDATE schedules
      SET available_seats = available_seats + $2
      WHERE id = $1
      RETURNING *;
    `;
    const result = await pool.query(query, [scheduleId, count]);
    return result.rows[0] || null;
  }

  static async create(lineId, departureTime, daysOfWeek, totalSeats) {
    const query = `
      INSERT INTO schedules (line_id, departure_time, days_of_week, total_seats, available_seats, valid_from, valid_until)
      VALUES ($1, $2, $3, $4, $4, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 year')
      RETURNING *;
    `;
    const result = await pool.query(query, [lineId, departureTime, daysOfWeek, totalSeats]);
    return result.rows[0];
  }
}

module.exports = ScheduleModel;
