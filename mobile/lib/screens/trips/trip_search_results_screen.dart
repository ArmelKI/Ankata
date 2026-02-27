import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../services/favorites_service.dart';
import '../../widgets/stops_list_widget.dart';

class TripSearchResultsScreen extends ConsumerStatefulWidget {
  final String originCity;
  final String destinationCity;
  final String departureDate;
  final int passengers;

  const TripSearchResultsScreen({
    Key? key,
    required this.originCity,
    required this.destinationCity,
    required this.departureDate,
    this.passengers = 1,
  }) : super(key: key);

  @override
  ConsumerState<TripSearchResultsScreen> createState() =>
      _TripSearchResultsScreenState();
}

class _TripSearchResultsScreenState
    extends ConsumerState<TripSearchResultsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _trips = [];
  String _sortBy = 'price'; // price, time, duration, rating
  final Set<String> _favoriteKeys = {};
  final Set<String> _companyFilters = {};
  final Set<String> _amenityFilters = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadCachedTrips();
    _searchTrips();
  }

  Future<void> _loadFavorites() async {
    final api = ref.read(apiServiceProvider);
    final favorites = await FavoritesService.getFavorites(api: api);
    if (!mounted) return;
    setState(() {
      _favoriteKeys
        ..clear()
        ..addAll(favorites.map(_favoriteKey));
    });
  }

  String _favoriteKey(Map<String, dynamic> trip) {
    return '${trip['from']}-${trip['to']}-${trip['company']}';
  }

  Future<void> _loadCachedTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(
        widget.originCity, widget.destinationCity, widget.departureDate);
    final raw = prefs.getString(key);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final cachedTrips = decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (mounted && cachedTrips.isNotEmpty) {
        setState(() => _trips = cachedTrips);
      }
    } on FormatException {
      await prefs.remove(key);
    }
  }

  Future<void> _cacheTrips(List<Map<String, dynamic>> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(
        widget.originCity, widget.destinationCity, widget.departureDate);
    await prefs.setString(key, jsonEncode(trips));
  }

  String _cacheKey(String origin, String destination, String date) {
    return 'trips_${origin}_${destination}_$date';
  }

  Future<void> _searchTrips() async {
    setState(() => _isLoading = true);

    try {
      final response = await ref.read(apiServiceProvider).searchLines(
            widget.originCity,
            widget.destinationCity,
            widget.departureDate,
          );

      final lines = response['lines'] as List<dynamic>? ?? [];
      final parsedTrips = <Map<String, dynamic>>[];

      for (var lineRaw in lines) {
        final line = lineRaw as Map<String, dynamic>;
        final schedules = line['schedules'] as List<dynamic>? ?? [];

        for (var scheduleRaw in schedules) {
          final schedule = scheduleRaw as Map<String, dynamic>;

          String durationStr = '--';
          if (line['estimated_duration_minutes'] != null) {
            final mins = line['estimated_duration_minutes'] as int;
            durationStr =
                mins % 60 > 0 ? '${mins ~/ 60}h${mins % 60}' : '${mins ~/ 60}h';
          }

          String arrivalStr = schedule['arrival_time'] ?? '--:--';
          if (arrivalStr.length > 5) {
            arrivalStr = arrivalStr.substring(0, 5); // Take only HH:mm
          }
          String departureStr = schedule['departure_time'] ?? '--:--';
          if (departureStr.length > 5) {
            departureStr = departureStr.substring(0, 5); // Take only HH:mm
          }

          // Parse stops from schedule or use mock data
          final stops = (schedule['stops'] as List<dynamic>?)
                  ?.map((s) => Map<String, dynamic>.from(s as Map))
                  .toList() ??
              _generateMockStops(line['origin_city'] as String?,
                  line['destination_city'] as String?);

          parsedTrips.add({
            'lineId': line['id'],
            'scheduleId': schedule['id'],
            'companyId': line['company_id'],
            'company': line['company_name'] ?? 'Compagnie',
            'companyName': line['company_name'] ?? 'Compagnie',
            'departure': departureStr,
            'arrival': arrivalStr,
            'duration': durationStr,
            'price': line['base_price'],
            'availableSeats': schedule['available_seats'],
            'amenities': schedule['is_vip'] == true
                ? ['AC', 'WiFi', 'Siege inclinable']
                : ['Bagages'],
            'from': line['origin_city'],
            'to': line['destination_city'],
            'date': widget.departureDate,
            'passengers': widget.passengers,
            'isVip': schedule['is_vip'] ?? false,
            'rating': line['rating_average'] ?? 0.0,
            'reviews': 0,
            'logoUrl': line['logo_url'],
            'isUrban': line['is_urban'] ?? false,
            'stops': stops,
          });
        }
      }

      // Exclude urban companies (ex: SOTRACO) from intercity results
      final filteredTrips = parsedTrips.where((t) {
        final isUrban = t['isUrban'] as bool? ?? false;
        final companyName = (t['company'] as String? ?? '').toUpperCase();
        return !isUrban && !companyName.contains('SOTRACO');
      }).toList();

      if (mounted) {
        setState(() {
          _trips = filteredTrips;
          _isLoading = false;
        });
        await _cacheTrips(filteredTrips);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: Impossible de trouver des trajets')),
        );
      }
    }
  }

  void _safePop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  List<Map<String, dynamic>> get _sortedTrips {
    final trips = List<Map<String, dynamic>>.from(_trips);

    switch (_sortBy) {
      case 'price':
        trips.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'time':
        trips.sort((a, b) => a['departure'].compareTo(b['departure']));
        break;
      case 'duration':
        trips.sort((a, b) => a['duration'].compareTo(b['duration']));
        break;
      case 'rating':
        trips.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
    }

    return trips;
  }

  List<Map<String, dynamic>> get _filteredTrips {
    var trips = _sortedTrips;

    if (_companyFilters.isNotEmpty) {
      trips = trips
          .where((trip) => _companyFilters.contains(trip['company']))
          .toList();
    }

    if (_amenityFilters.isNotEmpty) {
      trips = trips.where((trip) {
        final amenities = (trip['amenities'] as List?)?.cast<String>() ?? [];
        return _amenityFilters.every((f) {
          if (f == 'VIP') return trip['isVip'] == true;
          return amenities.contains(f);
        });
      }).toList();
    }

    return trips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => _safePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.originCity} → ${widget.destinationCity}',
              style:
                  AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              widget.departureDate,
              style: AppTextStyles.caption.copyWith(color: AppColors.gray),
            ),
          ],
        ),
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 4,
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
      child: Column(
        children: [
          Row(
            children: [
              _buildShimmer(60, 60),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmer(120, 16),
                    const SizedBox(height: 8),
                    _buildShimmer(80, 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildShimmer(double.infinity, 40),
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

  Widget _buildContent() {
    if (_trips.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildHeader(),
        _buildActiveFilters(),
        Expanded(child: _buildTripsList()),
      ],
    );
  }

  Widget _buildActiveFilters() {
    if (_companyFilters.isEmpty && _amenityFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._companyFilters.map((c) => _buildFilterChip(
              c, () => setState(() => _companyFilters.remove(c)))),
          ..._amenityFilters.map((a) => _buildFilterChip(
              a, () => setState(() => _amenityFilters.remove(a)))),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        padding: EdgeInsets.zero,
        deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
        onDeleted: onDelete,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_trips.length} trajets disponibles',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton.icon(
            onPressed: _showFiltersSheet,
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Filtres'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final allCompanies =
              _trips.map((t) => t['company'] as String).toSet().toList();
          final amenities = ['WiFi', 'AC', 'VIP'];

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filtres & Tri', style: AppTextStyles.h4),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: AppSpacing.md),

                // Sort Section
                Text('Trier par',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildModalChip('price', 'Prix', _sortBy == 'price',
                        (v) => setModalState(() => _sortBy = 'price')),
                    _buildModalChip('time', 'Heure', _sortBy == 'time',
                        (v) => setModalState(() => _sortBy = 'time')),
                    _buildModalChip('duration', 'Durée', _sortBy == 'duration',
                        (v) => setModalState(() => _sortBy = 'duration')),
                    _buildModalChip('rating', 'Note', _sortBy == 'rating',
                        (v) => setModalState(() => _sortBy = 'rating')),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Companies Section
                Text('Compagnies',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  children: allCompanies
                      .map((c) => _buildModalChip(
                          c,
                          c,
                          _companyFilters.contains(c),
                          (v) => setModalState(() {
                                if (v)
                                  _companyFilters.add(c);
                                else
                                  _companyFilters.remove(c);
                              })))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Amenities Section
                Text('Services à bord',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  children: amenities
                      .map((a) => _buildModalChip(
                          a,
                          a,
                          _amenityFilters.contains(a),
                          (v) => setModalState(() {
                                if (v)
                                  _amenityFilters.add(a);
                                else
                                  _amenityFilters.remove(a);
                              })))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd),
                    ),
                    child: const Text('Appliquer les filtres',
                        style: TextStyle(color: AppColors.white)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalChip(
      String id, String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.charcoal,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTripsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredTrips.length,
      itemBuilder: (context, index) {
        final trip = _filteredTrips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context.push('/passenger-info', extra: {
                'trip': trip,
                'passengers': widget.passengers,
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Logo compagnie
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: CompanyColors.getCompanyColor(trip['company']),
                          borderRadius: AppRadius.radiusSm,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: trip['logoUrl'] != null &&
                                (trip['logoUrl'] as String).isNotEmpty
                            ? (trip['logoUrl'] as String).startsWith('http')
                                ? Image.network(
                                    trip['logoUrl'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          trip['company'][0],
                                          style: AppTextStyles.h3
                                              .copyWith(color: AppColors.white),
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    trip['logoUrl'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          trip['company'][0],
                                          style: AppTextStyles.h3
                                              .copyWith(color: AppColors.white),
                                        ),
                                      );
                                    },
                                  )
                            : Center(
                                child: Text(
                                  trip['company'][0],
                                  style: AppTextStyles.h3
                                      .copyWith(color: AppColors.white),
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Info compagnie
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip['company'] as String? ?? 'Compagnie',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${trip['availableSeats'] ?? 0} places disponibles',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gray),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () async {
                          final route = {
                            'from': trip['from'] as String? ?? '',
                            'to': trip['to'] as String? ?? '',
                            'company': trip['company'] as String? ?? '',
                          };
                          await FavoritesService.toggleFavorite(
                            route,
                            api: ref.read(apiServiceProvider),
                          );
                          await _loadFavorites();
                        },
                        icon: Icon(
                          _favoriteKeys.contains(_favoriteKey(trip))
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.star,
                        ),
                      ),

                      // Places disponibles badge
                      if ((trip['availableSeats'] as int? ?? 99) <= 10)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: AppRadius.radiusFull,
                          ),
                          child: Text(
                            '${trip['availableSeats']}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Horaires
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip['departure'] as String? ?? '--:--',
                                style: AppTextStyles.h3),
                            Text('Départ',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.gray)),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Container(
                                    width: 30,
                                    height: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.arrow_forward,
                                      color: AppColors.primary, size: 16),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 30,
                                    height: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(trip['duration'] as String? ?? '--',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(trip['arrival'] as String? ?? '--:--',
                                style: AppTextStyles.h3),
                            Text('Arrivée',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.gray)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Équipements
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: (trip['amenities'] as List?)
                            ?.cast<String>()
                            .map((amenity) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray,
                                    borderRadius: AppRadius.radiusFull,
                                  ),
                                  child: Text(
                                    amenity,
                                    style: AppTextStyles.caption,
                                  ),
                                ))
                            .toList() ??
                        [],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Arrêts
                  if ((trip['stops'] as List?)?.isNotEmpty ?? false) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Arrêts',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.sm),
                          StopsListWidget(
                            stops: (trip['stops'] as List)
                                .cast<Map<String, dynamic>>(),
                            routeName: trip['company'] as String? ?? 'Ligne',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Prix et bouton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${trip['price'] ?? 0} FCFA',
                          style: AppTextStyles.price),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/passenger-info', extra: {
                            'trip': trip,
                            'passengers': widget.passengers,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: const Text('Sélectionner'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
                Icons.search_off,
                size: 60,
                color: AppColors.gray,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun trajet disponible',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Essayez de modifier vos critères de recherche',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () => _safePop(context),
              child: const Text('Modifier la recherche'),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _showPriceAlertDialog,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Créer une alerte prix'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceAlertDialog() {
    final priceController = TextEditingController();
    // Default target price: 10% less than cheapest if available, else 5000
    double defaultPrice = 5000;
    if (_trips.isNotEmpty) {
      final minPrice =
          _trips.map((t) => t['price'] as num).reduce((a, b) => a < b ? a : b);
      defaultPrice = (minPrice * 0.9).floorToDouble();
    }
    priceController.text = defaultPrice.toInt().toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une alerte prix'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soyez notifié quand un trajet de ${widget.originCity} vers ${widget.destinationCity} est disponible à ce prix ou moins.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix maximum (FCFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null) {
                Navigator.pop(context);
                _createPriceAlert(price);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPriceAlert(double targetPrice) async {
    try {
      await ref.read(apiServiceProvider).createPriceAlert(
            originCity: widget.originCity,
            destinationCity: widget.destinationCity,
            targetPrice: targetPrice,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerte créée avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _generateMockStops(String? from, String? to) {
    // Mock stops between two cities
    final fromCity = from ?? 'Ouagadougou';
    final toCity = to ?? 'Bobo-Dioulasso';

    return [
      {
        'name': fromCity,
        'duration': '00:00',
        'price': 0,
        'lat': 12.3656,
        'lng': -1.5197,
      },
      {
        'name': 'Koudougou',
        'duration': '02:15',
        'price': 2000,
        'lat': 12.2592,
        'lng': -2.3707,
      },
      {
        'name': 'Kaya',
        'duration': '04:30',
        'price': 3500,
        'lat': 13.0450,
        'lng': -1.2722,
      },
      {
        'name': toCity,
        'duration': '06:00',
        'price': 5000,
        'lat': 11.1847,
        'lng': -4.2695,
      },
    ];
  }
}
