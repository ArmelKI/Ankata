const pool = require('../database/connection');

class FavoriteModel {
  static async create(data) {
    const { userId, itemId, itemType, itemData } = data;
    const query = `
      INSERT INTO favorites (user_id, item_id, item_type, item_data)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (user_id, item_id, item_type) DO UPDATE SET item_data = $4
      RETURNING *;
    `;
    const result = await pool.query(query, [userId, itemId, itemType, itemData]);
    return result.rows[0];
  }

  static async findByUserId(userId) {
    const query = 'SELECT * FROM favorites WHERE user_id = $1 ORDER BY created_at DESC';
    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async delete(userId, itemId, itemType) {
    let query;
    let params;

    if (itemId && itemType) {
      query = 'DELETE FROM favorites WHERE user_id = $1 AND item_id = $2 AND item_type = $3 RETURNING *';
      params = [userId, itemId, itemType];
    } else {
      // If we just have an ID from params
      query = 'DELETE FROM favorites WHERE user_id = $1 AND id = $2 RETURNING *';
      params = [userId, itemId];
    }

    const result = await pool.query(query, params);
    return result.rows[0] || null;
  }

  static async isFavorite(userId, itemId, itemType) {
    const query = 'SELECT COUNT(*) FROM favorites WHERE user_id = $1 AND item_id = $2 AND item_type = $3';
    const result = await pool.query(query, [userId, itemId, itemType]);
    return parseInt(result.rows[0].count, 10) > 0;
  }
}

module.exports = FavoriteModel;
