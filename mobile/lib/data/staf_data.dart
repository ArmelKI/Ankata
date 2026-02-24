import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class StafData {
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 356,
      durationMinutes: 300,
      priceStandard: 5000,
      departures: [
        DepartureTime(time: '06:30'),
        DepartureTime(time: '13:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Koudougou',
      distanceKm: 99,
      durationMinutes: 90,
      priceStandard: 2500,
      departures: [
        DepartureTime(time: '07:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _boboRoutes = [
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Ouagadougou',
      distanceKm: 356,
      durationMinutes: 300,
      priceStandard: 5000,
      departures: [
        DepartureTime(time: '08:00'),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'staf',
    name: 'STAF',
    logo: 'assets/images/staf_logo.png',
    color: Color(0xFF4CAF50),
    address: 'Gare STAF, Bobo-Dioulasso',
    phones: ['+226 20 98 42 12'],
    services: [
      'Interurbain',
      'Prix bas',
    ],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare STAF Ouaga',
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare STAF Bobo',
        routes: _boboRoutes,
      ),
    },
  );
}
