import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../data/all_companies_data.dart';
import '../../widgets/animated_button.dart';
import '../../utils/haptic_helper.dart';
import '../../services/search_history_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedOrigin;
  String? _selectedDestination;
  DateTime? _selectedDate;
  int _passengers = 1;
  List<Map<String, dynamic>> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    // Pas de localisation par défaut - l'utilisateur doit choisir
    _selectedOrigin = null;
    _selectedDestination = null;
    _loadRecentSearches();
  }

  void _searchTrips() {
    if (_selectedOrigin == null ||
        _selectedDestination == null ||
        _selectedOrigin == _selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez des villes différentes')),
      );
      return;
    }

    final search = {
      'originCity': _selectedOrigin,
      'destinationCity': _selectedDestination,
      'departureDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'passengers': _passengers,
    };

    SearchHistoryService.addSearch(search);
    _loadRecentSearches();

    context.go('/trips/search', extra: search);
  }

  void _changePassengers(int delta) {
    final nextValue = _passengers + delta;
    if (nextValue < 1 || nextValue > 9) {
      return;
    }
    setState(() => _passengers = nextValue);
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('fr', 'FR'),
      helpText: 'Sélectionner la date',
      cancelText: 'Annuler',
      confirmText: 'OK',
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _loadRecentSearches() async {
    final items = await SearchHistoryService.getRecentSearches();
    if (mounted) {
      setState(() => _recentSearches = items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Center(
                child: Text(
                  'A',
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Ankata', style: AppTextStyles.h3),
          ],
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_outlined, color: AppColors.gray),
            onPressed: () {
              // Navigation vers la page notifications (à implémenter)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Fonctionnalit\u00e9 notifications en cours de d\u00e9veloppement'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Card Hero
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: AppRadius.radiusLg,
                  boxShadow: AppShadows.shadow3,
                ),
                child: Column(
                  children: [
                    // Origine (Dropdown)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedOrigin,
                        underline: const SizedBox(),
                        hint: const Text('Sélectionner départ'),
                        items: AppConstants.cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedOrigin = value);
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Destination (Dropdown)
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedDestination,
                            underline: const SizedBox(),
                            hint: const Text('Sélectionner destination'),
                            items: AppConstants.cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedDestination = value);
                            },
                          ),
                        ),
                        // Bouton d'échange
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                final temp = _selectedOrigin;
                                _selectedOrigin = _selectedDestination;
                                _selectedDestination = temp;
                              });
                              HapticHelper.lightImpact();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: const Icon(
                                Icons.repeat,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Date & Passagers
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: AppRadius.radiusMd,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: AppSpacing.md),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Date',
                                          style: AppTextStyles.bodySmall),
                                      Text(
                                        _selectedDate != null
                                            ? DateFormat('d MMM', 'fr_FR')
                                                .format(_selectedDate!)
                                            : 'Demain',
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _changePassengers(-1),
                                icon: const Icon(Icons.remove, size: 18),
                                color: AppColors.primary,
                              ),
                              Text(
                                '$_passengers',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _changePassengers(1),
                                icon: const Icon(Icons.add, size: 18),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Bouton Rechercher (UPGRADED avec AnimatedButton!)
                    AnimatedButton(
                      text: 'Rechercher des trajets',
                      onPressed: () {
                        HapticHelper.lightImpact();
                        _searchTrips();
                      },
                      icon: Icons.search,
                    ),
                  ],
                ),
              ),

              if (_recentSearches.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recherches recentes', style: AppTextStyles.h4),
                      const SizedBox(height: AppSpacing.sm),
                      ..._recentSearches.map((item) {
                        final origin = item['originCity'] ?? '';
                        final destination = item['destinationCity'] ?? '';
                        final date = item['departureDate'] ?? '';
                        final passengers = item['passengers'] ?? 1;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.history, color: AppColors.gray),
                          title: Text('$origin → $destination',
                              style: AppTextStyles.bodyMedium),
                          subtitle: Text('$date • $passengers passager(s)'),
                          onTap: () {
                            context.go('/trips/search', extra: item);
                          },
                        );
                      }),
                    ],
                  ),
                ),

              // Trajets Populaires
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Trajets populaires',
                        style: AppTextStyles.h3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_selectedOrigin == null ||
                            _selectedDestination == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Sélectionnez une origine et une destination')),
                          );
                          return;
                        }
                        context.push('/trips/search', extra: {
                          'originCity': _selectedOrigin,
                          'destinationCity': _selectedDestination,
                          'departureDate':
                              DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          'passengers': _passengers,
                        });
                      },
                      child: Text(
                        'Voir tout',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    _buildPopularRoute(
                        'Ouaga → Bobo', '6 compagnies', '4 500 FCFA', 4.2),
                    _buildPopularRoute(
                        'Bobo → Ouaga', '6 compagnies', '4 500 FCFA', 4.2),
                    _buildPopularRoute(
                        'Ouaga → Fada', '4 compagnies', '3 500 FCFA', 4.0),
                  ],
                ),
              ),

              // Compagnies
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Compagnies de transport',
                        style: AppTextStyles.h3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/companies'),
                      child: Text(
                        'Voir toutes',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.75,
                  children: [
                    _buildCompanyCard('SOTRACO', 4.5, 'Transport\nurbain',
                        CompanyColors.getCompanyColor('SOTRACO')),
                    _buildCompanyCard('TSR', 3.2, 'Prix bas',
                        CompanyColors.getCompanyColor('TSR')),
                    _buildCompanyCard('STAF', 4.1, 'Fiable',
                        CompanyColors.getCompanyColor('STAF')),
                    _buildCompanyCard('RAHIMO', 4.6, 'Premium',
                        CompanyColors.getCompanyColor('RAHIMO')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularRoute(
      String route, String companies, String price, double rating) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.shadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(route, style: AppTextStyles.h4),
              const SizedBox(height: 4),
              Text(companies,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.gray)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'À partir de $price',
                  style: AppTextStyles.priceSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.star, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(
      String name, double rating, String badge, Color color) {
    return InkWell(
      onTap: () {
        if (name == 'SOTRACO') {
          context.push('/sotraco');
          return;
        }
        final id = _getCompanyIdByName(name);
        if (id != null) {
          context.push('/companies/$id');
        } else {
          context.push('/companies');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.radiusMd,
          boxShadow: AppShadows.shadow2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: AppTextStyles.h1.copyWith(color: color),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(name, style: AppTextStyles.h4, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: AppColors.star, size: 14),
                const SizedBox(width: 4),
                Text(rating.toString(),
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              badge,
              style: AppTextStyles.bodySmall.copyWith(color: color),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(height: 3, color: color),
          ],
        ),
      ),
    );
  }

  String? _getCompanyIdByName(String name) {
    for (final company in AllCompaniesData.getAllCompanies()) {
      if (company.name == name) {
        return company.id;
      }
    }
    return null;
  }
}
