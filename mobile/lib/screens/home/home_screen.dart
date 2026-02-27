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
import '../../services/update_service.dart';

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

    // Check for updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkUpdate(context);
      }
    });
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

    context.push('/trips/search', extra: search);
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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Header & Floating Search Card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Immersive curved header
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.xxxl, AppSpacing.lg, AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenue sur',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color:
                                            AppColors.white.withOpacity(0.8)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Ankata.',
                                    style: AppTextStyles.h1
                                        .copyWith(color: AppColors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.white),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Fonctionnalité notifications en cours')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Où voulez-vous\naller aujourd\'hui ?',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Search Card
                  Container(
                    margin: const EdgeInsets.only(
                      top: 200, // Chevauche le header
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.xl,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.radiusLg,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Origine & Destination avec Swap Bouton intégré
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Column(
                                children: [
                                  // Départ
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm, vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: _selectedOrigin,
                                                hint: Text('Lieu de départ',
                                                    style: AppTextStyles
                                                        .bodyMedium
                                                        .copyWith(
                                                            color: AppColors
                                                                .gray)),
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: AppColors.gray),
                                                items: AppConstants.cities
                                                    .map((city) {
                                                  return DropdownMenuItem(
                                                      value: city,
                                                      child: Text(city,
                                                          style: AppTextStyles
                                                              .bodyLarge));
                                                }).toList(),
                                                onChanged: (value) => setState(
                                                    () => _selectedOrigin =
                                                        value),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1, indent: 40),
                                  // Arrivée
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm, vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: AppColors.error, size: 20),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: _selectedDestination,
                                                hint: Text('Destination',
                                                    style: AppTextStyles
                                                        .bodyMedium
                                                        .copyWith(
                                                            color: AppColors
                                                                .gray)),
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: AppColors.gray),
                                                items: AppConstants.cities
                                                    .map((city) {
                                                  return DropdownMenuItem(
                                                      value: city,
                                                      child: Text(city,
                                                          style: AppTextStyles
                                                              .bodyLarge));
                                                }).toList(),
                                                onChanged: (value) => setState(
                                                    () => _selectedDestination =
                                                        value),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Swap Button flottant à droite
                              Positioned(
                                right: AppSpacing.md,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticHelper.lightImpact();
                                    setState(() {
                                      final temp = _selectedOrigin;
                                      _selectedOrigin = _selectedDestination;
                                      _selectedDestination = temp;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGray,
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: AppColors.border),
                                      boxShadow: AppShadows.shadow1,
                                    ),
                                    child: const Icon(Icons.swap_vert,
                                        color: AppColors.primary, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Date & Passagers Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded,
                                          color: AppColors.primary, size: 20),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Date de départ',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                        color: AppColors.gray)),
                                            Text(
                                              _selectedDate != null
                                                  ? DateFormat(
                                                          'E d MMM', 'fr_FR')
                                                      .format(_selectedDate!)
                                                  : 'Aujourd\'hui',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: AppRadius.radiusMd,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _changePassengers(-1),
                                      child: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColors.primary,
                                          size: 24),
                                    ),
                                    Column(
                                      children: [
                                        Text('Passagers',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                    color: AppColors.gray)),
                                        Text('$_passengers',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => _changePassengers(1),
                                      child: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primary,
                                          size: 24),
                                    ),
                                  ],
                                ),
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
                ],
              ),

              _buildQuickServices(),

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
                    _buildPopularRoute('Ouagadougou', 'Bobo-Dioulasso',
                        'Ouaga → Bobo', '4 500 FCFA'),
                    _buildPopularRoute('Bobo-Dioulasso', 'Ouagadougou',
                        'Bobo → Ouaga', '4 500 FCFA'),
                    _buildPopularRoute('Ouagadougou', 'Fada N\'Gourma',
                        'Ouaga → Fada', '3 500 FCFA'),
                  ],
                ),
              ),

              // SOTRACO Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
                child: InkWell(
                  onTap: () => context.push('/sotraco'),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(
                          color: CompanyColors.getCompanyColor('SOTRACO')),
                      boxShadow: AppShadows.shadow2,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: CompanyColors.getCompanyColor('SOTRACO')
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Icon(Icons.directions_bus,
                              color: CompanyColors.getCompanyColor('SOTRACO'),
                              size: 30),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SOTRACO - Transport Urbain',
                                  style: AppTextStyles.h4),
                              const SizedBox(height: 4),
                              Text('Déplacez-vous facilement dans Ouagadougou',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.gray)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.gray),
                      ],
                    ),
                  ),
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
                  childAspectRatio: 0.85,
                  children: [
                    _buildCompanyCard('TSR', 'Prix abordables',
                        CompanyColors.getCompanyColor('TSR')),
                    _buildCompanyCard('STAF', 'Large réseau',
                        CompanyColors.getCompanyColor('STAF')),
                    _buildCompanyCard('RAHIMO', 'Confort Premium',
                        CompanyColors.getCompanyColor('RAHIMO')),
                    _buildCompanyCard('TCV', 'Gares modernes',
                        CompanyColors.getCompanyColor('TCV')),
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
      String origin, String destination, String routeName, String price) {
    return InkWell(
      onTap: () {
        context.push('/trips/search', extra: {
          'originCity': origin,
          'destinationCity': destination,
          'departureDate': DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(const Duration(days: 1))),
          'passengers': 1,
        });
      },
      child: Container(
        width: 250,
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
                Text(routeName, style: AppTextStyles.h4),
                const SizedBox(height: 4),
                Text('Trajet direct',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.gray)),
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
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.gray),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(String name, String badge, Color color) {
    return InkWell(
      onTap: () {
        final id = _getCompanyIdByName(name);
        if (id != null) {
          context.push('/companies/$id');
        } else {
          context.push('/companies');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.radiusLg,
          boxShadow: AppShadows.shadow2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: AppTextStyles.h2.copyWith(color: color),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(name,
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1),
            const SizedBox(height: 2),
            Text(
              badge,
              style: AppTextStyles.caption.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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

  Widget _buildQuickServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services Rapides', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildServiceItem(
                'Gares',
                Icons.map_outlined,
                AppColors.primary,
                () => context.push('/stations'),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildServiceItem(
                'SOTRACO',
                Icons.directions_bus_outlined,
                Colors.orange,
                () => context.push('/sotraco'),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildServiceItem(
                'Promotions',
                Icons.local_offer_outlined,
                AppColors.success,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Aucune promotion en ce moment')),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticHelper.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
