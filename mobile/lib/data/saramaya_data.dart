import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class SaramayaData {
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 356,
      durationMinutes: 330,
      priceStandard: 6500,
      priceVip: 8000,
      departures: [
        DepartureTime(time: '07:30'),
        DepartureTime(time: '09:30'),
        DepartureTime(time: '12:30'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '18:30'),
        DepartureTime(time: '22:30'),
        DepartureTime(time: '23:45'),
      ],
    ),
  ];

  static const List<RouteSchedule> _boboRoutes = [
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Ouagadougou',
      distanceKm: 356,
      durationMinutes: 330,
      priceStandard: 6500,
      priceVip: 8000,
      departures: [
        DepartureTime(time: '07:30'),
        DepartureTime(time: '09:30'),
        DepartureTime(time: '12:30'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '18:30'),
        DepartureTime(time: '22:30'),
        DepartureTime(time: '23:45'),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'saramaya',
    name: 'SARAMAYA',
    logo: 'assets/images/saramaya_logo.png',
    color: Color(0xFFE91E63),
    address: 'Gare SARAMAYA, Bobo-Dioulasso',
    phones: ['+226 74 00 00 00'],
    email: 'contact@saramaya-transport.bf',
    services: [
      'Liaison Ouaga-Bobo',
      'Confort Standard',
      'Securite garantie',
    ],
    photos: [],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare SARAMAYA Ouaga',
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare SARAMAYA',
        routes: _boboRoutes,
      ),
    },
  );
}
