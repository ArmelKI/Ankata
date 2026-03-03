import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../services/company_logo_service.dart';
import '../../utils/company_logo_helper.dart';

final tripDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, tripId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final data = await api.getLineDetails(tripId);
    return data;
  } catch (_) {
    return null;
  }
});

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: tripAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          appBar: AppBar(title: const Text('Détails')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: AppColors.error, size: 48),
                SizedBox(height: 16),
                Text('Erreur lors du chargement',
                    style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ),
        data: (data) {
          if (data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Détails')),
              body: const Center(child: Text('Trajet introuvable')),
            );
          }

          final line = data;
          final schedules = line['schedules'] as List? ?? [];
          final companyName = line['company_name'] ?? 'Compagnie';
          final companyColor = CompanyColors.getCompanyColor(companyName);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: companyColor,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              companyColor,
                              companyColor.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Opacity(
                          opacity: 0.2,
                          child: CompanyLogoHelper.buildLogo(companyName,
                              size: 150),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trajet Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.radiusLg,
                          boxShadow: AppShadows.shadow1,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCityCol(line['origin_city'] ?? '', 'DE'),
                                const Icon(Icons.arrow_forward,
                                    color: AppColors.gray),
                                _buildCityCol(
                                    line['destination_city'] ?? '', 'À'),
                              ],
                            ),
                            const Divider(height: AppSpacing.xl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem(Icons.payments, 'Prix',
                                    '${line['base_price'] ?? 0} FCFA'),
                                _buildInfoItem(Icons.speed, 'Distance',
                                    '${line['distance_km'] ?? 0} km'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Horaires disponibles', style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.md),
                      if (schedules.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                              child: Text('Aucun départ prévu aujourd\'hui')),
                        )
                      else
                        ...schedules.map((s) =>
                            _buildScheduleCard(context, s, line, companyColor)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCityCol(String city, String label) {
    return Column(
      crossAxisAlignment:
          label == 'DE' ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray)),
        Text(city, style: AppTextStyles.h3),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray)),
        Text(value,
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> s,
      Map<String, dynamic> line, Color companyColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: companyColor.withValues(alpha: 0.1)),
        boxShadow: AppShadows.shadow1,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: companyColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Column(
              children: [
                Text(s['departure_time']?.substring(0, 5) ?? '--:--',
                    style: AppTextStyles.h4.copyWith(color: companyColor)),
                Text('Départ', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['is_vip'] == true ? 'Service VIP' : 'Service Classique',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                Text('${s['available_seats'] ?? 0} places restantes',
                    style: AppTextStyles.caption.copyWith(
                        color: (s['available_seats'] ?? 0) < 5
                            ? AppColors.error
                            : AppColors.success)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigation vers la sélection de siège ou passager
              context.push('/booking/passengers', extra: {
                'trip': line,
                'schedule': s,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: companyColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Réserver'),
          ),
        ],
      ),
    );
  }
}
