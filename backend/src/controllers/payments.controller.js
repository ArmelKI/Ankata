const BookingModel = require('../models/Booking');
const PaymentModel = require('../models/Payment');
const PaymentAggregator = require('../services/payment.aggregator');

class PaymentController {
  // Initiate payment (create payment record)
  static async initiatePayment(req, res) {
    try {
      const userId = req.user.userId;
      const {
        bookingId,
        paymentMethod, // 'ORANGE_MONEY', 'WAVE', 'MOOV_MONEY', 'CARD'
      } = req.body;

      if (!bookingId || !paymentMethod) {
        return res.status(400).json({
          error: 'bookingId and paymentMethod are required',
        });
      }

      const normalizedMethod = this._normalizePaymentMethod(paymentMethod);
      if (!normalizedMethod) {
        return res.status(400).json({
          error: 'Unsupported payment method. Use ORANGE_MONEY, WAVE, MOOV_MONEY, CARD',
        });
      }

      const booking = await BookingModel.findById(bookingId);
      if (!booking) {
        return res.status(404).json({ error: 'Booking not found' });
      }

      if (booking.user_id !== userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      // Create payment record
      const payment = await PaymentModel.create({
        bookingId,
        userId,
        amount: booking.total_amount,
        currency: 'XOF',
        paymentMethod: normalizedMethod,
        paymentGateway: this._getPaymentGateway(normalizedMethod),
        metadata: {
          bookingCode: booking.booking_code,
          passengerName: booking.passenger_name,
        },
      });

      // In a real scenario, you would redirect to payment gateway or return payment initiation data
      const aggregatorResponse = await PaymentAggregator.initializePayment({
        amount: booking.total_amount,
        currency: 'XOF',
        transactionId: payment.id,
        description: `Booking ${booking.booking_code}`,
        customerName: booking.passenger_name,
        customerPhone: booking.passenger_phone,
      });

      res.status(200).json({
        message: 'Payment initiated',
        payment: {
          id: payment.id,
          amount: payment.amount,
          currency: payment.currency,
          paymentMethod: payment.payment_method,
          status: payment.payment_status,
        },
        paymentData: {
          redirectUrl: aggregatorResponse.paymentUrl,
          paymentReference: aggregatorResponse.transactionId,
          amount: payment.amount,
          currency: payment.currency,
          bookingCode: booking.booking_code,
        },
      });
    } catch (error) {
      console.error('Initiate payment error:', error);
      res.status(500).json({
        error: 'Failed to initiate payment',
        details: error.message,
      });
    }
  }

  // Verify payment (webhook from payment gateway)
  static async verifyPayment(req, res) {
    try {
      const { paymentId } = req.params;
      const {
        transactionId,
        status, // 'success', 'failed', 'pending'
        errorMessage,
      } = req.body;

      const payment = await PaymentModel.findById(paymentId);
      if (!payment) {
        return res.status(404).json({ error: 'Payment not found' });
      }

      const normalizedStatus = this._normalizePaymentStatus(status);

      // Update payment status
      const updatedPayment = await PaymentModel.updateStatus(
        paymentId,
        normalizedStatus,
        transactionId,
        errorMessage
      );

      // If payment is successful, update booking payment status
      if (normalizedStatus === 'COMPLETED') {
        await BookingModel.updatePaymentStatus(
          payment.booking_id,
          'COMPLETED'
        );
        await BookingModel.updateBookingStatus(
          payment.booking_id,
          'COMPLETED'
        );
      } else if (normalizedStatus === 'FAILED') {
        await BookingModel.updatePaymentStatus(
          payment.booking_id,
          'FAILED'
        );
      }

      res.status(200).json({
        message: 'Payment verified',
        payment: updatedPayment,
      });
    } catch (error) {
      console.error('Verify payment error:', error);
      res.status(500).json({
        error: 'Failed to verify payment',
        details: error.message,
      });
    }
  }

  // Get payment details
  static async getPaymentDetails(req, res) {
    try {
      const userId = req.user.userId;
      const { paymentId } = req.params;

      const payment = await PaymentModel.findById(paymentId);
      if (!payment) {
        return res.status(404).json({ error: 'Payment not found' });
      }

      if (payment.user_id !== userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      res.status(200).json({
        payment,
      });
    } catch (error) {
      console.error('Get payment details error:', error);
      res.status(500).json({
        error: 'Failed to fetch payment details',
        details: error.message,
      });
    }
  }

  static _getPaymentGateway(paymentMethod) {
    const gateways = {
      ORANGE_MONEY: 'aggregator_om',
      WAVE: 'aggregator_wave',
      MOOV_MONEY: 'aggregator_moov',
      CARD: 'aggregator_card',
    };
    return gateways[paymentMethod] || 'aggregator_default';
  }

  static _normalizePaymentMethod(method) {
    if (!method || typeof method !== 'string') {
      return null;
    }
    const normalized = method.trim().toUpperCase();
    const mapping = {
      ORANGE_MONEY_BF: 'ORANGE_MONEY',
      ORANGE_MONEY: 'ORANGE_MONEY',
      WAVE: 'WAVE',
      MOOV_MONEY_BF: 'MOOV_MONEY',
      MOOV_MONEY: 'MOOV_MONEY',
      CARD: 'CARD',
    };
    return mapping[normalized] || null;
  }

  static _normalizePaymentStatus(status) {
    const normalized = String(status || '').trim().toLowerCase();
    if (normalized === 'success' || normalized === 'paid' || normalized === 'completed') {
      return 'COMPLETED';
    }
    if (normalized === 'failed' || normalized === 'error') {
      return 'FAILED';
    }
    if (normalized === 'cancelled' || normalized === 'canceled') {
      return 'CANCELLED';
    }
    return 'PENDING';
  }
}

module.exports = PaymentController;
