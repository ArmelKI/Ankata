const pool = require('../database/connection');

class PriceAlert {
    static async create(data) {
        const { userId, originCity, destinationCity, targetPrice } = data;
        const query = `
            INSERT INTO price_alerts (user_id, origin_city, destination_city, target_price)
            VALUES ($1, $2, $3, $4)
            RETURNING *;
        `;
        const values = [userId, originCity, destinationCity, targetPrice];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }

    static async findByUserId(userId) {
        const query = 'SELECT * FROM price_alerts WHERE user_id = $1 ORDER BY created_at DESC';
        const { rows } = await pool.query(query, [userId]);
        return rows;
    }

    static async delete(id, userId) {
        const query = 'DELETE FROM price_alerts WHERE id = $1 AND user_id = $2 RETURNING *';
        const { rows } = await pool.query(query, [id, userId]);
        return rows[0];
    }

    static async toggleActive(id, userId) {
        const query = `
            UPDATE price_alerts 
            SET is_active = NOT is_active, updated_at = CURRENT_TIMESTAMP 
            WHERE id = $1 AND user_id = $2 
            RETURNING *;
        `;
        const { rows } = await pool.query(query, [id, userId]);
        return rows[0];
    }
}

module.exports = PriceAlert;
