import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';

class TripSearchScreen extends StatefulWidget {
  final String originCity;
  final String destinationCity;
  final String departureDate;
  final int passengers;

  const TripSearchScreen({
    Key? key,
    required this.originCity,
    required this.destinationCity,
    required this.departureDate,
    required this.passengers,
  }) : super(key: key);

  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _trips = [];

  @override
  void initState() {
    super.initState();
    _searchTrips();
  }

  Future<void> _searchTrips() async {
    setState(() => _isLoading = true);
    
    // Simuler recherche API
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _trips = _buildTripsForRoute(
        widget.originCity,
        widget.destinationCity,
        widget.departureDate,
      );
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _buildTripsForRoute(
    String origin,
    String destination,
    String date,
  ) {
    if (origin.isEmpty || destination.isEmpty || origin == destination) {
      return [];
    }

    final baseTrips = [
      {
        'id': 'TSR-1',
        'company': 'TSR',
        'departure': '08:00',
        'arrival': '13:00',
        'duration': '5h 00min',
        'price': 7500,
        'availableSeats': 12,
        'rating': 4.3,
        'amenities': ['AC', 'WiFi', 'Bagages'],
      },
      {
        'id': 'RAHIMO-2',
        'company': 'RAHIMO',
        'departure': '09:30',
        'arrival': '14:30',
        'duration': '5h 00min',
        'price': 9500,
        'availableSeats': 8,
        'rating': 4.6,
          'amenities': ['AC', 'WiFi', 'Bagages', 'Snack'],
      },
      {
        'id': 'RAKIETA-3',
        'company': 'RAKIETA',
        'departure': '12:00',
        'arrival': '17:00',
        'duration': '5h 00min',
        'price': 8000,
        'availableSeats': 22,
        'rating': 4.1,
        'amenities': ['AC', 'Bagages'],
      },
      {
        'id': 'STAF-4',
        'company': 'STAF',
        'departure': '14:00',
        'arrival': '18:50',
        'duration': '4h 50min',
        'price': 8500,
        'availableSeats': 15,
        'rating': 4.1,
        'amenities': ['AC', 'WiFi', 'Bagages'],
      },
    ];

    final seed = origin.length + destination.length;
    return baseTrips
      .map((trip) => {
          ...trip,
          'price': (trip['price'] as int) + (seed * 25),
          'companyColor': CompanyColors.getCompanyColor(trip['company'] as String),
          'from': origin,
          'to': destination,
          'date': date,
              'passengers': widget.passengers,
        })
      .toList();
  }

  void _safePop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
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
              style: AppTextStyles.h4,
            ),
            Text(
              widget.departureDate,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.charcoal),
            onPressed: () {
              // TODO: Filtres
            },
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildTripsList(),
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
                    const SizedBox(height: AppSpacing.sm),
                    _buildShimmer(80, 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmer(100, 20),
              _buildShimmer(80, 32),
            ],
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
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildTripsList() {
    if (_trips.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header résultats
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_trips.length} trajets disponibles',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text('Trier par', style: AppTextStyles.bodySmall),
                  const SizedBox(width: AppSpacing.sm),
                  DropdownButton<String>(
                    value: 'Prix',
                    underline: const SizedBox(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    items: ['Prix', 'Heure', 'Durée', 'Note']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      // TODO: Tri
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _trips.length,
            itemBuilder: (context, index) => _buildTripCard(_trips[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.shadow1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.radiusMd,
          onTap: () {
            context.push('/trip-details', extra: trip);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Header: Compagnie + Note
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: trip['companyColor'].withValues(alpha: 0.1),
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Center(
                            child: Text(
                              trip['company'][0],
                              style: AppTextStyles.h2.copyWith(
                                color: trip['companyColor'],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip['company'], style: AppTextStyles.h4),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.star, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  trip['rating'].toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (trip['availableSeats'] <= 10)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Text(
                          '${trip['availableSeats']} places',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),
                // Horaires
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Départ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Départ', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(trip['departure'], style: AppTextStyles.h3),
                        ],
                      ),
                    ),
                    // Durée
                    Column(
                      children: [
                        const Icon(Icons.arrow_forward, color: AppColors.gray, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          trip['duration'],
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                    // Arrivée
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Arrivée', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(trip['arrival'], style: AppTextStyles.h3),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Équipements
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: (trip['amenities'] as List<String>)
                      .map((amenity) => _buildAmenityChip(amenity))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),
                // Prix + Bouton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('À partir de', style: AppTextStyles.caption),
                        Text(
                          '${trip['price']} FCFA',
                          style: AppTextStyles.price,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/trip-details', extra: trip);
                      },
                      child: const Text('Sélectionner'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    IconData icon;
    switch (amenity) {
      case 'AC':
        icon = Icons.ac_unit;
        break;
      case 'WiFi':
        icon = Icons.wifi;
        break;
      case 'Bagages':
        icon = Icons.luggage;
        break;
      case 'Snack':
        icon = Icons.restaurant;
        break;
      case 'Premium':
        icon = Icons.star;
        break;
      default:
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray),
          const SizedBox(width: 4),
          Text(
            amenity,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray),
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
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.gray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun trajet disponible',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Essayez de modifier vos critères de recherche ou choisissez une autre date.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Modifier la recherche'),
            ),
          ],
        ),
      ),
    );
  }
}
