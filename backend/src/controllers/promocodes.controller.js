const PromoCodeModel = require('../models/PromoCode');

class PromoCodesController {
  static async validatePromo(req, res) {
    try {
      const { code, amount } = req.body;
      const userId = req.userId;

      if (!code || !amount) {
        return res.status(400).json({ error: 'Code et montant sont requis' });
      }

      const validation = await PromoCodeModel.validate(code, userId, amount);
      if (!validation.valid) {
        return res.status(400).json({ error: validation.error });
      }

      const { promo } = validation;
      let discountAmount = 0;

      if (promo.discount_type === 'percentage') {
        discountAmount = (amount * promo.discount_value) / 100;
        if (promo.max_discount_amount && discountAmount > promo.max_discount_amount) {
          discountAmount = promo.max_discount_amount;
        }
      } else {
        discountAmount = promo.discount_value;
      }

      res.status(200).json({
        valid: true,
        discountAmount,
        discountType: promo.discount_type,
        discountValue: promo.discount_value,
        promoCodeId: promo.id,
      });
    } catch (error) {
      console.error('Validate promo error:', error);
      res.status(500).json({ error: 'Erreur lors de la validation du code promo' });
    }
  }
}

module.exports = PromoCodesController;
