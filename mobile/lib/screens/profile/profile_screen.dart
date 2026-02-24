import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../services/favorites_service.dart';
import '../../widgets/referral_dialog.dart';
import '../../widgets/company_logo.dart';
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
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _photoPath = prefs.getString('profile_photo_path'));
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo_path', image.path);

    if (!mounted) return;
    setState(() => _photoPath = image.path);
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
            _buildReferralSection(), // 🎁 Referral (100F par ami, max 15)
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.white,
      child: Column(
        children: [
          // 🎨 User Avatar (NOUVEAU - remplace l'initiale simple)
          Stack(
            children: [
              UserAvatar(
                name: 'Jean Ouedraogo',
                size: 100,
                imageUrl: _photoPath,
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
            'Jean Ouedraogo',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '+226 70 12 34 56',
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
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Informations personnelles',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildListItem(
            Icons.badge,
            'Num\u00e9ro CNIB',
            'B123456789',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Modification CNIB en cours de d\u00e9veloppement')),
              );
            },
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.person,
            'Sexe',
            'Masculin',
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('S\u00e9lectionner le sexe'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: const Text('Masculin'),
                        value: 'Masculin',
                        groupValue: 'Masculin',
                        onChanged: (value) => Navigator.pop(context),
                      ),
                      RadioListTile<String>(
                        title: const Text('F\u00e9minin'),
                        value: 'F\u00e9minin',
                        groupValue: 'Masculin',
                        onChanged: (value) => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildListItem(
            Icons.calendar_today,
            'Date de naissance',
            '15 Janvier 1990',
            () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1990, 1, 15),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
              );
              if (date != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Date s\u00e9lectionn\u00e9e: ${date.day}/${date.month}/${date.year}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 💰 NOUVEAU: Section Premium & Referral
  Widget _buildReferralSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Gagne Des Points',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildListItem(
            Icons.card_giftcard,
            'Parrainer un ami',
            'Gagne 100F par personne. Max 15. Ton ami aussi!',
            () {
              HapticHelper.lightImpact();
              ReferralDialog.show(context, referralCode: 'USER123');
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
            'Clair',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: 'Jean',
              decoration: const InputDecoration(
                labelText: 'Pr\u00e9nom',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: 'Ouedraogo',
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: '',
              decoration: const InputDecoration(
                labelText: 'CNIB',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil mis à jour avec succès'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Clair'),
              value: 'light',
              groupValue: 'light',
              onChanged: (value) {
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
            ),
            const RadioListTile<String>(
              title: Text('Sombre (à venir)'),
              value: 'dark',
              groupValue: 'light',
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
