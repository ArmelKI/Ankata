const PriceAlert = require('../models/PriceAlert');

exports.createAlert = async (req, res) => {
    try {
        const { originCity, destinationCity, targetPrice } = req.body;
        const alert = await PriceAlert.create({
            userId: req.user.id,
            originCity,
            destinationCity,
            targetPrice
        });
        res.status(201).json(alert);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la création de l\'alerte', error: error.message });
    }
};

exports.getAlerts = async (req, res) => {
    try {
        const alerts = await PriceAlert.findByUserId(req.user.id);
        res.json(alerts);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la récupération des alertes', error: error.message });
    }
};

exports.deleteAlert = async (req, res) => {
    try {
        const alert = await PriceAlert.delete(req.params.id, req.user.id);
        if (!alert) return res.status(440).json({ message: 'Alerte non trouvée' });
        res.json({ message: 'Alerte supprimée' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la suppression de l\'alerte', error: error.message });
    }
};

exports.toggleAlert = async (req, res) => {
    try {
        const alert = await PriceAlert.toggleActive(req.params.id, req.user.id);
        if (!alert) return res.status(440).json({ message: 'Alerte non trouvée' });
        res.json(alert);
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de la modification de l\'alerte', error: error.message });
    }
};
