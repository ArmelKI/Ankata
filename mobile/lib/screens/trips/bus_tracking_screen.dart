import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_theme.dart';

class BusTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  const BusTrackingScreen({Key? key, required this.ticketData})
      : super(key: key);

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  late final MapController _mapController;
  Timer? _timer;
  double _progress = 0.0;

  // Mock Route: Ouagadougou to Bobo-Dioulasso
  final List<LatLng> _routePoints = [
    const LatLng(12.3656, -1.5197), // Ouaga
    const LatLng(12.2592, -2.3707), // Koudougou
    const LatLng(11.7500, -3.2500), // Boromo
    const LatLng(11.1847, -4.2695), // Bobo
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.005;
        if (_progress > 1.0) _progress = 0.0;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  LatLng _getCurrentBusLocation() {
    if (_routePoints.isEmpty) return const LatLng(0, 0);

    // Find the current segment
    int segmentsCount = _routePoints.length - 1;
    double segmentProgress = _progress * segmentsCount;
    int currentSegmentIndex = segmentProgress.floor();
    double t = segmentProgress - currentSegmentIndex;

    if (currentSegmentIndex >= segmentsCount) return _routePoints.last;

    LatLng start = _routePoints[currentSegmentIndex];
    LatLng end = _routePoints[currentSegmentIndex + 1];

    double lat = start.latitude + (end.latitude - start.latitude) * t;
    double lng = start.longitude + (end.longitude - start.longitude) * t;

    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final busPos = _getCurrentBusLocation();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suivi du bus en direct'),
            Text(
              '${widget.ticketData['company'] ?? 'Bus'} - ${widget.ticketData['from']} → ${widget.ticketData['to']}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _routePoints[0],
              initialZoom: 7.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ankata.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: AppColors.primary.withOpacity(0.5),
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Origin
                  Marker(
                    point: _routePoints.first,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on,
                        color: Colors.green, size: 30),
                  ),
                  // Destination
                  Marker(
                    point: _routePoints.last,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.flag,
                        color: AppColors.error, size: 30),
                  ),
                  // Bus
                  Marker(
                    point: busPos,
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                        const Icon(Icons.directions_bus,
                            color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Info Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusMd,
                boxShadow: AppShadows.shadow3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chauffeur: Moussa Diallo',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.bold)),
                            Text('Bus: BX-567-TG',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Arrivée estimée', style: AppTextStyles.caption),
                          Text('16:45 (dans 45 min)',
                              style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _mapController.move(busPos, 12.0);
                        },
                        style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12)),
                        child: const Text('Centrer'),
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
}
