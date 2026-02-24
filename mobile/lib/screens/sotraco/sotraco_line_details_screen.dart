import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../data/sotraco_data.dart';

class SotracoLineDetailsScreen extends StatelessWidget {
  final String lineId;

  const SotracoLineDetailsScreen({super.key, required this.lineId});

  @override
  Widget build(BuildContext context) {
    final line = SotracoData.getLineById(lineId);
    if (line == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ligne SOTRACO'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Ligne introuvable')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('${line.code} - ${line.name}', style: AppTextStyles.h4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildInfoCard('Distance', '${line.distanceKm} km'),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoCard('Duree', '${line.durationMin} min'),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoCard('Frequence', line.frequency),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoCard('Service', line.serviceHours),
          const SizedBox(height: AppSpacing.lg),
          Text('Arrets principaux', style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          ...line.stops.map((stop) => ListTile(
                leading: const Icon(Icons.place, color: AppColors.primary),
                title: Text(stop),
              )),
          const SizedBox(height: AppSpacing.lg),
          Text('Horaires exemples', style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: line.sampleTimes
                .map((time) => Chip(
                      label: Text(time),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
