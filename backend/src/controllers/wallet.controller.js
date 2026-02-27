const TransactionModel = require('../models/Transaction');
const UserModel = require('../models/User');

class WalletController {
  static async getTransactions(req, res) {
    try {
      const userId = req.user.userId;
      const { limit, offset } = req.query;
      
      const transactions = await TransactionModel.findByUserId(
        userId, 
        parseInt(limit) || 50, 
        parseInt(offset) || 0
      );
      
      const user = await UserModel.findById(userId);

      res.status(200).json({
        balance: user.wallet_balance || 0,
        xp: user.xp || 0,
        level: user.level || 'Bronze',
        transactions
      });
    } catch (error) {
      console.error('Get transactions error:', error);
      res.status(500).json({ error: 'Failed to fetch transaction history' });
    }
  }
}

module.exports = WalletController;
