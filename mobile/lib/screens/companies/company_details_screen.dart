import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../data/all_companies_data.dart';
import '../../models/transport_company.dart';
import '../../services/ratings_service.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final String companyId;

  const CompanyDetailsScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransportCompany? _company;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompany();
  }

  void _loadCompany() {
    _company = AllCompaniesData.getCompanyById(widget.companyId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compagnie introuvable')),
        body: const Center(
            child:
                Text('Cette compagnie n\'est pas disponible pour le moment')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _company!.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_company!.name,
                  style: AppTextStyles.h3.copyWith(color: AppColors.white)),
              background: Container(
                color: _company!.color,
                child: Center(
                  child: Icon(
                    Icons.business,
                    size: 80,
                    color: AppColors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
              indicatorColor: AppColors.white,
              tabs: const [
                Tab(text: 'Informations'),
                Tab(text: 'Destinations'),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildDestinationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildRatingsCard(),
        const SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          'Contact',
          [
            _buildInfoRow(Icons.location_on, _company!.address),
            ...(_company!.phones
                .map((phone) => _buildInfoRow(Icons.phone, phone))),
            if (_company!.email != null)
              _buildInfoRow(Icons.email, _company!.email!),
            if (_company!.website != null)
              _buildInfoRow(Icons.language, _company!.website!),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          'Services',
          _company!.services
              .map((service) => _buildInfoRow(Icons.check_circle, service))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          'Gares',
          _company!.stations.entries
              .map((entry) => _buildStationRow(entry.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDestinationsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: _company!.stations.entries.map((entry) {
        final city = entry.key;
        final station = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _company!.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Row(
                children: [
                  Icon(Icons.place, color: _company!.color),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    city,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _company!.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...station.routes
                .where((route) => route.isActive && route.departures.isNotEmpty)
                .map((route) => _buildRouteCard(route)),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRouteCard(RouteSchedule route) {
    final originCity = route.from;
    final durationHours = route.durationMinutes ~/ 60;
    final durationMinutes = route.durationMinutes % 60;
    final durationLabel = durationMinutes > 0
        ? '${durationHours}h$durationMinutes'
        : '${durationHours}h';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.arrow_forward, size: 16, color: _company!.color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                route.to,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${route.distanceKm} km • $durationLabel • ${route.priceStandard} FCFA',
          style: AppTextStyles.caption.copyWith(color: AppColors.gray),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (route.priceVip != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Prix VIP: ${route.priceVip} FCFA',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                Text('Horaires de départ:',
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: route.departures.map((dep) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: dep.isVip ? _company!.color : AppColors.white,
                        borderRadius: AppRadius.radiusSm,
                        border: Border.all(color: _company!.color),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dep.time,
                            style: TextStyle(
                              color:
                                  dep.isVip ? AppColors.white : _company!.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (dep.gareSpecific != null)
                            Text(
                              dep.gareSpecific!,
                              style: TextStyle(
                                color: dep.isVip
                                    ? AppColors.white
                                    : AppColors.gray,
                                fontSize: 8,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                // Bouton de réservation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/trip-search-results',
                        extra: {
                          'origin': originCity,
                          'destination': route.to,
                          'date': DateTime.now(),
                          'passengers': 1,
                          'companyFilter': _company!.id,
                        },
                      );
                    },
                    icon: const Icon(Icons.confirmation_number, size: 18),
                    label: const Text('Réserver ce trajet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _company!.color,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.bodyLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRatingsCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: RatingsService.getCompanyStats(_company!.id),
      builder: (context, snapshot) {
        final average = (snapshot.data?['average'] as double?) ?? 0.0;
        final count = (snapshot.data?['count'] as int?) ?? 0;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.radiusMd,
            boxShadow: AppShadows.shadow1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Avis et notes',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    count == 0 ? 'Aucun avis' : '$count avis',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.gray),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.star, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    average.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: count == 0 ? 0 : (average / 5.0).clamp(0.0, 1.0),
                      backgroundColor: AppColors.lightGray,
                      color: AppColors.star,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/rating/company-${_company!.id}', extra: {
                      'companyId': _company!.id,
                    });
                  },
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text('Laisser un avis'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _company!.color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildStationRow(CompanyStation station) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place, size: 18, color: _company!.color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                station.city,
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              station.address,
              style: AppTextStyles.caption.copyWith(color: AppColors.gray),
            ),
          ),
          if (station.phone != null)
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                station.phone!,
                style: AppTextStyles.caption.copyWith(color: AppColors.gray),
              ),
            ),
        ],
      ),
    );
  }
}
