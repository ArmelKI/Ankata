import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/favorites_service.dart';
import '../../widgets/referral_dialog.dart';
import '../../widgets/company_logo.dart';
import '../../widgets/edit_profile_dialog.dart';
import '../../utils/haptic_helper.dart';
import '../../providers/app_providers.dart';
import '../../config/constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _smsEnabled = true;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final box = Hive.box('user_profile');
    if (!mounted) return;
    setState(() => _photoPath = box.get('avatarUrl'));
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      if (!mounted) return;

      // Update local optimistically
      setState(() => _photoPath = image.path);

      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.uploadProfilePicture(image.path);

      if (response['profilePictureUrl'] != null) {
        final serverUrl = response['profilePictureUrl'];
        final box = Hive.box('user_profile');
        await box.put('avatarUrl', serverUrl);

        // Update user provider
        final currentUser = ref.read(currentUserProvider);
        if (currentUser != null) {
          final updatedUser = Map<String, dynamic>.from(currentUser);
          updatedUser['profilePictureUrl'] = serverUrl;
          ref.read(currentUserProvider.notifier).state = updatedUser;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo de profil mise à jour'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('Profil', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildPersonalInfoSection(),
            const SizedBox(height: AppSpacing.md),
            _buildReferralSection(), // Referral (100F par ami, max 15)
            const SizedBox(height: AppSpacing.md),
            _buildNotificationsSection(),
            const SizedBox(height: AppSpacing.md),
            _buildPreferencesSection(),
            const SizedBox(height: AppSpacing.md),
            _buildFavoritesSection(),
            const SizedBox(height: AppSpacing.md),
            _buildSupportSection(),
            const SizedBox(height: AppSpacing.md),
            _buildAboutSection(),
            const SizedBox(height: AppSpacing.md),
            _buildLogoutButton(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = ref.watch(currentUserProvider);
    final firstName =
        user?['firstName'] ?? user?['first_name'] ?? 'Utilisateur';
    final lastName = user?['lastName'] ?? user?['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final phone = user?['phoneNumber'] ?? user?['phone_number'] ?? '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.white,
      child: Column(
        children: [
          // User Avatar
          Stack(
            children: [
              UserAvatar(
                name: fullName,
                size: 100,
                imageUrl: user?['profilePictureUrl'] ??
                    user?['profile_picture_url'] ??
                    _photoPath,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    HapticHelper.lightImpact();
                    _pickPhoto();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            fullName,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            phone,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () {
              HapticHelper.lightImpact();
              _showEditProfileDialog();
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Modifier le profil'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    final user = ref.watch(currentUserProvider);
    final cnib = user?['cnib'] as String? ?? 'Non renseigne';
    final gender = user?['gender'] as String? ?? 'Non renseigne';
    final dob =
        user?['dateOfBirth'] as String? ?? user?['date_of_birth'] as String?;
    final dobDisplay =
        dob != null && dob.isNotEmpty ? dob.split('T').first : 'Non renseignee';
    final email = user?['email'] as String? ?? 'Non renseigne';

    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informations personnelles',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticHelper.lightImpact();
                    _showEditProfileDialog();
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                ),
              ],
            ),
          ),
          _buildListItem(
              Icons.badge,
              'Numero CNIB',
              cnib.isEmpty ? 'Non renseigne' : cnib,
              () => _showEditProfileDialog()),
          const Divider(height: 1),
          _buildListItem(
              Icons.person,
              'Sexe',
              gender.isEmpty ? 'Non renseigne' : gender,
              () => _showEditProfileDialog()),
          const Divider(height: 1),
          _buildListItem(Icons.calendar_today, 'Date de naissance', dobDisplay,
              () => _showEditProfileDialog()),
          const Divider(height: 1),
          _buildListItem(
              Icons.email,
              'Email',
              email.isEmpty ? 'Non renseigne' : email,
              () => _showEditProfileDialog()),
        ],
      ),
    );
  }

  // Section Referral
  Widget _buildReferralSection() {
    final user = ref.watch(currentUserProvider);
    final referralCode = user?['referralCode'] as String? ??
        user?['referral_code'] as String? ??
        'CODE?';
    final walletBalance =
        user?['walletBalance'] as int? ?? user?['wallet_balance'] as int? ?? 0;

    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Parrainage',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (walletBalance > 0)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Solde bonus: $walletBalance FCFA',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          _buildListItem(
            Icons.card_giftcard,
            'Parrainer un ami',
            'Ton ami s\'inscrit avec ton code => tu gagnes 100F !\nTon code: $referralCode',
            () {
              HapticHelper.lightImpact();
              ReferralDialog.show(context, referralCode: referralCode);
            },
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '+100F',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Notifications',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildSwitchItem(
            Icons.notifications,
            'Notifications push',
            'Recevoir des notifications sur l\'application',
            _notificationsEnabled,
            (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          const Divider(height: 1),
          _buildSwitchItem(
            Icons.sms,
            'Notifications SMS',
            'Recevoir des SMS pour vos réservations',
            _smsEnabled,
            (value) {
              setState(() => _smsEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final isDarkMode = ref.watch(darkModeProvider);

    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Préférences',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildListItem(
            Icons.language,
            'Langue',
            'Français',
            () {
              _showLanguageDialog();
            },
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.dark_mode,
            'Thème',
            isDarkMode ? 'Sombre' : 'Clair',
            () {
              _showThemeDialog();
            },
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.location_on,
            'Localisation par défaut',
            'Ouagadougou',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Favoris',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FavoritesService.getFavorites(),
            builder: (context, snapshot) {
              final favorites = snapshot.data ?? [];
              if (favorites.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Aucun trajet favori pour le moment.',
                    style:
                        AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
                  ),
                );
              }
              return Column(
                children: favorites.map((item) {
                  final from = item['from'] ?? '';
                  final to = item['to'] ?? '';
                  final company = item['company'] ?? '';
                  return ListTile(
                    leading: const Icon(Icons.star, color: AppColors.star),
                    title: Text('$from → $to', style: AppTextStyles.bodyMedium),
                    subtitle: Text(company,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.gray)),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Assistance',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildListItem(
            Icons.help,
            'Centre d\'aide',
            'FAQ et guides',
            () => context.push('/faq'),
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.message,
            'Contacter le support',
            'Nous sommes là pour vous aider',
            () {
              _showContactDialog();
            },
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.feedback,
            'Envoyer un feedback',
            'Aidez-nous à améliorer l\'application',
            () => context.push('/feedback'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'À propos',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildListItem(
            Icons.description,
            'Conditions générales',
            'Conditions d\'utilisation',
            () => context.push('/legal/terms'),
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.privacy_tip,
            'Politique de confidentialité',
            'Protection de vos données',
            () => context.push('/legal/privacy'),
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.info,
            'Version',
            '1.0.0 (Build 1)',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    Widget? trailing, // NOUVEAU: trailing custom optionnel
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.radiusSm,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.gray)
              : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.radiusSm,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            _showLogoutDialog();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final user = ref.read(currentUserProvider);
    final apiService = ref.read(apiServiceProvider);

    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        currentUser: user ?? {},
        onSave: (updatedData) async {
          try {
            if (!mounted) return;

            // Show loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mise à jour en cours...'),
                duration: Duration(seconds: 5),
              ),
            );

            // Call API
            final userId = user?['id'] ?? user?['userId'] ?? '';
            await apiService.updateUserProfile(userId, updatedData);

            // Update local provider
            if (mounted) {
              ref.read(currentUserProvider.notifier).state = {
                ...?user,
                ...updatedData,
              };

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil mis à jour avec succès'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'fr',
              groupValue: 'fr',
              onChanged: (value) {
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
            ),
            const RadioListTile<String>(
              title: Text('English (à venir)'),
              value: 'en',
              groupValue: 'fr',
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    final isDarkMode = ref.watch(darkModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Clair'),
              value: false,
              groupValue: isDarkMode,
              onChanged: (value) {
                if (value == null) return;
                ref.read(darkModeProvider.notifier).state = value;
                Hive.box('user_profile').put('darkMode', value);
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
            ),
            RadioListTile<bool>(
              title: const Text('Sombre'),
              value: true,
              groupValue: isDarkMode,
              onChanged: (value) {
                if (value == null) return;
                ref.read(darkModeProvider.notifier).state = value;
                Hive.box('user_profile').put('darkMode', value);
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactOption(Icons.phone, '+226 25 12 34 56'),
            const SizedBox(height: AppSpacing.md),
            _buildContactOption(Icons.email, 'support@ankata.bf'),
            const SizedBox(height: AppSpacing.md),
            _buildContactOption(Icons.chat, '+226 70 12 34 56'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implémenter la déconnexion : vider le token et le cache local
              try {
                await ref.read(apiServiceProvider).clearToken();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (context.mounted) {
                  context.go('/phone-auth');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la déconnexion')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
