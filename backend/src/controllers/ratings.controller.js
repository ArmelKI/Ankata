const RatingModel = require('../models/Rating');
const BookingModel = require('../models/Booking');
const CompanyModel = require('../models/Company');

class RatingController {
  // Create a new rating
  static async createRating(req, res) {
    try {
      const userId = req.user.userId;
      const {
        bookingId,
        companyId,
        lineId,
        rating,
        punctualityRating,
        comfortRating,
        staffRating, // Mobile might send staffRating, map to serviceRating
        serviceRating,
        cleanlinessRating,
        comment,
      } = req.body;

      // Validate required fields
      if (!companyId || !lineId || !rating) {
        return res.status(400).json({
          error: 'Missing required fields: companyId, lineId, rating',
        });
      }

      // Validate rating values
      if (rating < 1 || rating > 5) {
        return res.status(400).json({ error: 'Rating must be between 1 and 5' });
      }

      if (bookingId) {
        const booking = await BookingModel.findById(bookingId);
        if (!booking || booking.user_id !== userId) {
          return res.status(403).json({ error: 'Unauthorized or booking not found' });
        }

        // Business Rule 1: Booking must be COMPLETED
        if (booking.booking_status !== 'COMPLETED') {
          return res.status(400).json({ error: 'Vous ne pouvez noter qu\'un trajet terminé' });
        }

        // Business Rule 2: Cannot rate if elapsed time > 7 days
        const travelDate = new Date(booking.travel_date);
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
        if (travelDate < sevenDaysAgo) {
          return res.status(400).json({ error: 'Le délai de 7 jours pour noter ce trajet a expiré' });
        }

        // Business Rule 3: Cannot rate twice
        const alreadyRated = await RatingModel.hasUserRatedBooking(userId, bookingId);
        if (alreadyRated) {
          return res.status(400).json({ error: 'Vous avez déjà noté ce trajet' });
        }
      }

      // Create rating
      const newRating = await RatingModel.create({
        bookingId,
        userId,
        companyId,
        lineId,
        rating,
        punctualityRating: punctualityRating || rating,
        comfortRating: comfortRating || rating,
        serviceRating: serviceRating || staffRating || rating,
        cleanlinessRating: cleanlinessRating || rating,
        comment,
      });

      // Update company ratings
      const stats = await RatingModel.getCompanyStats(companyId);
      if (stats) {
        // Average can be derived from company stats if needed later
      }

      // Mark booking as rated if provided
      /* We don't need this anymore since hasUserRatedBooking is doing the check in ratings table directly
      if (bookingId) {
        await BookingModel.markAsRated(bookingId);
      }
      */

      res.status(201).json({
        message: 'Rating created successfully',
        rating: newRating,
      });
    } catch (error) {
      console.error('Create rating error:', error);
      res.status(500).json({
        error: 'Failed to create rating',
        details: error.message,
      });
    }
  }

  // Get line ratings
  static async getLineRatings(req, res) {
    try {
      const { lineId } = req.params;
      const { limit = 10, offset = 0 } = req.query;

      const parsedLimit = Math.min(parseInt(limit, 10) || 10, 100);
      const parsedOffset = parseInt(offset, 10) || 0;

      const ratings = await RatingModel.findByLineId(lineId, parsedLimit, parsedOffset);

      res.status(200).json({
        lineId,
        ratings,
        count: ratings.length,
      });
    } catch (error) {
      console.error('Get line ratings error:', error);
      res.status(500).json({
        error: 'Failed to fetch line ratings',
        details: error.message,
      });
    }
  }

  // Get company ratings
  static async getCompanyRatings(req, res) {
    try {
      const { companyId } = req.params;
      const { limit = 10, offset = 0 } = req.query;

      const parsedLimit = Math.min(parseInt(limit, 10) || 10, 100);
      const parsedOffset = parseInt(offset, 10) || 0;

      const ratings = await RatingModel.findByCompanyId(companyId, parsedLimit, parsedOffset);
      const stats = await RatingModel.getCompanyStats(companyId);

      res.status(200).json({
        companyId,
        stats,
        ratings,
        count: ratings.length,
      });
    } catch (error) {
      console.error('Get company ratings error:', error);
      res.status(500).json({
        error: 'Failed to fetch ratings',
        details: error.message,
      });
    }
  }

  // Get my ratings
  static async getMyRatings(req, res) {
    try {
      const userId = req.user.userId;
      const { limit = 20, offset = 0 } = req.query;
      
      const parsedLimit = Math.min(parseInt(limit, 10) || 20, 100);
      const parsedOffset = parseInt(offset, 10) || 0;

      const pool = require('../database/connection');
      const query = `
        SELECT r.*, c.name as company_name, l.origin_city, l.destination_city
        FROM ratings r
        JOIN companies c ON r.company_id = c.id
        JOIN lines l ON r.line_id = l.id
        WHERE r.user_id = $1
        ORDER BY r.created_at DESC
        LIMIT $2 OFFSET $3;
      `;
      
      const result = await pool.query(query, [userId, parsedLimit, parsedOffset]);

      res.status(200).json({
        ratings: result.rows,
        count: result.rows.length,
      });
    } catch (error) {
      console.error('Get my ratings error:', error);
      res.status(500).json({
        error: 'Failed to fetch my ratings',
        details: error.message,
      });
    }
  }

  // Get trip rating
  static async getTripRating(req, res) {
    try {
      const { tripId } = req.params;
      const userId = req.user.userId;
      
      const pool = require('../database/connection');
      const query = 'SELECT * FROM ratings WHERE booking_id = $1 AND user_id = $2';
      const result = await pool.query(query, [tripId, userId]);
      
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Rating not found for this trip' });
      }

      res.status(200).json({
        rating: result.rows[0]
      });
    } catch (error) {
      console.error('Get trip rating error:', error);
      res.status(500).json({
        error: 'Failed to fetch trip rating',
        details: error.message,
      });
    }
  }
}

module.exports = RatingController;
