import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class RakietaData {
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 356,
      durationMinutes: 330,
      priceStandard: 7500,
      priceVip: 9500,
      departures: [
        DepartureTime(time: '07:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '14:00'),
        DepartureTime(time: '18:30'),
        DepartureTime(time: '22:00'),
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
      priceVip: 9500,
      departures: [
        DepartureTime(time: '07:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '14:00'),
        DepartureTime(time: '18:30'),
        DepartureTime(time: '22:30'),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'rakieta',
    name: 'RAKIETA',
    logo: 'assets/images/rakieta_logo.png',
    color: Color(0xFF8B0000),
    address: 'Gare RAKIETA, Banfora',
    phones: ['+226 20 91 03 07'],
    email: 'info@transport-rakieta.com',
    website: 'https://transport-rakieta.com',
    services: [
      'Transport national et international',
      'Express VIP',
      'Colis et messagerie',
    ],
    photos: [],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare RAKIETA Ouaga',
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare RAKIETA Bobo',
        routes: _boboRoutes,
      ),
    },
  );
}
