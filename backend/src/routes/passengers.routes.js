const express = require('express');
const PassengersController = require('../controllers/passengers.controller');
const { verifyToken } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/', verifyToken, PassengersController.getPassengers);
router.post('/', verifyToken, PassengersController.createPassenger);
router.put('/:id', verifyToken, PassengersController.updatePassenger);
router.delete('/:id', verifyToken, PassengersController.deletePassenger);

module.exports = router;
