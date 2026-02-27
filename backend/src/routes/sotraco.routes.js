const express = require('express');
const router = express.Router();
const SotracoController = require('../controllers/sotraco.controller');

// SOTRACO routes are publicly accessible; optional auth is applied at app level

// Obtenir les arrêts les plus proches des coordonnées (lat, lng)
// GET /api/sotraco/stops/nearest
router.get('/stops/nearest', SotracoController.getNearestStops);

// Obtenir les lignes (bus) passant par un arrêt précis
// GET /api/sotraco/stops/:stopId/lines
router.get('/stops/:stopId/lines', SotracoController.getLinesForStop);

module.exports = router;
