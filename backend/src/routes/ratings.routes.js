const express = require('express');
const RatingController = require('../controllers/ratings.controller');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Get my ratings
router.get('/my-ratings', authMiddleware, RatingController.getMyRatings);

// Get rating for a trip
router.get('/trip/:tripId', authMiddleware, RatingController.getTripRating);

// Create a new rating
router.post('/', authMiddleware, RatingController.createRating);

// Get ratings for a line
router.get('/line/:lineId', RatingController.getLineRatings);

// Get ratings for a company
router.get('/company/:companyId', RatingController.getCompanyRatings);

module.exports = router;
