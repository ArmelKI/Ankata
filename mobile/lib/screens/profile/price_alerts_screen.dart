import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../utils/haptic_helper.dart';

class PriceAlertsScreen extends ConsumerStatefulWidget {
  const PriceAlertsScreen({super.key});

  @override
  ConsumerState<PriceAlertsScreen> createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends ConsumerState<PriceAlertsScreen> {
  bool _isLoading = true;
  List<dynamic> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final alerts = await ref.read(apiServiceProvider).getPriceAlerts();
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _toggleAlert(String id) async {
    try {
      HapticHelper.lightImpact();
      await ref.read(apiServiceProvider).togglePriceAlert(id);
      _loadAlerts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteAlert(String id) async {
    try {
      HapticHelper.mediumImpact();
      await ref.read(apiServiceProvider).deletePriceAlert(id);
      _loadAlerts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Mes Alertes Prix'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.charcoal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return _buildAlertCard(alert);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: AppColors.gray.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Aucune alerte configurée',
            style: AppTextStyles.h4.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Créez une alerte lors de votre prochaine recherche pour être notifié des baisses de prix.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(dynamic alert) {
    final bool isActive = alert['is_active'] ?? true;
    final String origin = alert['origin_city'] ?? '';
    final String destination = alert['destination_city'] ?? '';
    final double targetPrice =
        (alert['target_price'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            title: Row(
              children: [
                Text(origin,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_forward,
                    size: 16, color: AppColors.gray),
                Text(destination,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Objectif: < ${targetPrice.toInt()} FCFA',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
              ),
            ),
            trailing: Switch(
              value: isActive,
              onChanged: (value) => _toggleAlert(alert['id']),
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _deleteAlert(alert['id']),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  label: const Text('Supprimer',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
