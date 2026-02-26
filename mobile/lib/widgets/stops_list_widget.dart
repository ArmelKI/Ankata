import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class StopDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> stop;
  final String routeName;

  const StopDetailsDialog({
    Key? key,
    required this.stop,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stopName = stop['name'] ?? 'Arrêt';
    final duration = stop['duration'] ?? '0min';
    final price = stop['price'] ?? 0;
    final lat = stop['lat'] ?? 12.3656;
    final lng = stop['lng'] ?? -1.5197; // Default: Ouagadougou

    // OpenStreetMap static map URL (100% gratuit, pas de clé API nécessaire)
    final mapUrl =
        'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=13&size=400x300&markers=$lat,$lng,red';

    return AlertDialog(
      backgroundColor: AppColors.white,
      title: Text('Arrêt: $stopName', style: AppTextStyles.h4),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OpenStreetMap static map (gratuit)
            ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: Image.network(
                mapUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.lightGray,
                  child: Center(
                    child: Icon(Icons.location_off, color: AppColors.gray),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow('Ligne', routeName),
            _buildInfoRow('Durée du trajet', duration),
            _buildInfoRow('Prix', '$price FCFA'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Text(
                'Coordonnées: $lat, $lng',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class StopsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> stops;
  final String routeName;

  const StopsListWidget({
    Key? key,
    required this.stops,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return Center(
        child: Text('Aucun arrêt disponible', style: AppTextStyles.bodyMedium),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        final stopName = stop['name'] ?? 'Arrêt ${index + 1}';
        final duration = stop['duration'] ?? '0min';
        final price = stop['price'] ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            title: Text(stopName, style: AppTextStyles.bodyMedium),
            subtitle: Text(
              'Durée: $duration • $price FCFA',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => StopDetailsDialog(
                  stop: stop,
                  routeName: routeName,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
