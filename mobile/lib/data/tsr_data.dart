import 'package:flutter/material.dart';
import '../models/transport_company.dart';

class TSRData {
  static const TransportCompany company = TransportCompany(
    id: 'tsr',
    name: 'TSR',
    logo: 'assets/images/tsr_logo.png',
    color: Color(0xFF2196F3),
    address: 'Gare Goughin & Gare Wemtenga, Ouagadougou',
    phones: ['+226 70 25 31 38', '+226 53 10 10 32'],
    email: 'info@tsr-transports.com',
    website: 'https://tsr-transports.com',
    services: [
      'Transport de voyageurs',
      'Expedition de colis',
      'Bus climatises',
      'Service VIP',
    ],
    photos: [
      'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
      'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=800',
      'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
    ],
    stations: {
      'Ouagadougou': CompanyStation(
        city: 'Ouagadougou',
        address: 'Gare Goughin & Gare Wemtenga',
        latitude: 12.3714,
        longitude: -1.5197,
        routes: _ouagaRoutes,
      ),
      'Bobo-Dioulasso': CompanyStation(
        city: 'Bobo-Dioulasso',
        address: 'Gare Bobo',
        latitude: 11.1771,
        longitude: -4.2974,
        routes: _boboRoutes,
      ),
      'Gaoua': CompanyStation(
        city: 'Gaoua',
        address: 'Gare Gaoua',
        routes: _gaouaRoutes,
      ),
      'Ouahigouya': CompanyStation(
        city: 'Ouahigouya',
        address: 'Gare Ouahigouya',
        routes: _ouahigouyaRoutes,
      ),
      'Koudougou': CompanyStation(
        city: 'Koudougou',
        address: 'Gare Koudougou',
        routes: _koudougouRoutes,
      ),
      'Kaya': CompanyStation(
        city: 'Kaya',
        address: 'Centre ville',
        routes: _kayaRoutes,
      ),
      'Dédougou': CompanyStation(
        city: 'Dédougou',
        address: 'Gare Dédougou',
        routes: _dedougouRoutes,
      ),
      'Dori': CompanyStation(
        city: 'Dori',
        address: 'Gare Dori',
        routes: _doriRoutes,
      ),
      'Fada N\'Gourma': CompanyStation(
        city: 'Fada N\'Gourma',
        address: 'Gare Fada',
        routes: _fadaRoutes,
      ),
      'Tenkodogo': CompanyStation(
        city: 'Tenkodogo',
        address: 'Gare Tenkodogo',
        routes: _tenkodogoRoutes,
      ),
      'Léo': CompanyStation(
        city: 'Léo',
        address: 'Gare Léo',
        routes: _leoRoutes,
      ),
      'Zabré': CompanyStation(
        city: 'Zabré',
        address: 'Gare Zabré',
        routes: _zabreRoutes,
      ),
      'Kongoussi': CompanyStation(
        city: 'Kongoussi',
        address: 'Gare Kongoussi',
        routes: _kongoussiRoutes,
      ),
      'Hamélé': CompanyStation(
        city: 'Hamélé',
        address: 'Gare Hamélé',
        routes: _hameleRoutes,
      ),
    },
  );

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
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '15:00'),
        DepartureTime(time: '18:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Gaoua',
      distanceKm: 392,
      durationMinutes: 420,
      priceStandard: 6500,
      departures: [
        DepartureTime(time: '07:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '15:00'),
        DepartureTime(time: '18:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Ouahigouya',
      distanceKm: 182,
      durationMinutes: 195,
      priceStandard: 2500,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:30'),
        DepartureTime(time: '11:00'),
        DepartureTime(time: '13:00'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '16:00'),
        DepartureTime(time: '18:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Koudougou',
      distanceKm: 99,
      durationMinutes: 120,
      priceStandard: 3000,
      departures: [
        DepartureTime(time: '06:30'),
        DepartureTime(time: '08:30'),
        DepartureTime(time: '09:30'),
        DepartureTime(time: '11:30'),
        DepartureTime(time: '13:30'),
        DepartureTime(time: '15:30'),
        DepartureTime(time: '17:30'),
        DepartureTime(time: '18:30'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Kaya',
      distanceKm: 102,
      durationMinutes: 90,
      priceStandard: 3000,
      departures: [
        DepartureTime(time: '05:00'),
        DepartureTime(time: '06:00'),
        DepartureTime(time: '07:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '11:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '13:00'),
        DepartureTime(time: '14:00'),
        DepartureTime(time: '15:00'),
        DepartureTime(time: '16:00'),
        DepartureTime(time: '17:00'),
        DepartureTime(time: '18:00'),
        DepartureTime(time: '19:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Dori',
      distanceKm: 268,
      durationMinutes: 300,
      priceStandard: 6000,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '13:30'),
        DepartureTime(time: '15:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Fada N\'Gourma',
      distanceKm: 224,
      durationMinutes: 240,
      priceStandard: 5500,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '16:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Tenkodogo',
      distanceKm: 185,
      durationMinutes: 220,
      priceStandard: 4500,
      departures: [
        DepartureTime(time: '05:30'),
        DepartureTime(time: '06:30'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '11:00'),
        DepartureTime(time: '14:30'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Dédougou',
      distanceKm: 231,
      durationMinutes: 210,
      priceStandard: 5000,
      departures: [
        DepartureTime(time: '07:00'),
        DepartureTime(time: '14:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Léo',
      distanceKm: 167,
      durationMinutes: 180,
      priceStandard: 4000,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '14:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Kongoussi',
      distanceKm: 115,
      durationMinutes: 120,
      priceStandard: 2500,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '07:00'),
        DepartureTime(time: '08:30'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '13:00'),
        DepartureTime(time: '16:00'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Zabré',
      distanceKm: 177,
      durationMinutes: 180,
      priceStandard: 3000,
      departures: [
        DepartureTime(time: '06:30'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '15:30'),
      ],
    ),
    RouteSchedule(
      from: 'Ouagadougou',
      to: 'Hamélé',
      distanceKm: 255,
      durationMinutes: 300,
      priceStandard: 0,
      departures: [],
      isActive: false,
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
        DepartureTime(time: '05:30'),
        DepartureTime(time: '06:30'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '11:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '13:00'),
        DepartureTime(time: '14:00'),
        DepartureTime(time: '15:00'),
        DepartureTime(time: '16:00'),
        DepartureTime(time: '17:00'),
        DepartureTime(time: '21:00'),
        DepartureTime(time: '22:30'),
      ],
    ),
  ];

  static const List<RouteSchedule> _gaouaRoutes = [
    RouteSchedule(
      from: 'Gaoua',
      to: 'Ouagadougou',
      distanceKm: 392,
      durationMinutes: 420,
      priceStandard: 6500,
      departures: [
        DepartureTime(time: '07:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '15:00'),
        DepartureTime(time: '18:00'),
      ],
    ),
    RouteSchedule(
      from: 'Gaoua',
      to: 'Bobo-Dioulasso',
      distanceKm: 150,
      durationMinutes: 150,
      priceStandard: 3500,
      departures: [
        DepartureTime(time: '08:00'),
        DepartureTime(time: '15:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _ouahigouyaRoutes = [
    RouteSchedule(
      from: 'Ouahigouya',
      to: 'Ouagadougou',
      distanceKm: 182,
      durationMinutes: 195,
      priceStandard: 2500,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:30'),
        DepartureTime(time: '11:00'),
        DepartureTime(time: '13:00'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '16:00'),
        DepartureTime(time: '18:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _koudougouRoutes = [
    RouteSchedule(
      from: 'Koudougou',
      to: 'Ouagadougou',
      distanceKm: 99,
      durationMinutes: 120,
      priceStandard: 3000,
      departures: [
        DepartureTime(time: '06:30'),
        DepartureTime(time: '08:30'),
        DepartureTime(time: '09:30'),
        DepartureTime(time: '11:30'),
        DepartureTime(time: '13:30'),
        DepartureTime(time: '15:30'),
        DepartureTime(time: '17:30'),
        DepartureTime(time: '18:30'),
      ],
    ),
    RouteSchedule(
      from: 'Koudougou',
      to: 'Bobo-Dioulasso',
      distanceKm: 257,
      durationMinutes: 300,
      priceStandard: 6000,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '13:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _kayaRoutes = [
    RouteSchedule(
      from: 'Kaya',
      to: 'Ouagadougou',
      distanceKm: 102,
      durationMinutes: 90,
      priceStandard: 3000,
      departures: [
        DepartureTime(time: '05:00'),
        DepartureTime(time: '06:00'),
        DepartureTime(time: '07:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '11:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '13:00'),
        DepartureTime(time: '14:00'),
        DepartureTime(time: '15:00'),
        DepartureTime(time: '16:00'),
        DepartureTime(time: '17:00'),
        DepartureTime(time: '18:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _dedougouRoutes = [
    RouteSchedule(
      from: 'Dédougou',
      to: 'Ouagadougou',
      distanceKm: 231,
      durationMinutes: 210,
      priceStandard: 5000,
      departures: [
        DepartureTime(time: '05:30'),
        DepartureTime(time: '06:30'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '14:00'),
        DepartureTime(time: '16:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _doriRoutes = [
    RouteSchedule(
      from: 'Dori',
      to: 'Ouagadougou',
      distanceKm: 268,
      durationMinutes: 300,
      priceStandard: 6000,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '13:30'),
        DepartureTime(time: '15:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _fadaRoutes = [
    RouteSchedule(
      from: 'Fada N\'Gourma',
      to: 'Ouagadougou',
      distanceKm: 224,
      durationMinutes: 240,
      priceStandard: 5500,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:30'),
        DepartureTime(time: '10:30'),
        DepartureTime(time: '12:30'),
        DepartureTime(time: '14:30'),
        DepartureTime(time: '16:30'),
      ],
    ),
  ];

  static const List<RouteSchedule> _tenkodogoRoutes = [
    RouteSchedule(
      from: 'Tenkodogo',
      to: 'Ouagadougou',
      distanceKm: 185,
      durationMinutes: 220,
      priceStandard: 4500,
      departures: [
        DepartureTime(time: '05:30'),
        DepartureTime(time: '06:30'),
        DepartureTime(time: '09:00'),
        DepartureTime(time: '11:00'),
        DepartureTime(time: '14:30'),
      ],
    ),
  ];

  static const List<RouteSchedule> _leoRoutes = [
    RouteSchedule(
      from: 'Léo',
      to: 'Ouagadougou',
      distanceKm: 167,
      durationMinutes: 180,
      priceStandard: 4000,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '08:00'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '14:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _zabreRoutes = [
    RouteSchedule(
      from: 'Zabré',
      to: 'Ouagadougou',
      distanceKm: 177,
      durationMinutes: 180,
      priceStandard: 3000,
      departures: [
        DepartureTime(time: '06:30'),
        DepartureTime(time: '12:00'),
        DepartureTime(time: '15:30'),
      ],
    ),
  ];

  static const List<RouteSchedule> _kongoussiRoutes = [
    RouteSchedule(
      from: 'Kongoussi',
      to: 'Ouagadougou',
      distanceKm: 115,
      durationMinutes: 120,
      priceStandard: 2500,
      departures: [
        DepartureTime(time: '06:00'),
        DepartureTime(time: '07:00'),
        DepartureTime(time: '08:30'),
        DepartureTime(time: '10:00'),
        DepartureTime(time: '13:00'),
        DepartureTime(time: '16:00'),
      ],
    ),
  ];

  static const List<RouteSchedule> _hameleRoutes = [
    RouteSchedule(
      from: 'Hamélé',
      to: 'Ouagadougou',
      distanceKm: 255,
      durationMinutes: 300,
      priceStandard: 0,
      departures: [],
      isActive: false,
    ),
  ];
}
