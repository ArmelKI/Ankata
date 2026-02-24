const express = require('express');
const LineController = require('../controllers/lines.controller');
const { optionalAuth } = require('../middleware/auth');

const router = express.Router();

// Get all lines with filters
router.get('/', LineController.getAllLines);

// Search lines by origin, destination, and date
router.get('/search', LineController.searchLines);

// Get line details with schedules and stops
router.get('/:lineId', LineController.getLineDetails);

// Get schedules for a line
router.get('/:lineId/schedules', LineController.getSchedules);

// Get stops for a line
router.get('/:lineId/stops', LineController.getStops);

module.exports = router;
