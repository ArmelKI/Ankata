const express = require('express');
const multer = require('multer');
const path = require('path');
const { authMiddleware } = require('../middleware/auth');
const pool = require('../database/connection');
const supabase = require('../config/supabase');
const UserModel = require('../models/User');

const router = express.Router();

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Le fichier doit être une image'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: fileFilter
});

router.post('/profile-picture', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucune image uploadée' });
    }

    const userId = req.user.userId;
    const user = await UserModel.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'avatars';
    const phone = (user.phone_number || '').replace(/\s+/g, '');
    const fileExt = path.extname(req.file.originalname) || '.jpg';
    const objectPath = `${phone || userId}${fileExt}`;

    const { error: uploadError } = await supabase.storage
      .from(bucket)
      .upload(objectPath, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true,
      });

    if (uploadError) {
      return res.status(500).json({
        error: 'Erreur lors de l\'upload Supabase',
        details: uploadError.message,
      });
    }

    const { data: signedData, error: signedError } = await supabase.storage
      .from(bucket)
      .createSignedUrl(objectPath, 60 * 60 * 24 * 7);

    if (signedError || !signedData?.signedUrl) {
      return res.status(500).json({
        error: 'Erreur lors de la génération du lien signé',
        details: signedError?.message,
      });
    }
    
    // Update user profile in database
    const query = `
      UPDATE users 
      SET profile_picture_url = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING *;
    `;

    const result = await pool.query(query, [objectPath, userId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    res.status(200).json({
      message: 'Photo de profil mise à jour',
      profilePictureUrl: signedData.signedUrl,
      avatarPath: objectPath,
    });
  } catch (error) {
    console.error('Error uploading profile picture:', error);
    res.status(500).json({
      error: 'Erreur lors de la mise à jour de la photo de profil',
      details: error.message
    });
  }
});

module.exports = router;
