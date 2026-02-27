import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class TcvData {
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 356,
      durationMinutes: 295,
      priceStandard: 5000,
      departures: [
        DepartureTime(time: '10:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Lomé',
      distanceKm: 990,
      durationMinutes: 1080,
      priceStandard: 20000,
      departures: [
        DepartureTime(time: '06:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _lomeRoutes = [
    RouteSchedule(
      from: 'Lomé',
      to: 'Ouagadougou',
      distanceKm: 990,
      durationMinutes: 1080,
      priceStandard: 20000,
      departures: [
        DepartureTime(time: '07:00'),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'tcv',
    name: 'TCV',
    logo: 'assets/images/tcv_logo.png',
    color: Color(0xFF3F51B5),
    address: 'Gare TCV, Ouagadougou',
    phones: ['+226 25 30 43 21'],
    services: [
      'Interurbain',
      'International',
    ],
    photos: [],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare TCV Ouaga',
        routes: _ouagaRoutes,
      ),
      'Lome': CompanyStation(
        city: 'Lomé',
        address: 'Gare TCV Lomé',
        routes: _lomeRoutes,
      ),
    },
  );
}
