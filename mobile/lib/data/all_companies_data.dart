import '../models/transport_company.dart';
import 'tsr_data.dart';
import 'elitis_data.dart';
import 'saramaya_data.dart';
import 'rakieta_data.dart';
import 'fts_data.dart';
import 'ctke_data.dart';
import 'staf_data.dart';
import 'rahimo_data.dart';
import 'tcv_data.dart';

class AllCompaniesData {
  static const TransportCompany tsr = TSRData.company;
  static const TransportCompany elitisExpress = ElitisData.company;
  static const TransportCompany saramaya = SaramayaData.company;
  static const TransportCompany rakieta = RakietaData.company;
  static const TransportCompany fts = FtsData.company;
  static const TransportCompany ctkeWays = CtkeData.company;
  static const TransportCompany staf = StafData.company;
  static const TransportCompany rahimo = RahimoData.company;
  static const TransportCompany tcv = TcvData.company;

  /// Liste des compagnies de transport interurbain (SOTRACO exclu - transport urbain)
  static List<TransportCompany> getAllCompanies() {
    return [
      tsr,
      staf,
      rahimo,
      rakieta,
      tcv,
      saramaya,
      elitisExpress,
      ctkeWays,
      fts,
    ];
  }

  static TransportCompany? getCompanyById(String id) {
    final companies = {
      'tsr': tsr,
      'staf': staf,
      'rahimo': rahimo,
      'rakieta': rakieta,
      'tcv': tcv,
      'saramaya': saramaya,
      'elitis': elitisExpress,
      'ctke': ctkeWays,
      'fts': fts,
    };
    return companies[id.toLowerCase()];
  }

  static List<String> getAllCities() {
    final cities = <String>{};
    for (final company in getAllCompanies()) {
      cities.addAll(company.stations.keys);
    }
    return cities.toList()..sort();
  }

  static List<TransportCompany> getCompaniesBetween(String from, String to) {
    final companies = <TransportCompany>[];
    for (final company in getAllCompanies()) {
      final station = company.stations[from];
      if (station == null) continue;
      final hasRoute = station.routes
          .any((route) => route.to == to && route.departures.isNotEmpty);
      if (hasRoute) {
        companies.add(company);
      }
    }
    return companies;
  }

  static Map<String, List<TransportCompany>> getDestinationsFrom(String city) {
    final destinations = <String, List<TransportCompany>>{};
    for (final company in getAllCompanies()) {
      final station = company.stations[city];
      if (station != null) {
        for (final route in station.routes) {
          if (route.departures.isEmpty) continue;
          destinations.putIfAbsent(route.to, () => []).add(company);
        }
      }
    }
    return destinations;
  }
}
