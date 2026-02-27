const BookingModel = require('../models/Booking');
const PaymentModel = require('../models/Payment');
const UserModel = require('../models/User');
const TransactionModel = require('../models/Transaction');
const PaymentAggregator = require('../services/payment.aggregator');

class PaymentController {
  // Initiate payment (create payment record)
  static async initiatePayment(req, res) {
    try {
      const userId = req.user.userId;
      const {
        bookingId,
        paymentMethod, // 'orange_money', 'moov_money', 'card'
      } = req.body;

      if (!bookingId || !paymentMethod) {
        return res.status(400).json({
          error: 'bookingId and paymentMethod are required',
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
        paymentMethod,
        paymentGateway: this._getPaymentGateway(paymentMethod),
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
          status: payment.status,
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

      // Update payment status
      const updatedPayment = await PaymentModel.updateStatus(
        paymentId,
        status,
        transactionId,
        errorMessage
      );

      // If payment is successful, update booking payment status
      if (status === 'success') {
        await BookingModel.updatePaymentStatus(
          payment.booking_id,
          'completed'
        );

        // Reward XP to the user
        // 100 XP per booking + bonus based on amount?
        // Let's keep it simple: 100 XP per travel
        const booking = await BookingModel.findById(payment.booking_id);
        if (booking && booking.user_id) {
          await UserModel.addXP(booking.user_id, 100);
          
          // Record transaction
          await TransactionModel.create({
            userId: booking.user_id,
            amount: booking.total_price || payment.amount,
            type: 'payment',
            description: `Paiement billet ${booking.booking_code || ''}`,
            status: 'completed'
          });
        }
      } else if (status === 'failed') {
        await BookingModel.updatePaymentStatus(
          payment.booking_id,
          'failed'
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
      orange_money_bf: 'aggregator_om',
      moov_money_bf: 'aggregator_moov',
      card: 'aggregator_card',
    };
    return gateways[paymentMethod] || 'aggregator_default';
  }
}

module.exports = PaymentController;
