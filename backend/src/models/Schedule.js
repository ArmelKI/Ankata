const pool = require('../database/connection');

class ScheduleModel {
  static async findById(id) {
    const query = 'SELECT * FROM schedules WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async decrementAvailableSeats(scheduleId) {
    const query = `
      UPDATE schedules
      SET available_seats = available_seats - 1
      WHERE id = $1 AND available_seats > 0
      RETURNING *;
    `;
    const result = await pool.query(query, [scheduleId]);
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
