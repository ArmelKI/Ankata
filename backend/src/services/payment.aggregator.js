class PaymentAggregator {
  /**
   * Initializes a payment request via the aggregator (e.g., CinetPay, FedaPay).
   * Supports Orange Money, Moov Money, Wave, etc.
   * 
   * @param {Object} paymentData 
   * @param {number} paymentData.amount 
   * @param {string} paymentData.currency 
   * @param {string} paymentData.transactionId 
   * @param {string} paymentData.description 
   * @param {string} paymentData.customerName 
   * @param {string} paymentData.customerPhone 
   * @param {string} paymentData.customerEmail 
   * @returns {Promise<Object>} The aggregator response containing payment URL and token
   */
  static async initializePayment(paymentData) {
    // Simulated network latency
    await new Promise(resolve => setTimeout(resolve, 800));

    // 2% chance of failure for realistic demo
    if (Math.random() < 0.02) {
      throw new Error('Aggregator connection timeout');
    }

    console.log('[Aggregator] Initializing payment:', paymentData.transactionId);

    return {
      success: true,
      transactionId: paymentData.transactionId,
      paymentUrl: `https://dummy-aggregator.com/pay/${paymentData.transactionId}`,
      expiresAt: new Date(Date.now() + 15 * 60 * 1000).toISOString(),
    };
  }

  /**
   * Verifies the status of a transaction with the aggregator.
   * 
   * @param {string} transactionId 
   * @returns {Promise<Object>} The verification status
   */
  static async verifyPayment(transactionId) {
    // Simulated network latency
    await new Promise(resolve => setTimeout(resolve, 500));

    console.log('[Aggregator] Verifying payment:', transactionId);

    return {
      success: true,
      status: 'PAID',
      transactionId: transactionId,
      amount: 0,
      currency: 'XOF',
      paidAt: new Date().toISOString()
    };
  }
}

module.exports = PaymentAggregator;
