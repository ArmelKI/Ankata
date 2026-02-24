import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../data/sotraco_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SotracoHomeScreen extends StatefulWidget {
  const SotracoHomeScreen({super.key});

  @override
  State<SotracoHomeScreen> createState() => _SotracoHomeScreenState();
}

class _SotracoHomeScreenState extends State<SotracoHomeScreen> {
  String _stopQuery = '';
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition!, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text('SOTRACO Urbain', style: AppTextStyles.h3),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray,
            tabs: [
              Tab(text: 'Lignes'),
              Tab(text: 'Arrets'),
              Tab(text: 'Itineraire'),
              Tab(text: 'Abonnements'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLinesTab(),
            _buildStopsTab(),
            _buildItineraryTab(),
            _buildSubscriptionTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLinesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: SotracoData.lines.length,
      itemBuilder: (context, index) {
        final line = SotracoData.lines[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.radiusMd,
            boxShadow: AppShadows.shadow1,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(line.code, style: AppTextStyles.bodySmall),
            ),
            title: Text(line.name, style: AppTextStyles.bodyMedium),
            subtitle: Text(
              '${line.distanceKm} km • ${line.durationMin} min • ${line.frequency}',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
            onTap: () => context.push('/sotraco/line/${line.id}'),
          ),
        );
      },
    );
  }

  Widget _buildStopsTab() {
    final stops = SotracoData.getAllStops()
        .where((stop) => stop.toLowerCase().contains(_stopQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher un arret',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _stopQuery = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              return ListTile(
                title: Text(stop, style: AppTextStyles.bodyMedium),
                leading:
                    const Icon(Icons.location_on, color: AppColors.primary),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryTab() {
    // Coordonnées approximatives de Ouagadougou
    final ouagaCenter = const LatLng(12.3681, -1.5271);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition ?? ouagaCenter,
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ankata.app',
            ),
            MarkerLayer(
              markers: [
                if (_currentPosition != null)
                  Marker(
                    point: _currentPosition!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
              ],
            ),
          ],
        ),
        // Search Overlay
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.shadow1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.gray),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Où allez-vous ?',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Recherche de l\'arrêt proche pour "$value"...')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Action Sheet Placeholder
        Positioned(
          bottom: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calcul de l\'itinéraire...')),
              );
            },
            child: const Text('Trouver un itinéraire',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSubscriptionCard(
          title: 'Ticket unitaire',
          description: SotracoData.fareNote,
          price: '200 FCFA',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSubscriptionCard(
          title: 'Abonnement mensuel',
          description: 'Trajets urbains illimites pendant 30 jours',
          price: '12 000 FCFA',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSubscriptionCard(
          title: 'Abonnement etudiant',
          description: 'Tarif reduit pour etudiants (carte requise)',
          price: '6 000 FCFA',
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.radiusMd,
            boxShadow: AppShadows.shadow1,
          ),
          child: Text(
            'Le paiement SOTRACO sera active apres confirmation du systeme de paiement.',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String description,
    required String price,
  }) {
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
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Text(description,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
          const SizedBox(height: AppSpacing.sm),
          Text(price,
              style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
