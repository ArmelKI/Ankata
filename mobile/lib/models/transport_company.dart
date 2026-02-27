import 'package:flutter/material.dart';

/// Modèle complet pour une compagnie de transport
class TransportCompany {
  final String id;
  final String name;
  final String? logo; // Path vers le logo (assets ou network)
  final Color color;
  final String address;
  final List<String> phones;
  final String? email;
  final String? website;
  final List<String> services;
  final List<String> photos;
  final Map<String, CompanyStation> stations; // Ville -> Station info

  const TransportCompany({
    required this.id,
    required this.name,
    this.logo,
    required this.color,
    required this.address,
    required this.phones,
    this.email,
    this.website,
    this.services = const [],
    this.photos = const [],
    this.stations = const {},
  });
}

/// Information sur une station/gare d'une compagnie
class CompanyStation {
  final String city;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final List<RouteSchedule> routes;

  const CompanyStation({
    required this.city,
    required this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.routes = const [],
  });
}

/// Horaires pour une liaison donnée
class RouteSchedule {
  final String from;
  final String to;
  final int distanceKm;
  final int durationMinutes;
  final List<DepartureTime> departures;
  final int priceStandard; // Prix en FCFA
  final int? priceVip;
  final bool isActive;

  const RouteSchedule({
    required this.from,
    required this.to,
    required this.distanceKm,
    required this.durationMinutes,
    required this.departures,
    required this.priceStandard,
    this.priceVip,
    this.isActive = true,
  });
}

class DepartureTime {
  final String time; // "08:30"
  final bool isVip;
  final String? gareSpecific; // "Goughin", "Wemtenga", etc.

  const DepartureTime({
    required this.time,
    this.isVip = false,
    this.gareSpecific,
  });
}
