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

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadCachedTrips();
    _searchTrips();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.getFavorites();
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
              _generateMockStops(line['origin_city'] as String?, line['destination_city'] as String?);

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
                ? ['AC', 'WiFi', 'Siège inclinable']
                : ['Bagages'],
            'from': line['origin_city'],
            'to': line['destination_city'],
            'date': widget.departureDate,
            'passengers': widget.passengers,
            'isVip': schedule['is_vip'] ?? false,
            'rating': line['rating_average'] ?? 0.0,
            'reviews': 0,
            'logoUrl': line['logo_url'],
            'stops': stops,
          });
        }
      }

      if (mounted) {
        setState(() {
          _trips = parsedTrips;
          _isLoading = false;
        });
        await _cacheTrips(parsedTrips);
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
    if (_companyFilters.isEmpty) {
      return _sortedTrips;
    }
    return _sortedTrips
        .where((trip) => _companyFilters.contains(trip['company']))
        .toList();
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
        _buildCompanyFilters(),
        Expanded(child: _buildTripsList()),
      ],
    );
  }

  Widget _buildCompanyFilters() {
    final companies =
        _trips.map((trip) => trip['company'] as String).toSet().toList();
    if (companies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Wrap(
        spacing: 8,
        children: companies.map((company) {
          final isSelected = _companyFilters.contains(company);
          return FilterChip(
            label: Text(company),
            selected: isSelected,
            onSelected: (value) {
              setState(() {
                if (value) {
                  _companyFilters.add(company);
                } else {
                  _companyFilters.remove(company);
                }
              });
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_trips.length} trajets disponibles',
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.sort, size: 20),
            items: const [
              DropdownMenuItem(value: 'price', child: Text('Prix')),
              DropdownMenuItem(value: 'time', child: Text('Heure')),
              DropdownMenuItem(value: 'duration', child: Text('Durée')),
              DropdownMenuItem(value: 'rating', child: Text('Note')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortBy = value);
              }
            },
          ),
        ],
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
      child: InkWell(
        onTap: () {
          context.push('/passenger-info', extra: {
            'trip': trip,
            'passengers': widget.passengers,
          });
        },
        borderRadius: AppRadius.radiusMd,
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
                    child: trip['logoUrl'] != null && trip['logoUrl'].isNotEmpty
                        ? Image.asset(
                            trip['logoUrl'],
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
                      await FavoritesService.toggleFavorite(route);
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
                      Text('Arrêts', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      StopsListWidget(
                        stops: (trip['stops'] as List).cast<Map<String, dynamic>>(),
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
          ],
        ),
      ),
    );
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

