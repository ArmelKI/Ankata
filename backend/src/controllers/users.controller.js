const UserModel = require('../models/User');
const supabase = require('../config/supabase');

const getSignedAvatarUrl = async (avatarPath) => {
  if (!avatarPath) return null;
  if (avatarPath.startsWith('http')) return avatarPath;

  const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'avatars';
  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(avatarPath, 60 * 60 * 24 * 7);

  if (error || !data?.signedUrl) return null;
  return data.signedUrl;
};

class UsersController {
  static async updateUser(req, res) {
    try {
      const userId = req.user.userId;
      const { id } = req.params;

      if (userId !== id) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      const {
        firstName,
        lastName,
        dateOfBirth,
        cnib,
        gender,
        city,
      } = req.body;

      const updatedUser = await UserModel.update(userId, {
        first_name: firstName,
        last_name: lastName,
        date_of_birth: dateOfBirth,
        cnib,
        gender,
        city,
      });

      if (!updatedUser) {
        return res.status(400).json({ error: 'Aucune modification valide' });
      }

      const signedAvatarUrl = await getSignedAvatarUrl(
        updatedUser.profile_picture_url
      );

      res.status(200).json({
        message: 'Profil mis a jour',
        user: {
          id: updatedUser.id,
          phoneNumber: updatedUser.phone_number,
          firstName: updatedUser.first_name,
          lastName: updatedUser.last_name,
          dateOfBirth: updatedUser.date_of_birth,
          cnib: updatedUser.cnib,
          gender: updatedUser.gender,
          city: updatedUser.city,
          profilePictureUrl:
            signedAvatarUrl || updatedUser.profile_picture_url,
        },
      });
    } catch (error) {
      console.error('Update user error:', error);
      res.status(500).json({
        error: 'Erreur mise a jour profil',
        details: error.message,
      });
    }
  }
}

module.exports = UsersController;
