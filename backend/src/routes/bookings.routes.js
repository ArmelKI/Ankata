const express = require('express');
const BookingController = require('../controllers/bookings.controller');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Create a new booking
router.post('/', authMiddleware, BookingController.createBooking);

// Get my bookings (upcoming and past)
router.get('/my-bookings', authMiddleware, BookingController.getMyBookings);

// Get booking details
router.get('/:bookingId', authMiddleware, BookingController.getBookingDetails);

// Get booking by code (public endpoint)
router.get('/code/:bookingCode', BookingController.getBookingByCode);

// Cancel booking
router.post('/:bookingId/cancel', authMiddleware, BookingController.cancelBooking);

module.exports = router;
