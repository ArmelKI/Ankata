const CompanyModel = require('../models/Company');
const RatingModel = require('../models/Rating');
const pool = require('../database/connection');

class CompanyController {
  // Get all companies
  static async getAllCompanies(req, res) {
    try {
      const { limit = 20, offset = 0 } = req.query;

      const parsedLimit = Math.min(parseInt(limit, 10) || 20, 100);
      const parsedOffset = parseInt(offset, 10) || 0;

      const companies = await CompanyModel.findAll(parsedLimit, parsedOffset);

      res.status(200).json({
        companies,
        count: companies.length,
        limit: parsedLimit,
        offset: parsedOffset,
      });
    } catch (error) {
      console.error('Get all companies error:', error);
      res.status(500).json({
        error: 'Failed to fetch companies',
        details: error.message,
      });
    }
  }

  // Get company details
  static async getCompanyDetails(req, res) {
    try {
      const { companyId } = req.params;

      const company = await CompanyModel.findById(companyId);
      if (!company) {
        return res.status(404).json({ error: 'Company not found' });
      }

      const stats = await CompanyModel.getStats(companyId);
      const ratings = await RatingModel.findByCompanyId(companyId, 5, 0);

      res.status(200).json({
        company: {
          ...company,
          stats,
          ratings,
        },
      });
    } catch (error) {
      console.error('Get company details error:', error);
      res.status(500).json({
        error: 'Failed to fetch company details',
        details: error.message,
      });
    }
  }

  // Get company by slug
  static async getCompanyBySlug(req, res) {
    try {
      const { slug } = req.params;

      const company = await CompanyModel.findBySlug(slug);
      if (!company) {
        return res.status(404).json({ error: 'Company not found' });
      }

      const stats = await CompanyModel.getStats(company.id);
      const ratings = await RatingModel.findByCompanyId(company.id, 5, 0);

      res.status(200).json({
        company: {
          ...company,
          stats,
          ratings,
        },
      });
    } catch (error) {
      console.error('Get company by slug error:', error);
      res.status(500).json({
        error: 'Failed to fetch company',
        details: error.message,
      });
    }
  }

  // Get company ratings
  static async getCompanyRatings(req, res) {
    try {
      const { companyId } = req.params;
      const { limit = 10, offset = 0 } = req.query;

      const company = await CompanyModel.findById(companyId);
      if (!company) {
        return res.status(404).json({ error: 'Company not found' });
      }

      const parsedLimit = Math.min(parseInt(limit, 10) || 10, 100);
      const parsedOffset = parseInt(offset, 10) || 0;

      const ratings = await RatingModel.findByCompanyId(companyId, parsedLimit, parsedOffset);
      const stats = await RatingModel.getCompanyStats(companyId);

      res.status(200).json({
        companyId,
        companyName: company.name,
        stats,
        ratings,
        count: ratings.length,
      });
    } catch (error) {
      console.error('Get company ratings error:', error);
      res.status(500).json({
        error: 'Failed to fetch company ratings',
        details: error.message,
      });
    }
  }

  // Get company schedules
  static async getCompanySchedules(req, res) {
    try {
      const { slug } = req.params;
      
      const company = await CompanyModel.findBySlug(slug);
      if (!company) {
        return res.status(404).json({ error: 'Company not found' });
      }

      const query = `
        SELECT s.*, l.origin_city, l.destination_city, l.base_price, l.line_code, l.line_type
        FROM schedules s
        JOIN lines l ON s.line_id = l.id
        WHERE l.company_id = $1 AND s.is_active = true AND l.is_active = true
        ORDER BY s.departure_time ASC;
      `;
      const result = await pool.query(query, [company.id]);

      res.status(200).json({
        schedules: result.rows,
        company: {
           id: company.id,
           name: company.name
        }
      });
    } catch (error) {
      console.error('Get company schedules error:', error);
      res.status(500).json({
        error: 'Failed to fetch company schedules',
        details: error.message,
      });
    }
  }
}

module.exports = CompanyController;
