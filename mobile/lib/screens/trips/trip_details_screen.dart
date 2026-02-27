
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';

final tripDetailsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, tripId) async {
  final api = ref.read(apiServiceProvider);
  try {
    // Suppose endpoint: /lines/:tripId
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
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Détails du trajet', style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGray,
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Erreur lors du chargement du trajet', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        data: (data) {
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.gray, size: 48),
                  const SizedBox(height: 16),
                  const Text('Trajet introuvable ou non disponible'),
                ],
              ),
            );
          }

          final line = data;
          final schedules = line['schedules'] as List? ?? [];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.radiusLg,
                  boxShadow: AppShadows.shadow1,
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line['company_name'] ?? 'Compagnie', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text('${line['origin_city']} → ${line['destination_city']}', style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 8),
                    Text('Prix: ${line['base_price'] ?? '--'} FCFA', style: AppTextStyles.price),
                    const SizedBox(height: 8),
                    Text('Distance: ${line['distance_km'] ?? '--'} km'),
                    const SizedBox(height: 8),
                    Text('Durée estimée: ${line['estimated_duration_minutes'] ?? '--'} min'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (schedules.isNotEmpty) ...[
                Text('Horaires disponibles', style: AppTextStyles.h4),
                const SizedBox(height: 8),
                ...schedules.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Départ: ${s['departure_time'] ?? '--:--'}'),
                      Text('Arrivée: ${s['arrival_time'] ?? '--:--'}'),
                      Text('Places disponibles: ${s['available_seats'] ?? '--'}'),
                    ],
                  ),
                ))
              ] else ...[
                const Text('Aucun horaire disponible pour ce trajet'),
              ],
            ],
          );
        },
      ),
    );
  }
}
