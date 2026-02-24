const BookingModel = require('../models/Booking');
const LineModel = require('../models/Line');
const ScheduleModel = require('../models/Schedule');
const { generateBookingCode } = require('../utils/helpers');

class BookingController {
  // Create a new booking
  static async createBooking(req, res) {
    try {
      const userId = req.user.userId;
      const {
        scheduleId,
        lineId,
        companyId,
        passengerName,
        passengerPhone,
        departureDate,
        luggageWeightKg = 0,
        paymentMethod = 'pending',
      } = req.body;

      // Validate required fields
      if (!scheduleId || !lineId || !companyId || !passengerName || !departureDate) {
        return res.status(400).json({
          error: 'Missing required fields: scheduleId, lineId, companyId, passengerName, departureDate',
        });
      }

      // Get line details for pricing
      const line = await LineModel.findById(lineId);
      if (!line) {
        return res.status(404).json({ error: 'Line not found' });
      }

      // Check schedule availability
      const schedule = await ScheduleModel.findById(scheduleId);
      if (!schedule || schedule.available_seats <= 0) {
        return res.status(400).json({ error: 'No available seats for this schedule' });
      }

      // Calculate pricing
      const basePrice = parseFloat(line.base_price);
      const luggageFee = luggageWeightKg * parseFloat(line.luggage_price_per_kg);
      const serviceFee = 200; // Frais de service Ankata fixes (ex: 200 FCFA)
      const totalAmount = basePrice + luggageFee + serviceFee;

      // Generate booking code
      const bookingCode = generateBookingCode();

      // Create booking
      const booking = await BookingModel.create({
        bookingCode,
        userId,
        scheduleId,
        lineId,
        passengerName,
        passengerPhone,
        passengerEmail: req.body.passengerEmail || null,
        numPassengers: 1,
        travelDate: departureDate, // Map to DB column name
        seatNumbers: [], // Will be assigned later
        luggageWeightKg,
        totalPrice: totalAmount,
        luggagePrice: luggageFee,
        serviceFee: serviceFee,
        paymentMethod,
        specialRequests: null
      });

      // Update available seats
      await ScheduleModel.decrementAvailableSeats(scheduleId);

      res.status(201).json({
        message: 'Booking created successfully',
        booking: {
          id: booking.id,
          bookingCode: booking.booking_code,
          passengerName: booking.passenger_name,
          travelDate: booking.travel_date,
          basePrice: basePrice,
          luggageFee: booking.luggage_price,
          serviceFee: booking.service_fee,
          totalAmount: booking.total_price,
          paymentStatus: booking.payment_status,
          bookingStatus: booking.booking_status,
        },
      });
    } catch (error) {
      console.error('Create booking error:', error);
      res.status(500).json({
        error: 'Failed to create booking',
        details: error.message,
      });
    }
  }

  // Get my bookings (upcoming and past)
  static async getMyBookings(req, res) {
    try {
      const userId = req.user.userId;
      const { status } = req.query;

      if (status && status !== 'upcoming' && status !== 'past') {
        return res.status(400).json({
          error: 'Invalid status. Use "upcoming" or "past"',
        });
      }

      const bookings = await BookingModel.getMyBookings(userId);

      let response = {};
      if (!status || status === 'upcoming') {
        response.upcoming = bookings.upcoming;
      }
      if (!status || status === 'past') {
        response.past = bookings.past;
      }

      if (status === 'upcoming') {
        response = { bookings: bookings.upcoming };
      } else if (status === 'past') {
        response = { bookings: bookings.past };
      } else {
        response.bookings = [...bookings.upcoming, ...bookings.past];
      }

      res.status(200).json(response);
    } catch (error) {
      console.error('Get my bookings error:', error);
      res.status(500).json({
        error: 'Failed to fetch bookings',
        details: error.message,
      });
    }
  }

  // Get booking details
  static async getBookingDetails(req, res) {
    try {
      const userId = req.user.userId;
      const { bookingId } = req.params;

      const booking = await BookingModel.findById(bookingId);
      if (!booking) {
        return res.status(404).json({ error: 'Booking not found' });
      }

      // Verify user owns this booking
      if (booking.user_id !== userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      res.status(200).json({
        booking,
      });
    } catch (error) {
      console.error('Get booking details error:', error);
      res.status(500).json({
        error: 'Failed to fetch booking details',
        details: error.message,
      });
    }
  }

  // Get booking by code (public endpoint)
  static async getBookingByCode(req, res) {
    try {
      const { bookingCode } = req.params;

      const booking = await BookingModel.findByCode(bookingCode);
      if (!booking) {
        return res.status(404).json({ error: 'Booking not found' });
      }

      res.status(200).json({
        booking: {
          bookingCode: booking.booking_code,
          passengerName: booking.passenger_name,
          departureDate: booking.departure_date,
          originCity: booking.origin_city,
          destinationCity: booking.destination_city,
          companyName: booking.company_name,
          totalAmount: booking.total_amount,
          paymentStatus: booking.payment_status,
          bookingStatus: booking.booking_status,
        },
      });
    } catch (error) {
      console.error('Get booking by code error:', error);
      res.status(500).json({
        error: 'Failed to fetch booking',
        details: error.message,
      });
    }
  }

  // Cancel booking
  static async cancelBooking(req, res) {
    try {
      const userId = req.user.userId;
      const { bookingId } = req.params;
      const { reason } = req.body;

      const booking = await BookingModel.findById(bookingId);
      if (!booking) {
        return res.status(404).json({ error: 'Booking not found' });
      }

      // Verify user owns this booking
      if (booking.user_id !== userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      // Check if booking can be cancelled
      const departureDate = new Date(booking.departure_date);
      if (departureDate < new Date()) {
        return res.status(400).json({ error: 'Cannot cancel past bookings' });
      }

      // Cancel booking
      const cancelledBooking = await BookingModel.cancelBooking(bookingId, reason || 'User cancelled');

      // Restore available seats
      const schedule = await ScheduleModel.findById(booking.schedule_id);
      if (schedule) {
        await ScheduleModel.incrementAvailableSeats(booking.schedule_id);
      }

      res.status(200).json({
        message: 'Booking cancelled successfully',
        booking: cancelledBooking,
      });
    } catch (error) {
      console.error('Cancel booking error:', error);
      res.status(500).json({
        error: 'Failed to cancel booking',
        details: error.message,
      });
    }
  }
}

module.exports = BookingController;
