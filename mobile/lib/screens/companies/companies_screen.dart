import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../data/all_companies_data.dart';
import '../../services/ratings_service.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({Key? key}) : super(key: key);

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _companies = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);

    // Simulation du chargement depuis l'API
    await Future.delayed(const Duration(seconds: 1));

    final companies = AllCompaniesData.getAllCompanies();
    final mapped = <Map<String, dynamic>>[];

    for (final company in companies) {
      final stats = await RatingsService.getCompanyStats(company.id);
      mapped.add({
        'id': company.id,
        'name': company.name,
        'fullName': company.name,
        'rating': stats['average'] ?? 0.0,
        'reviews': stats['count'] ?? 0,
        'totalTrips': company.stations.values
            .fold<int>(0, (sum, s) => sum + s.routes.length),
        'verified': true,
        'description': company.services.isEmpty
            ? 'Compagnie interurbaine'
            : company.services.first,
      });
    }

    setState(() {
      _companies = mapped;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredCompanies {
    return _companies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('Compagnies', style: AppTextStyles.h3),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredCompanies.isEmpty
                    ? _buildEmptyState()
                    : _buildCompaniesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return const SizedBox.shrink(); // Filtrage inutile sans SOTRACO
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Row(
        children: [
          _buildShimmer(80, 80),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(150, 20),
                const SizedBox(height: 8),
                _buildShimmer(100, 16),
                const SizedBox(height: 8),
                _buildShimmer(120, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppGradients.shimmer,
        borderRadius: AppRadius.radiusSm,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business,
                size: 60,
                color: AppColors.gray,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune compagnie trouvée',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Essayez de modifier vos filtres',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompaniesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredCompanies.length,
      itemBuilder: (context, index) {
        final company = _filteredCompanies[index];
        return _buildCompanyCard(company);
      },
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: InkWell(
        onTap: () {
          final companyName = company['name'] as String? ?? '';
          if (companyName == 'SOTRACO') {
            context.push('/sotraco');
            return;
          }
          context.push('/companies/${company['id']}');
        },
        borderRadius: AppRadius.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CompanyColors.getCompanyColor(company['name']),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Center(
                  child: Text(
                    company['name'][0],
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            company['name'],
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (company['verified'])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: AppRadius.radiusFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Vérifiée',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.success,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company['fullName'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFFFB800)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${company['rating'] ?? 0.0}/5.0',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          ' (${company['reviews']} avis)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.gray,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${company['totalTrips']} trajets',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.gray),
            ],
          ),
        ),
      ),
    );
  }
}
