import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_theme.dart';
import '../../data/all_companies_data.dart';
import '../../models/transport_company.dart';
import '../../utils/haptic_helper.dart';

class StationMapsScreen extends StatefulWidget {
  const StationMapsScreen({super.key});

  @override
  State<StationMapsScreen> createState() => _StationMapsScreenState();
}

class _StationMapsScreenState extends State<StationMapsScreen> {
  String _selectedCity = 'Ouagadougou';
  late List<String> _cities;

  @override
  void initState() {
    super.initState();
    _cities = AllCompaniesData.getAllCities();
    if (!_cities.contains(_selectedCity) && _cities.isNotEmpty) {
      _selectedCity = _cities.first;
    }
  }

  Future<void> _openMap(double lat, double lng, String label) async {
    final uri = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companies = AllCompaniesData.getAllCompanies();
    final stationsInCity = <Map<String, dynamic>>[];

    for (final company in companies) {
      final station = company.stations[_selectedCity];
      if (station != null) {
        stationsInCity.add({
          'company': company,
          'station': station,
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Gares & Stations'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.charcoal,
      ),
      body: Column(
        children: [
          _buildCitySelector(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: stationsInCity.length,
              itemBuilder: (context, index) {
                final item = stationsInCity[index];
                final company = item['company'] as TransportCompany;
                final station = item['station'] as CompanyStation;
                return _buildStationCard(company, station);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      height: 60,
      color: AppColors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = city == _selectedCity;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  HapticHelper.selectionClick();
                  setState(() => _selectedCity = city);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.charcoal,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStationCard(TransportCompany company, CompanyStation station) {
    final hasCoords = station.latitude != null && station.longitude != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: AppShadows.shadow1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: company.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.business, color: company.color, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        station.city,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.gray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: AppColors.gray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    station.address,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
            if (station.phone != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 18, color: AppColors.gray),
                  const SizedBox(width: 8),
                  Text(
                    station.phone!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasCoords
                    ? () => _openMap(
                        station.latitude!, station.longitude!, station.address)
                    : null,
                icon: const Icon(Icons.directions),
                label: Text(hasCoords ? 'Y aller' : 'Position non disponible'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasCoords ? AppColors.primary : AppColors.gray,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
