import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/favorites_service.dart';
import '../../widgets/company_logo.dart';
import '../../widgets/edit_profile_dialog.dart';
import '../../utils/haptic_helper.dart';
import '../../providers/app_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _smsEnabled = true;
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final bioService = ref.read(biometricServiceProvider);
    final available = await bioService.isAvailable();
    final enabled = await bioService.isEnabled();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
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
      setState(() => _photoPath = image.path);

      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.uploadProfilePicture(image.path);

      if (response['profilePictureUrl'] != null) {
        final serverUrl = response['profilePictureUrl'];
        final box = Hive.box('user_profile');
        await box.put('avatarUrl', serverUrl);

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
            _buildGamificationCard(),
            const SizedBox(height: AppSpacing.md),
            _buildPersonalInfoSection(),
            const SizedBox(height: AppSpacing.md),
            _buildPassengersSection(),
            const SizedBox(height: AppSpacing.md),
            _buildReferralSection(),
            const SizedBox(height: AppSpacing.md),
            _buildNotificationsSection(),
            const SizedBox(height: AppSpacing.md),
            _buildSupportSection(),
            const SizedBox(height: AppSpacing.md),
            _buildPreferencesSection(),
            const SizedBox(height: AppSpacing.md),
            _buildFavoritesSection(),
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
          Text(fullName, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(phone,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray)),
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
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard() {
    final user = ref.watch(currentUserProvider);
    final xp = (user?['xp'] as num?)?.toInt() ?? 0;
    final level = user?['level'] as String? ?? 'Bronze';

    String nextLevel = 'Silver';
    double progress = xp / 500;

    if (level == 'Silver') {
      nextLevel = 'Gold';
      progress = (xp - 500) / (2000 - 500);
    } else if (level == 'Gold') {
      nextLevel = 'Platinum';
      progress = (xp - 2000) / (5000 - 2000);
    } else if (level == 'Platinum') {
      nextLevel = 'Diamant';
      progress = (xp - 5000) / 5000;
    }

    if (progress > 1.0) progress = 1.0;
    if (progress < 0) progress = 0;

    Color levelColor = Colors.orange.shade700;
    if (level == 'Silver') levelColor = Colors.grey.shade400;
    if (level == 'Gold') levelColor = Colors.amber;
    if (level == 'Platinum') levelColor = const Color(0xFFE5E4E2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor.withOpacity(0.8), levelColor.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stars, color: levelColor, size: 28),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(level.toUpperCase(),
                          style: AppTextStyles.h4.copyWith(
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.bold)),
                      Text('$xp XP cumulés',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.charcoal.withOpacity(0.7))),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/wallet/transactions'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: AppRadius.radiusFull),
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 14),
                      const SizedBox(width: 4),
                      Text('Historique', style: AppTextStyles.overline),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Niveau Actuel',
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.charcoal)),
              Text('Prochain: $nextLevel',
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.charcoal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    final user = ref.watch(currentUserProvider);
    final cnib = user?['cnib'] as String? ?? 'Non renseigné';
    final gender = user?['gender'] as String? ?? 'Non renseigné';
    final dob =
        user?['dateOfBirth'] as String? ?? user?['date_of_birth'] as String?;
    final dobDisplay =
        dob != null && dob.isNotEmpty ? dob.split('T').first : 'Non renseignée';
    final email = user?['email'] as String? ?? 'Non renseigné';

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
                Text('Informations personnelles',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
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
              Icons.badge, 'Numéro CNIB', cnib, () => _showEditProfileDialog()),
          const Divider(height: 1),
          _buildListItem(
              Icons.person, 'Sexe', gender, () => _showEditProfileDialog()),
          const Divider(height: 1),
          _buildListItem(Icons.calendar_today, 'Date de naissance', dobDisplay,
              () => _showEditProfileDialog()),
          const Divider(height: 1),
          _buildListItem(
              Icons.email, 'Email', email, () => _showEditProfileDialog()),
        ],
      ),
    );
  }

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
            child: Text('Parrainage',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          if (walletBalance > 0)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSm),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text('Solde bonus: $walletBalance FCFA',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
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
              context.push('/profile/referral');
            },
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200)),
              child: Text('+100F',
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
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
            child: Text('Notifications',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          _buildSwitchItem(
              Icons.notifications,
              'Notifications push',
              'Recevoir des notifications sur l\'application',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value)),
          const Divider(height: 1),
          _buildSwitchItem(
              Icons.sms,
              'Notifications SMS',
              'Recevoir des SMS pour vos réservations',
              _smsEnabled,
              (value) => setState(() => _smsEnabled = value)),
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
            child: Text('Préférences',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          _buildListItem(
              Icons.language,
              'Langue',
              'Modifier la langue de l\'application',
              () => _showLanguageDialog()),
          const Divider(height: 1),
          _buildListItem(Icons.dark_mode, 'Thème',
              isDarkMode ? 'Sombre' : 'Clair', () => _showThemeDialog()),
          const Divider(height: 1),
          _buildListItem(Icons.location_on, 'Localisation par défaut',
              'Ouagadougou', () {}),
          if (_isBiometricAvailable) ...[
            const Divider(height: 1),
            _buildSwitchItem(
              Icons.fingerprint,
              'Authentification biométrique',
              'Sécuriser les actions sensibles',
              _biometricEnabled,
              (value) async {
                final bioService = ref.read(biometricServiceProvider);
                if (value) {
                  final authenticated = await bioService.authenticate();
                  if (authenticated) {
                    await bioService.setEnabled(true);
                    setState(() => _biometricEnabled = true);
                  }
                } else {
                  await bioService.setEnabled(false);
                  setState(() => _biometricEnabled = false);
                }
              },
            ),
          ],
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
            child: Text('Favoris',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FavoritesService.getFavorites(),
            builder: (context, snapshot) {
              final favorites = snapshot.data ?? [];
              if (favorites.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('Aucun trajet favori pour le moment.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray)),
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
            child: Text('Assistance & Feedback',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          _buildListItem(Icons.help_outline, 'Centre d\'aide', 'FAQ et guides',
              () => context.push('/faq')),
          const Divider(height: 1),
          _buildListItem(Icons.support_agent_outlined, 'Contacter le support',
              'Parler à un de nos agents', () => _showContactDialog()),
          const Divider(height: 1),
          _buildListItem(
              Icons.feedback_outlined,
              'Envoyer un feedback',
              'Signalez un bug ou suggérez une idée',
              () => context.push('/feedback')),
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
            child: Text('À propos',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          _buildListItem(Icons.description, 'Conditions générales',
              'Conditions d\'utilisation', () => context.push('/legal/terms')),
          const Divider(height: 1),
          _buildListItem(
              Icons.privacy_tip,
              'Politique de confidentialité',
              'Protection de vos données',
              () => context.push('/legal/privacy')),
          const Divider(height: 1),
          _buildListItem(Icons.info, 'Version', '1.0.0 (Build 1)', null),
        ],
      ),
    );
  }

  Widget _buildListItem(
      IconData icon, String title, String subtitle, VoidCallback? onTap,
      {Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppRadius.radiusSm),
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

  Widget _buildSwitchItem(IconData icon, String title, String subtitle,
      bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppRadius.radiusSm),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray)),
      trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(),
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Mise à jour en cours...'),
                duration: Duration(seconds: 2)));
            final userId = user?['id'] ?? user?['userId'] ?? '';
            await apiService.updateUserProfile(userId, updatedData);
            if (mounted) {
              ref.read(currentUserProvider.notifier).state = {
                ...?user,
                ...updatedData
              };
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Profil mis à jour avec succès'),
                  backgroundColor: AppColors.success));
            }
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Erreur: $e'), backgroundColor: AppColors.error));
          }
        },
      ),
    );
  }

  void _showLanguageDialog() {
    final currentLocale = ref.watch(localeProvider);
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
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value == null) return;
                ref.read(localeProvider.notifier).state = Locale(value);
                Hive.box('user_profile').put('locale', value);
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value == null) return;
                ref.read(localeProvider.notifier).state = Locale(value);
                Hive.box('user_profile').put('locale', value);
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'))
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
              child: const Text('Fermer'))
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
              child: const Text('Fermer'))
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
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(apiServiceProvider).clearToken();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) context.go('/phone-auth');
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la déconnexion')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('Gestion des Passagers',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          _buildListItem(
              Icons.account_balance_wallet_outlined,
              'Portefeuille Ankata',
              'Gérez votre solde et transactions',
              () => context.push('/wallet/transactions')),
          _buildListItem(
              Icons.notifications_active_outlined,
              'Mes Alertes Prix',
              'Recevez des alertes sur les tarifs',
              () => context.push('/profile/price-alerts')),
          _buildListItem(
              Icons.people_outline,
              'Passagers enregistrés',
              'Gérez vos compagnons de voyage fréquents',
              () => context.push('/profile/passengers')),
        ],
      ),
    );
  }
}
