const express = require('express');
const router = express.Router();
const priceAlertController = require('../controllers/price_alerts.controller');
const { verifyToken } = require('../middleware/auth.middleware');

router.use(verifyToken);

router.post('/', priceAlertController.createAlert);
router.get('/', priceAlertController.getAlerts);
router.delete('/:id', priceAlertController.deleteAlert);
router.patch('/:id/toggle', priceAlertController.toggleAlert);

module.exports = router;
