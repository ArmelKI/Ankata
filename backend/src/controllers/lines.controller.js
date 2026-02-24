const LineModel = require('../models/Line');
const CompanyModel = require('../models/Company');

class LineController {
  // Get all lines with search filters
  static async getAllLines(req, res) {
    try {
      const { originCity, destinationCity, companyId, limit = 20, offset = 0 } = req.query;

      const parsedLimit = Math.min(parseInt(limit, 10) || 20, 100);
      const parsedOffset = parseInt(offset, 10) || 0;

      const filters = {};
      if (originCity) filters.originCity = originCity;
      if (destinationCity) filters.destinationCity = destinationCity;
      if (companyId) filters.companyId = companyId;

      const lines = await LineModel.findAll(filters, parsedLimit, parsedOffset);

      res.status(200).json({
        lines,
        count: lines.length,
        limit: parsedLimit,
        offset: parsedOffset,
      });
    } catch (error) {
      console.error('Get all lines error:', error);
      res.status(500).json({
        error: 'Failed to fetch lines',
        details: error.message,
      });
    }
  }

  // Search lines by origin and destination
  static async searchLines(req, res) {
    try {
      const { originCity, destinationCity, date } = req.query;

      if (!originCity || !destinationCity || !date) {
        return res.status(400).json({
          error: 'originCity, destinationCity, and date are required',
        });
      }

      // Validate date format
      const dateObj = new Date(date);
      if (isNaN(dateObj.getTime())) {
        return res.status(400).json({
          error: 'Invalid date format. Use YYYY-MM-DD',
        });
      }

      const lines = await LineModel.search(originCity, destinationCity, date);

      // Fetch schedules for each line
      const linesWithSchedules = await Promise.all(
        lines.map(async (line) => {
          const schedules = await LineModel.getSchedules(line.id, date);
          return {
            ...line,
            schedules,
          };
        })
      );

      res.status(200).json({
        originCity,
        destinationCity,
        date,
        lines: linesWithSchedules,
        count: linesWithSchedules.length,
      });
    } catch (error) {
      console.error('Search lines error:', error);
      res.status(500).json({
        error: 'Failed to search lines',
        details: error.message,
      });
    }
  }

  // Get line details with schedules and stops
  static async getLineDetails(req, res) {
    try {
      const { lineId } = req.params;
      const { date } = req.query;

      const line = await LineModel.findById(lineId);
      if (!line) {
        return res.status(404).json({ error: 'Line not found' });
      }

      const stops = await LineModel.getStops(lineId);

      let schedules = [];
      if (date) {
        schedules = await LineModel.getSchedules(lineId, date);
      } else {
        // Get all schedules if no date specified
        const result = await LineModel.getSchedules(lineId);
        schedules = result;
      }

      const company = await CompanyModel.findById(line.company_id);

      res.status(200).json({
        line: {
          ...line,
          company,
          stops,
          schedules,
        },
      });
    } catch (error) {
      console.error('Get line details error:', error);
      res.status(500).json({
        error: 'Failed to fetch line details',
        details: error.message,
      });
    }
  }

  // Get schedules for a line
  static async getSchedules(req, res) {
    try {
      const { lineId } = req.params;
      const { date } = req.query;

      const line = await LineModel.findById(lineId);
      if (!line) {
        return res.status(404).json({ error: 'Line not found' });
      }

      const schedules = await LineModel.getSchedules(lineId, date);

      res.status(200).json({
        lineId,
        date: date || 'all',
        schedules,
        count: schedules.length,
      });
    } catch (error) {
      console.error('Get schedules error:', error);
      res.status(500).json({
        error: 'Failed to fetch schedules',
        details: error.message,
      });
    }
  }

  // Get stops for a line
  static async getStops(req, res) {
    try {
      const { lineId } = req.params;

      const line = await LineModel.findById(lineId);
      if (!line) {
        return res.status(404).json({ error: 'Line not found' });
      }

      const stops = await LineModel.getStops(lineId);

      res.status(200).json({
        lineId,
        stops,
        count: stops.length,
      });
    } catch (error) {
      console.error('Get stops error:', error);
      res.status(500).json({
        error: 'Failed to fetch stops',
        details: error.message,
      });
    }
  }
}

module.exports = LineController;
