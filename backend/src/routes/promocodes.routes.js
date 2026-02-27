const express = require('express');
const PromoCodesController = require('../controllers/promocodes.controller');
const { verifyToken } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/validate', verifyToken, PromoCodesController.validatePromo);

module.exports = router;
