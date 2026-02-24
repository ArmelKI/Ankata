const pool = require('../database/connection');

class CompanyModel {
  static async findAll(limit = 20, offset = 0) {
    const query = `
      SELECT * FROM companies
      WHERE is_active = true
      ORDER BY rating_average DESC, total_ratings DESC
      LIMIT $1 OFFSET $2;
    `;
    const result = await pool.query(query, [limit, offset]);
    return result.rows;
  }

  static async findById(id) {
    const query = 'SELECT * FROM companies WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  }

  static async findBySlug(slug) {
    const query = 'SELECT * FROM companies WHERE slug = $1';
    const result = await pool.query(query, [slug]);
    return result.rows[0] || null;
  }

  static async create(data) {
    const {
      name, slug, description, logoUrl, primaryColor,
      secondaryColor, phone, whatsapp, facebookUrl, headquartersAddress,
    } = data;

    const query = `
      INSERT INTO companies 
      (name, slug, description, logo_url, primary_color, secondary_color, 
       phone, whatsapp, facebook_url, headquarters_address)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *;
    `;

    const result = await pool.query(query, [
      name, slug, description, logoUrl, primaryColor,
      secondaryColor, phone, whatsapp, facebookUrl, headquartersAddress,
    ]);
    return result.rows[0];
  }

  static async updateRating(companyId, avgRating, totalRatings) {
    const query = `
      UPDATE companies
      SET rating_average = $1, total_ratings = $2, updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *;
    `;
    const result = await pool.query(query, [avgRating, totalRatings, companyId]);
    return result.rows[0] || null;
  }

  static async getStats(companyId) {
    const query = `
      SELECT 
        c.id,
        c.name,
        c.rating_average,
        c.total_ratings,
        COUNT(DISTINCT l.id) as total_lines,
        COUNT(DISTINCT b.id) as total_bookings,
        SUM(CASE WHEN b.payment_status = 'completed' THEN b.total_amount ELSE 0 END) as total_revenue
      FROM companies c
      LEFT JOIN lines l ON c.id = l.company_id
      LEFT JOIN bookings b ON c.id = b.company_id
      WHERE c.id = $1
      GROUP BY c.id, c.name, c.rating_average, c.total_ratings;
    `;
    const result = await pool.query(query, [companyId]);
    return result.rows[0] || null;
  }
}

module.exports = CompanyModel;
