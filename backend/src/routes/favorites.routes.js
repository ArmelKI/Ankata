const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const FavoriteModel = require('../models/Favorite');

const router = express.Router();

// Get user favorites
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const favorites = await FavoriteModel.findByUserId(userId);

    res.status(200).json({
      favorites,
      count: favorites.length
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({
      error: 'Failed to fetch favorites',
      details: error.message,
    });
  }
});

// Add favorite
router.post('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const { itemId, itemType, itemData } = req.body;

    if (!itemId || !itemType) {
      return res.status(400).json({ error: 'itemId and itemType are required' });
    }

    const favorite = await FavoriteModel.create({
      userId,
      itemId,
      itemType,
      itemData
    });

    res.status(201).json({
      message: 'Favorite added',
      favorite
    });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({
      error: 'Failed to add favorite',
      details: error.message,
    });
  }
});

// Remove favorite
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const favoriteId = req.params.id;

    // We try to delete by ID first, but if it fails or we want to delete by item info:
    const { itemId, itemType } = req.query;

    const favorite = await FavoriteModel.delete(userId, favoriteId || itemId, itemType);

    if (!favorite) {
      return res.status(404).json({ error: 'Favorite not found' });
    }

    res.status(200).json({
      message: 'Favorite removed',
      favorite
    });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({
      error: 'Failed to remove favorite',
      details: error.message,
    });
  }
});

module.exports = router;
