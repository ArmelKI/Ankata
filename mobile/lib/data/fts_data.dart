import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class FtsData {
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 356,
      durationMinutes: 330,
      priceStandard: 7500,
      priceVip: 9000,
      departures: [
        DepartureTime(time: '07:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '14:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Lomé',
      distanceKm: 990,
      durationMinutes: 1080,
      priceStandard: 15000,
      departures: [
        DepartureTime(time: '04:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _boboRoutes = [
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Ouagadougou',
      distanceKm: 356,
      durationMinutes: 330,
      priceStandard: 7500,
      priceVip: 9000,
      departures: [
        DepartureTime(time: '07:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '14:00'),
      ],
    ),
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Dédougou',
      distanceKm: 110,
      durationMinutes: 120,
      priceStandard: 3500,
      departures: [
        DepartureTime(time: '06:15'),
        DepartureTime(time: '13:15'),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'fts',
    name: 'FTS',
    logo: 'assets/images/fts_logo.png',
    color: Color(0xFFFF5722),
    address: 'Gare FTS, Ouagadougou',
    phones: ['+226 73 00 00 00'],
    email: 'contact@fts-transport.bf',
    services: [
      'Transport national et international',
      'Service VIP disponible',
    ],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare FTS',
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare FTS Bobo',
        routes: _boboRoutes,
      ),
    },
  );
}
