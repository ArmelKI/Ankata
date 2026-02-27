const PassengerModel = require('../models/Passenger');

class PassengersController {
  static async getPassengers(req, res) {
    try {
      const userId = req.userId;
      const passengers = await PassengerModel.findByUserId(userId);
      res.status(200).json({ passengers });
    } catch (error) {
      console.error('Get passengers error:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération des passagers' });
    }
  }

  static async createPassenger(req, res) {
    try {
      const userId = req.userId;
      const { firstName, lastName, phoneNumber, idType, idNumber } = req.body;

      if (!firstName || !lastName) {
        return res.status(400).json({ error: 'Prénom et nom sont obligatoires' });
      }

      const passenger = await PassengerModel.create({
        userId,
        firstName,
        lastName,
        phoneNumber,
        idType,
        idNumber,
      });

      res.status(201).json({
        message: 'Passager enregistré avec succès',
        passenger,
      });
    } catch (error) {
      console.error('Create passenger error:', error);
      res.status(500).json({ error: 'Erreur lors de la création du passager' });
    }
  }

  static async updatePassenger(req, res) {
    try {
      const userId = req.userId;
      const { id } = req.params;
      const { firstName, lastName, phoneNumber, idType, idNumber } = req.body;

      // Verify ownership
      const existing = await PassengerModel.findById(id);
      if (!existing || existing.user_id !== userId) {
        return res.status(404).json({ error: 'Passager non trouvé' });
      }

      const updated = await PassengerModel.update(id, {
        first_name: firstName,
        last_name: lastName,
        phone_number: phoneNumber,
        id_type: idType,
        id_number: idNumber,
      });

      res.status(200).json({
        message: 'Passager mis à jour',
        passenger: updated,
      });
    } catch (error) {
      console.error('Update passenger error:', error);
      res.status(500).json({ error: 'Erreur lors de la mise à jour du passager' });
    }
  }

  static async deletePassenger(req, res) {
    try {
      const userId = req.userId;
      const { id } = req.params;

      // Verify ownership
      const existing = await PassengerModel.findById(id);
      if (!existing || existing.user_id !== userId) {
        return res.status(404).json({ error: 'Passager non trouvé' });
      }

      await PassengerModel.delete(id);
      res.status(200).json({ message: 'Passager supprimé' });
    } catch (error) {
      console.error('Delete passenger error:', error);
      res.status(500).json({ error: 'Erreur lors de la suppression du passager' });
    }
  }
}

module.exports = PassengersController;
