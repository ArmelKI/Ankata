import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../utils/haptic_helper.dart';

class ReferralDashboardScreen extends ConsumerStatefulWidget {
  const ReferralDashboardScreen({super.key});

  @override
  ConsumerState<ReferralDashboardScreen> createState() =>
      _ReferralDashboardScreenState();
}

class _ReferralDashboardScreenState
    extends ConsumerState<ReferralDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getReferralStats();
      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Mon Parrainage'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _buildCodeCard(),
                      const SizedBox(height: AppSpacing.md),
                      _buildStatsRow(),
                      const SizedBox(height: AppSpacing.md),
                      _buildHowItWorks(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildShareButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCodeCard() {
    final code = _stats?['referralCode'] ?? '-------';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          Text(
            'Votre code de parrainage',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  code,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    HapticHelper.success();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copie !')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final count = _stats?['referralCount'] ?? 0;
    final earned = _stats?['totalEarned'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Amis parraines',
            count.toString(),
            Icons.people_outline,
            Colors.blue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatItem(
            'Gains totaux',
            '${earned.toInt()} F',
            Icons.account_balance_wallet_outlined,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.charcoal),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comment ca marche ?', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _stepItem('1', 'Partagez votre code unique avec vos amis.'),
          _stepItem('2', 'Ils s\'inscrivent en utilisant votre code.'),
          _stepItem('3',
              'Vous recevez 100 F par ami lorsqu\'ils reservent leur premier trajet !'),
        ],
      ),
    );
  }

  Widget _stepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    final code = _stats?['referralCode'] ?? '';
    final message =
        'Inscris-toi sur Ankata avec mon code $code et voyage plus sereinement au Burkina Faso ! https://ankata.app';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticHelper.lightImpact();
          Share.share(message);
        },
        icon: const Icon(Icons.share),
        label: const Text('Partager mon code'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
