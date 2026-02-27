const pool = require('../config/db');

class PromoCodeModel {
  static async findByCode(code) {
    const query = 'SELECT * FROM promo_codes WHERE code = $1 AND is_active = TRUE';
    const result = await pool.query(query, [code.toUpperCase()]);
    return result.rows[0];
  }

  static async validate(code, userId, amount) {
    const promo = await this.findByCode(code);
    if (!promo) return { valid: false, error: 'Code promo invalide' };

    const now = new Date();
    if (promo.valid_from && now < new Date(promo.valid_from)) {
      return { valid: false, error: 'Ce code promo n\'est pas encore actif' };
    }
    if (promo.valid_until && now > new Date(promo.valid_until)) {
      return { valid: false, error: 'Ce code promo a expiré' };
    }

    if (promo.usage_limit && promo.usage_count >= promo.usage_limit) {
      return { valid: false, error: 'Limite d\'utilisation atteinte' };
    }

    if (amount < parseFloat(promo.min_purchase_amount)) {
      return { valid: false, error: `Montant minimum requis: ${promo.min_purchase_amount} FCFA` };
    }

    // Check if user already used it
    const usageQuery = 'SELECT id FROM promo_code_usage WHERE promo_code_id = $1 AND user_id = $2';
    const usageResult = await pool.query(usageQuery, [promo.id, userId]);
    if (usageResult.rows.length > 0) {
      return { valid: false, error: 'Vous avez déjà utilisé ce code promo' };
    }

    return { valid: true, promo };
  }

  static async incrementUsage(promoId) {
    const query = 'UPDATE promo_codes SET usage_count = usage_count + 1 WHERE id = $1';
    await pool.query(query, [promoId]);
  }

  static async recordUsage(promoId, userId, discountAmount, bookingId = null) {
    const query = `
      INSERT INTO promo_code_usage (promo_code_id, user_id, discount_applied, booking_id)
      VALUES ($1, $2, $3, $4)
    `;
    await pool.query(query, [promoId, userId, discountAmount, bookingId]);
  }
}

module.exports = PromoCodeModel;
