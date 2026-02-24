const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const SotracoController = require('../controllers/sotraco.controller');

// Toutes les requêtes SOTRACO nécessitent une authentification
router.use(authMiddleware);

// Obtenir les arrêts les plus proches des coordonnées (lat, lng)
// GET /api/sotraco/stops/nearest
router.get('/stops/nearest', SotracoController.getNearestStops);

// Obtenir les lignes (bus) passant par un arrêt précis
// GET /api/sotraco/stops/:stopId/lines
router.get('/stops/:stopId/lines', SotracoController.getLinesForStop);

module.exports = router;
