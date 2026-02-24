const pool = require('../database/connection');

class SotracoController {
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

      // Requête SQL utilisant la formule de Haversine
      // Multiplie par 6371 (rayon de la Terre en km) pour obtenir la distance en km
      const query = `
        SELECT 
          id, stop_name, city, address, latitude, longitude, stop_type,
          (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) AS distance
        FROM stops
        WHERE stop_type = 'URBAIN'
        HAVING (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) < $3
        ORDER BY distance ASC
        LIMIT 10;
      `;

      // NOTE: Standard PostgreSQL ne permet pas HAVING sur un alias sélectionné sans GROUP BY.
      // Une CTE (Common Table Expression) ou une sous-requête est préférable.
      const safeQuery = `
        SELECT * FROM (
          SELECT 
            id, stop_name, city, address, latitude, longitude, stop_type,
            (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) AS distance
          FROM stops
          WHERE stop_type = 'URBAIN'
        ) sub
        WHERE distance < $3
        ORDER BY distance ASC
        LIMIT 10;
      `;

      const result = await pool.query(safeQuery, [latitude, longitude, searchRadius]);

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

      const query = `
        SELECT 
          l.id, l.line_code, l.line_name, l.origin_city, l.destination_city, l.base_price,
          ls.stop_sequence
        FROM line_stops ls
        JOIN lines l ON ls.line_id = l.id
        WHERE ls.stop_id = $1 AND l.line_type = 'URBAIN' AND l.is_active = true
        ORDER BY l.line_name ASC;
      `;

      const result = await pool.query(query, [stopId]);

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
