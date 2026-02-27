const pool = require('../database/connection');

class SotracoController {
  static async _tableExists(tableName) {
    const query = `
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = $1
      LIMIT 1;
    `;
    const result = await pool.query(query, [tableName]);
    return result.rowCount > 0;
  }

  /**
   * Rechercher les arrêts les plus proches d'une coordonnée GPS existante
   * Utilisant la formule de Haversine pour une recherche par rayon
   */
  static async getNearestStops(req, res) {
    try {
      const { lat, lng, radius = 2.0 } = req.query; // rayon par défaut = 2km
      
      if (!lat || !lng) {
        return res.status(400).json({ error: 'lat et lng sont requis' });
      }

      const latitude = parseFloat(lat);
      const longitude = parseFloat(lng);
      const searchRadius = parseFloat(radius);

      const hasStopsTable = await SotracoController._tableExists('stops');
      if (!hasStopsTable) {
        return res.status(200).json({
          stops: [],
          warning: 'stops table missing',
        });
      }

      // NOTE: Standard PostgreSQL ne permet pas HAVING sur un alias sélectionné sans GROUP BY.
      // Une CTE (Common Table Expression) ou une sous-requête est préférable.
      const buildQuery = (includeStopType) => `
        SELECT * FROM (
          SELECT 
            id, stop_name, city, address, latitude, longitude${includeStopType ? ', stop_type' : ''},
            (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) AS distance
          FROM stops
          ${includeStopType ? "WHERE stop_type = 'URBAIN'" : ''}
        ) sub
        WHERE distance < $3
        ORDER BY distance ASC
        LIMIT 10;
      `;

      let result;
      try {
        result = await pool.query(buildQuery(true), [latitude, longitude, searchRadius]);
      } catch (error) {
        if (error.code === '42703' || /stop_type/i.test(error.message)) {
          result = await pool.query(buildQuery(false), [latitude, longitude, searchRadius]);
        } else {
          throw error;
        }
      }

      res.status(200).json({
        stops: result.rows
      });
    } catch (error) {
      console.error('Erreur getNearestStops:', error);
      res.status(500).json({ error: 'Erreur lors de la recherche des arrêts proches', details: error.message });
    }
  }

  /**
   * Récupérer toutes les lignes (trajets) associées à un arrêt
   */
  static async getLinesForStop(req, res) {
    try {
      const { stopId } = req.params;

      const hasLineStopsTable = await SotracoController._tableExists('line_stops');
      if (!hasLineStopsTable) {
        return res.status(200).json({
          lines: [],
          warning: 'line_stops table missing',
        });
      }

      const query = `
        SELECT 
          l.id, l.line_code, l.line_name, l.origin_city, l.destination_city, l.base_price,
          ls.stop_sequence
        FROM line_stops ls
        JOIN lines l ON ls.line_id = l.id
        WHERE ls.stop_id = $1 AND l.line_type = 'URBAIN' AND l.is_active = true
        ORDER BY l.line_name ASC;
      `;

      let result;
      try {
        result = await pool.query(query, [stopId]);
      } catch (error) {
        if (error.code === '42P01' || /line_stops/i.test(error.message)) {
          return res.status(200).json({
            lines: [],
            warning: 'line_stops table missing',
          });
        }
        throw error;
      }

      res.status(200).json({
        lines: result.rows
      });
    } catch (error) {
      console.error('Erreur getLinesForStop:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération des lignes', details: error.message });
    }
  }
}

module.exports = SotracoController;
