const pool = require('../database/connection');

class LineModel {
  static async findAll(filters = {}, limit = 20, offset = 0) {
    let query = `
      SELECT l.*, c.name as company_name, c.logo_url, c.rating_average
      FROM lines l
      JOIN companies c ON l.company_id = c.id
      WHERE l.is_active = true
    `;
    const values = [];
    let paramIndex = 1;

    if (filters.originCity) {
      query += ` AND LOWER(l.origin_city) LIKE LOWER($${paramIndex})`;
      values.push(`%${filters.originCity}%`);
      paramIndex++;
    }

    if (filters.destinationCity) {
      query += ` AND LOWER(l.destination_city) LIKE LOWER($${paramIndex})`;
      values.push(`%${filters.destinationCity}%`);
      paramIndex++;
    }

    if (filters.companyId) {
      query += ` AND l.company_id = $${paramIndex}`;
      values.push(filters.companyId);
      paramIndex++;
    }

    query += ` ORDER BY c.rating_average DESC, l.base_price ASC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    values.push(limit, offset);

    const result = await pool.query(query, values);
    return result.rows;
  }

  static async findById(id) {
    const query = `
      SELECT l.*, c.name as company_name, c.logo_url, c.rating_average
      FROM lines l
      JOIN companies c ON l.company_id = c.id
      WHERE l.id = $1;
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async findByCode(lineCode) {
    const query = `
      SELECT l.*, c.name as company_name, c.logo_url, c.rating_average
      FROM lines l
      JOIN companies c ON l.company_id = c.id
      WHERE l.line_code = $1;
    `;
    const result = await pool.query(query, [lineCode]);
    return result.rows[0] || null;
  }

  static async create(companyId, data) {
    const {
      lineCode, originCity, destinationCity, originName, destinationName,
      originLatitude, originLongitude, destinationLatitude, destinationLongitude,
      basePrice, luggagePricePerKg, distanceKm, estimatedDurationMinutes,
    } = data;

    const query = `
      INSERT INTO lines 
      (company_id, line_code, origin_city, destination_city, origin_name, destination_name,
       origin_latitude, origin_longitude, destination_latitude, destination_longitude,
       base_price, luggage_price_per_kg, distance_km, estimated_duration_minutes)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *;
    `;

    const result = await pool.query(query, [
      companyId, lineCode, originCity, destinationCity, originName, destinationName,
      originLatitude, originLongitude, destinationLatitude, destinationLongitude,
      basePrice, luggagePricePerKg, distanceKm, estimatedDurationMinutes,
    ]);
    return result.rows[0];
  }

  static async getSchedules(lineId, date = null) {
    let query = `
      SELECT s.* FROM schedules s
      WHERE s.line_id = $1 AND s.is_active = true
    `;
    const values = [lineId];

    if (date) {
      query += ` AND s.valid_from <= $2 AND s.valid_until >= $2
        AND EXTRACT(DOW FROM $2::date)::int = ANY(s.days_of_week)`;
      values.push(date);
    }

    query += ` ORDER BY s.departure_time ASC`;

    const result = await pool.query(query, values);
    return result.rows;
  }

  static async getStops(lineId) {
    const query = `
      SELECT * FROM stops
      WHERE line_id = $1
      ORDER BY stop_order ASC;
    `;
    const result = await pool.query(query, [lineId]);
    return result.rows;
  }

  static async search(originCity, destinationCity, date) {
    const query = `
      SELECT DISTINCT
        l.id, l.line_code, l.company_id, l.origin_city, l.destination_city,
        l.origin_name, l.destination_name, l.base_price, l.luggage_price_per_kg,
        l.distance_km, l.estimated_duration_minutes,
        c.name as company_name, c.logo_url, c.rating_average,
        COUNT(DISTINCT s.id) as schedule_count
      FROM lines l
      JOIN companies c ON l.company_id = c.id
      LEFT JOIN schedules s ON l.id = s.line_id 
        AND s.valid_from <= $3 AND s.valid_until >= $3
        AND EXTRACT(DOW FROM $3::date)::int = ANY(s.days_of_week)
        AND s.is_active = true
      WHERE LOWER(l.origin_city) LIKE '%' || LOWER($1) || '%'
        AND LOWER(l.destination_city) LIKE '%' || LOWER($2) || '%'
        AND l.is_active = true
      GROUP BY l.id, l.line_code, l.company_id, l.origin_city, l.destination_city,
        l.origin_name, l.destination_name, l.base_price, l.luggage_price_per_kg,
        l.distance_km, l.estimated_duration_minutes,
        c.id, c.name, c.logo_url, c.rating_average
      ORDER BY c.rating_average DESC, l.base_price ASC;
    `;
    const result = await pool.query(query, [originCity, destinationCity, date]);
    return result.rows;
  }
}

module.exports = LineModel;
