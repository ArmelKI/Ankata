import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../data/sotraco_data.dart';
import '../../data/sotraco_tarifs_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SotracoHomeScreen extends StatefulWidget {
  const SotracoHomeScreen({super.key});

  @override
  State<SotracoHomeScreen> createState() => _SotracoHomeScreenState();
}

class _SotracoHomeScreenState extends State<SotracoHomeScreen> {
  String _selectedCity = 'Ouagadougou';
  String _stopQuery = '';
  String _selectedLineType = 'Toutes';
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  static const Map<String, LatLng> _cityCenters = {
    'Ouagadougou': LatLng(12.3681, -1.5271),
    'Bobo-Dioulasso': LatLng(11.1771, -4.2979),
    'Koudougou': LatLng(12.2533, -2.3628),
    'Ouahigouya': LatLng(13.5753, -2.4072),
    'Dédougou': LatLng(12.4530, -3.4610),
    'Banfora': LatLng(10.6325, -4.7625),
  };

  static const List<Color> _lineColors = [
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFF44336),
    Color(0xFF3F51B5),
    Color(0xFF8BC34A),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
    Color(0xFF795548),
    Color(0xFFCDDC39),
    Color(0xFF009688),
    Color(0xFF673AB7),
    Color(0xFFFFEB3B),
    Color(0xFF03A9F4),
    Color(0xFFE040FB),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() =>
          _currentPosition = LatLng(position.latitude, position.longitude));
    }
  }

  List<SotracoLine> get _filteredLines {
    var lines = SotracoData.getLinesByCity(_selectedCity);
    if (_selectedLineType == 'Ordinaire')
      lines = SotracoData.getOrdinaryLines(_selectedCity);
    if (_selectedLineType == 'Intercommunale')
      lines = SotracoData.getIntercommunalLines(_selectedCity);
    if (_selectedLineType == 'Étudiants')
      lines = SotracoData.getStudentLines(_selectedCity);
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () {
              if (context.canPop())
                context.pop();
              else
                context.go('/home');
            },
          ),
          title: Row(
            children: [
              const Icon(Icons.directions_bus,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text('SOTRACO', style: AppTextStyles.h3),
              const Spacer(),
              // City Selector
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    icon: const Icon(Icons.expand_more,
                        size: 18, color: AppColors.primary),
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                    isDense: true,
                    items: SotracoData.cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedCity = v);
                        final center = _cityCenters[v];
                        if (center != null) {
                          _mapController.move(center, 13.0);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.map, size: 20), text: 'Carte'),
              Tab(icon: Icon(Icons.list, size: 20), text: 'Lignes'),
              Tab(icon: Icon(Icons.location_on, size: 20), text: 'Arrêts'),
              Tab(icon: Icon(Icons.payment, size: 20), text: 'Tarifs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMapTab(),
            _buildLinesListTab(),
            _buildStopsTab(),
            _buildTarifsTab(),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: Carte avec toutes les lignes ──
  Widget _buildMapTab() {
    final lines = _filteredLines;
    final center =
        _cityCenters[_selectedCity] ?? const LatLng(12.3681, -1.5271);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              initialCenter: _currentPosition ?? center, initialZoom: 13.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ankata.app',
            ),
            PolylineLayer(
              polylines: lines.asMap().entries.map((entry) {
                final color = _lineColors[entry.key % _lineColors.length];
                return Polyline(
                  points: entry.value.coordinates,
                  color: color.withValues(alpha: 0.85),
                  strokeWidth: 4.0,
                );
              }).toList(),
            ),
            if (_currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location,
                        color: Colors.blue, size: 30),
                  ),
                ],
              ),
          ],
        ),
        // Filter chips
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Toutes', 'Ordinaire', 'Intercommunale', 'Étudiants']
                  .map((type) {
                final isSelected = _selectedLineType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type,
                        style: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.charcoal,
                            fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    elevation: 2,
                    onSelected: (_) => setState(() => _selectedLineType = type),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Bottom line cards carousel
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: lines.length,
            itemBuilder: (ctx, i) {
              final line = lines[i];
              final color = _lineColors[i % _lineColors.length];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (line.coordinates.isNotEmpty)
                        _mapController.move(line.coordinates.first, 14.5);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(line.code,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(line.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ]),
                          const Spacer(),
                          Row(children: [
                            Icon(Icons.place, size: 14, color: AppColors.gray),
                            const SizedBox(width: 4),
                            Text('${line.stopsCount} arrêts',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.gray)),
                            const SizedBox(width: 12),
                            Icon(Icons.schedule,
                                size: 14, color: AppColors.gray),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(line.frequency,
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.gray),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: 4),
                          Text('${line.firstDeparture} → ${line.lastDeparture}',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── TAB 2: Liste de toutes les lignes ──
  Widget _buildLinesListTab() {
    final lines = _filteredLines;
    if (lines.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.info_outline, size: 48, color: AppColors.gray),
          const SizedBox(height: 12),
          Text('Aucune ligne pour $_selectedCity',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray)),
        ]),
      );
    }
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Toutes', 'Ordinaire', 'Intercommunale', 'Étudiants']
                  .map((type) {
                final isSelected = _selectedLineType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type,
                        style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : AppColors.charcoal)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => setState(() => _selectedLineType = type),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lines.length,
            itemBuilder: (ctx, i) {
              final line = lines[i];
              final color = _lineColors[i % _lineColors.length];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(line.code,
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11))),
                  ),
                  title: Text(line.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(children: [
                      _infoChip(Icons.place, '${line.stopsCount} arrêts'),
                      const SizedBox(width: 8),
                      _infoChip(Icons.schedule, line.frequency),
                    ]),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: line.type == 'Ordinaire'
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : line.type == 'Intercommunale'
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      line.type == 'Spéciale Étudiants'
                          ? 'Étud.'
                          : line.type.substring(
                              0, (line.type.length > 5 ? 5 : line.type.length)),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: line.type == 'Ordinaire'
                              ? AppColors.primary
                              : line.type == 'Intercommunale'
                                  ? Colors.orange
                                  : Colors.purple),
                    ),
                  ),
                  onTap: () => context.push('/sotraco/line/${line.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.gray),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11, color: AppColors.gray)),
    ]);
  }

  // ── TAB 3: Recherche d'arrêts ──
  Widget _buildStopsTab() {
    final allStops = SotracoData.getStopsByCity(_selectedCity);
    final filteredStops = allStops
        .where((s) => s.toLowerCase().contains(_stopQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un arrêt à $_selectedCity...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (v) => setState(() => _stopQuery = v),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('${filteredStops.length} arrêts trouvés',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredStops.length,
            itemBuilder: (ctx, i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.location_on,
                        color: AppColors.primary, size: 18),
                  ),
                  title: Text(filteredStops[i],
                      style: const TextStyle(fontSize: 14)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── TAB 4: Tarifs ──
  Widget _buildTarifsTab() {
    final categories = SotracoTarifsData.getCategories(_selectedCity);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.7)
            ]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Horaires de service',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                ...SotracoTarifsData.serviceHours.entries.map((e) => Text(
                      '${e.key}: ${e.value}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    )),
              ],
            )),
          ]),
        ),
        const SizedBox(height: 16),
        // Tarif sections by category
        ...categories.map((cat) {
          final tarifs =
              SotracoTarifsData.getTarifsByCategory(_selectedCity, cat);
          final isIntercommunal = cat == 'Lignes intercommunales';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Icon(
                    isIntercommunal
                        ? Icons.directions_bus
                        : cat.contains('Élèves')
                            ? Icons.school
                            : Icons.person,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(cat,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                ]),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6)
                  ],
                ),
                child: Column(
                  children: tarifs.asMap().entries.map((entry) {
                    final t = entry.value;
                    return Column(children: [
                      ListTile(
                        dense: true,
                        title: Text(t.typeTarif,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: t.typeTarif.contains('Abonnement')
                            ? Text('Valide pour la période indiquée',
                                style: AppTextStyles.caption)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.montant,
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _handlePayment(context, t),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                minimumSize: const Size(60, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                t.typeTarif.contains('Abonnement')
                                    ? 'S\'abonner'
                                    : 'Acheter',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (entry.key < tarifs.length - 1)
                        const Divider(height: 1),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  void _handlePayment(BuildContext context, SotracoTarif tarif) {
    // Parse amount from string like "200 F CFA" or "1 000 F CFA"
    final amountString = tarif.montant.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(amountString) ?? 0;

    context.push('/payment', extra: {
      'amount': amount,
      'bookingId':
          'SOTRACO-${tarif.ville}-${DateTime.now().millisecondsSinceEpoch}',
      'tripDetails': 'SOTRACO ${tarif.ville} - ${tarif.typeTarif}',
    });
  }
}
