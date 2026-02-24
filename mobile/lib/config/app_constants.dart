// Données de référence pour Ankata

import 'package:flutter/material.dart';

/// Liste des villes Burkina Faso avec coordonnées
class AppConstants {
  static const List<String> cities = [
    'Ouagadougou',
    'Bobo-Dioulasso',
    'Koudougou',
    'Ouahigouya',
    'Kaya',
    'Gaoua',
    'Dédougou',
    'Tenkodogo',
    'Fada N\'Gourma',
    'Banfora',
    'Dori',
    'Yako',
  ];

  static const List<Map<String, dynamic>> companies = [
    {
      'id': '1',
      'name': 'SOTRACO',
      'color': '0xFF00BCD4',
      'rating': 4.5,
      'reviews': 1234,
    },
    {
      'id': '2',
      'name': 'TSR',
      'color': '0xFF2196F3',
      'rating': 4.3,
      'reviews': 156,
    },
    {
      'id': '3',
      'name': 'RAKIETA',
      'color': '0xFFFF9800',
      'rating': 4.1,
      'reviews': 89,
    },
    {
      'id': '4',
      'name': 'STAF',
      'color': '0xFF4CAF50',
      'rating': 4.1,
      'reviews': 127,
    },
    {
      'id': '5',
      'name': 'RAHIMO',
      'color': '0xFFE91E63',
      'rating': 4.6,
      'reviews': 203,
    },
    {
      'id': '6',
      'name': 'SAVANA',
      'color': '0xFF9C27B0',
      'rating': 3.8,
      'reviews': 76,
    },
    {
      'id': '7',
      'name': 'OMEGA',
      'color': '0xFFFFC107',
      'rating': 4.2,
      'reviews': 145,
    },
    {
      'id': '8',
      'name': 'TCV',
      'color': '0xFF006400',
      'rating': 4.3,
      'reviews': 521,
    },
  ];

  static const int maxReferralPeople = 15;
  static const int referralRewardFcfa = 100;
}

/// Couleurs par compagnie
class CompanyColors {
  static const Map<String, Color> colors = {
    'TSR': Color(0xFF2196F3),
    'RAKIETA': Color(0xFFFF9800),
    'STAF': Color(0xFF4CAF50),
    'RAHIMO': Color(0xFFE91E63),
    'SAVANA': Color(0xFF9C27B0),
    'OMEGA': Color(0xFFFFC107),
    'SOTRACO': Color(0xFF00BCD4),
  };

  static Color getCompanyColor(String companyName) {
    return colors[companyName] ?? const Color(0xFF2196F3);
  }
}
