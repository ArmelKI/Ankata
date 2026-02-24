import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class CtkeData {
  // CTKE WAYS - Liaisons internationales (prix officiels confirmés)
  // Ouagadougou: départs Mardi, Jeudi, Dimanche à 18h00
  // Bobo-Dioulasso: départs Lundi, Vendredi à 05h00
  
  static const List<RouteSchedule> _ouagaRoutes = [
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Lomé',
      distanceKm: 990,
      durationMinutes: 1080,
      priceStandard: 20000,
      departures: [
        DepartureTime(time: '18:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Cotonou',
      distanceKm: 1050,
      durationMinutes: 1140,
      priceStandard: 27000,
      departures: [
        DepartureTime(time: '18:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _boboRoutes = [
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Lomé',
      distanceKm: 1150,
      durationMinutes: 1200,
      priceStandard: 27000,
      departures: [
        DepartureTime(time: '05:00'),
      ],
    ),
    RouteSchedule(
      from: 'Bobo-Dioulasso',
      to: 'Cotonou',
      distanceKm: 1210,
      durationMinutes: 1260,
      priceStandard: 37000,
      departures: [
        DepartureTime(time: '05:00'),
      ],
    ),
  ];

  static const TransportCompany company = TransportCompany(
    id: 'ctke',
    name: 'CTKE WAYS',
    logo: 'assets/images/ctke_logo.png',
    color: Color(0xFF00BCD4),
    address: 'Gare CTKE, Ouagadougou',
    phones: ['+226 72 00 00 00'],
    email: 'contact@ctke-ways.bf',
    services: [
      'Liaisons internationales',
      'Ouaga/Bobo vers Lome et Cotonou',
    ],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare CTKE',
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare CTKE Bobo',
        routes: _boboRoutes,
      ),
    },
  );
}
