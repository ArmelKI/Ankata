import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class ElitisData {
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 356,
      durationMinutes: 300,
      priceStandard: 9000,
      departures: [
        DepartureTime(time: '08:30'),
        DepartureTime(time: '10:30'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '18:30'),
        DepartureTime(time: '23:30'),
      ],
    ),
  ];

  static const List<RouteSchedule> _boboRoutes = [
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Ouagadougou',
      distanceKm: 356,
      durationMinutes: 300,
      priceStandard: 9000,
      departures: [
        DepartureTime(time: '08:30'),
        DepartureTime(time: '10:30'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '18:30'),
        DepartureTime(time: '23:30'),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'elitis',
    name: 'Elitis Express',
    logo: 'assets/images/elitis_logo.png',
    color: Color(0xFF9C27B0),
    address: 'Gare Elitis, Ouagadougou',
    phones: ['+226 71 00 00 00'],
    email: 'contact@elitis-express.bf',
    services: [
      'Liaisons Ouaga-Bobo',
      'Depart quotidiens',
      'Service Express',
    ],
    photos: [
      'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
      'https://images.unsplash.com/photo-1590674899484-13da0d1b58f5?w=800',
    ],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare Elitis',
        latitude: 12.368,
        longitude: -1.527,
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare Elitis Bobo',
        latitude: 11.183,
        longitude: -4.294,
        routes: _boboRoutes,
      ),
    },
  );
}
