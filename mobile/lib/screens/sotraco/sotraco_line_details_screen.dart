import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../config/app_theme.dart';
import '../../data/sotraco_data.dart';

class SotracoLineDetailsScreen extends StatefulWidget {
  final String lineId;

  const SotracoLineDetailsScreen({super.key, required this.lineId});

  @override
  State<SotracoLineDetailsScreen> createState() =>
      _SotracoLineDetailsScreenState();
}

class _SotracoLineDetailsScreenState extends State<SotracoLineDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = SotracoData.getLineById(widget.lineId);
    if (line == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ligne SOTRACO'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Ligne introuvable')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(line.code,
                  style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(line.name,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Carte'),
            Tab(text: 'Arrêts'),
            Tab(text: 'Infos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapTab(line),
          _buildStopsTab(line),
          _buildInfoTab(line),
        ],
      ),
    );
  }

  // ── TAB 1: Carte de la ligne ──
  Widget _buildMapTab(SotracoLine line) {
    if (line.coordinates.isEmpty) {
      return const Center(child: Text('Pas de données GPS pour cette ligne'));
    }
    final center = line.coordinates[line.coordinates.length ~/ 2];

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 14.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ankata.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: line.coordinates,
              color: AppColors.primary.withValues(alpha: 0.85),
              strokeWidth: 5.0,
            ),
          ],
        ),
        MarkerLayer(
          markers: line.stops.map((stop) {
            final isTerminus = stop.ordre == 1 || stop.ordre == line.stopsCount;
            return Marker(
              point: stop.position,
              width: isTerminus ? 40 : 28,
              height: isTerminus ? 40 : 28,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${stop.nom} — ${stop.premierDepart} → ${stop.dernierDepart}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isTerminus ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${stop.ordre}',
                      style: TextStyle(
                        fontSize: isTerminus ? 12 : 9,
                        fontWeight: FontWeight.bold,
                        color: isTerminus ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── TAB 2: Liste des arrêts avec horaires ──
  Widget _buildStopsTab(SotracoLine line) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: line.stops.length,
      itemBuilder: (ctx, i) {
        final stop = line.stops[i];
        final isFirst = i == 0;
        final isLast = i == line.stops.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline indicator
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    if (!isFirst)
                      Expanded(
                        child: Container(
                          width: 3,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: (isFirst || isLast)
                            ? AppColors.primary
                            : Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.primary, width: 2.5),
                      ),
                      child: Center(
                        child: Text(
                          '${stop.ordre}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: (isFirst || isLast)
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 3,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              // Stop info card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6, left: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.nom,
                        style: TextStyle(
                          fontWeight: (isFirst || isLast)
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                          color: (isFirst || isLast)
                              ? AppColors.primary
                              : AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 13, color: AppColors.gray),
                          const SizedBox(width: 4),
                          Text(
                            '${stop.premierDepart} → ${stop.dernierDepart}',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.gray),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              stop.frequence,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500),
                            ),
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
      },
    );
  }

  // ── TAB 3: Infos générales ──
  Widget _buildInfoTab(SotracoLine line) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.7)
            ]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line.code,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(line.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoBadge(Icons.place, '${line.stopsCount} arrêts'),
                  const SizedBox(width: 12),
                  _infoBadge(Icons.schedule, line.frequency),
                  const SizedBox(width: 12),
                  _infoBadge(Icons.category, line.type),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Service info
        _buildInfoCard('Ville', line.ville),
        const SizedBox(height: 8),
        _buildInfoCard('Type de ligne', line.type),
        const SizedBox(height: 8),
        _buildInfoCard('Premier départ', line.firstDeparture),
        const SizedBox(height: 8),
        _buildInfoCard('Dernier départ', line.lastDeparture),
        const SizedBox(height: 8),
        _buildInfoCard('Fréquence', line.frequency),
        const SizedBox(height: 8),
        _buildInfoCard('Nombre d\'arrêts', '${line.stopsCount}'),
        const SizedBox(height: 16),
        // Terminus info
        if (line.stops.isNotEmpty) ...[
          Text('Terminus',
              style: AppTextStyles.bodyLarge
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
              ],
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                    Container(
                        width: 2,
                        height: 30,
                        color: AppColors.gray.withValues(alpha: 0.3)),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.stops.first.nom,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 18),
                      Text(line.stops.last.nom,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
          Flexible(
            child: Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
