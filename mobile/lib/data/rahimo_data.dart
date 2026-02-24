import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class RahimoData {
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 356,
      durationMinutes: 270,
      priceStandard: 6500,
      priceVip: 8000,
      departures: [
        DepartureTime(time: '08:00', isVip: true),
        DepartureTime(time: '16:00', isVip: true),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Kaya',
      distanceKm: 102,
      durationMinutes: 95,
      priceStandard: 2500,
      departures: [
        DepartureTime(time: '08:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _boboRoutes = [
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Ouagadougou',
      distanceKm: 356,
      durationMinutes: 270,
      priceStandard: 6500,
      priceVip: 8000,
      departures: [
        DepartureTime(time: '09:00', isVip: true),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'rahimo',
    name: 'RAHIMO',
    logo: 'assets/images/rahimo_logo.png',
    color: Color(0xFFFF9800),
    address: 'Gare RAHIMO, Bobo-Dioulasso',
    phones: ['+226 20 97 07 07'],
    services: [
      'Premium',
      'Bus climatise',
      'Service VIP',
    ],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare RAHIMO Ouaga',
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare RAHIMO Bobo',
        routes: _boboRoutes,
      ),
    },
  );
}
