const pool = require('../database/connection');

class RatingModel {
  static async create(data) {
    const {
      bookingId, userId, companyId, lineId,
      rating, punctualityRating, comfortRating, serviceRating, cleanlinessRating,
      comment,
    } = data;

    const query = `
      INSERT INTO ratings
      (booking_id, user_id, company_id, line_id, rating,
       punctuality_rating, comfort_rating, service_rating, cleanliness_rating, comment, is_verified)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, false)
      RETURNING *;
    `;

    const result = await pool.query(query, [
      bookingId, userId, companyId, lineId,
      rating, punctualityRating, comfortRating, serviceRating, cleanlinessRating,
      comment,
    ]);

    return result.rows[0];
  }

  static async verify(ratingId) {
    const query = `
      UPDATE ratings SET is_verified = true
      WHERE id = $1 RETURNING *;
    `;
    const result = await pool.query(query, [ratingId]);
    return result.rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM ratings WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async findByCompanyId(companyId, limit = 10, offset = 0) {
    const query = `
      SELECT r.*, u.full_name, u.profile_picture_url
      FROM ratings r
      LEFT JOIN users u ON r.user_id = u.id
      WHERE r.company_id = $1 AND r.is_visible = true
      ORDER BY r.created_at DESC
      LIMIT $2 OFFSET $3;
    `;
    const result = await pool.query(query, [companyId, limit, offset]);
    return result.rows;
  }

  static async findByLineId(lineId, limit = 10, offset = 0) {
    const query = `
      SELECT r.*, u.full_name, u.profile_picture_url
      FROM ratings r
      LEFT JOIN users u ON r.user_id = u.id
      WHERE r.line_id = $1 AND r.is_visible = true
      ORDER BY r.created_at DESC
      LIMIT $2 OFFSET $3;
    `;
    const result = await pool.query(query, [lineId, limit, offset]);
    return result.rows;
  }

  static async getCompanyStats(companyId) {
    const query = `
      SELECT 
        AVG(rating) as avg_rating,
        AVG(punctuality_rating) as avg_punctuality,
        AVG(comfort_rating) as avg_comfort,
        AVG(service_rating) as avg_service,
        AVG(cleanliness_rating) as avg_cleanliness,
        COUNT(*) as total_ratings,
        COUNT(DISTINCT user_id) as total_reviewers
      FROM ratings
      WHERE company_id = $1 AND is_visible = true;
    `;
    const result = await pool.query(query, [companyId]);
    return result.rows[0] || null;
  }

  static async deleteRating(ratingId) {
    const query = 'DELETE FROM ratings WHERE id = $1 RETURNING *';
    const result = await pool.query(query, [ratingId]);
    return result.rows[0] || null;
  }

  static async countRatingsByCompany(companyId) {
    const query = 'SELECT COUNT(*) as count FROM ratings WHERE company_id = $1 AND is_visible = true';
    const result = await pool.query(query, [companyId]);
    return parseInt(result.rows[0].count, 10);
  }
  
  static async hasUserRatedBooking(userId, bookingId) {
    const query = 'SELECT COUNT(*) as count FROM ratings WHERE user_id = $1 AND booking_id = $2';
    const result = await pool.query(query, [userId, bookingId]);
    return parseInt(result.rows[0].count, 10) > 0;
  }
}

module.exports = RatingModel;
