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
      'id': '8',
      'name': 'TCV',
      'color': '0xFF006400',
      'rating': 4.3,
      'reviews': 521,
    },
    {
      'id': '9',
      'name': 'ELITIS EXPRESS',
      'color': '0xFF1565C0',
      'rating': 4.7,
      'reviews': 312,
    },
    {
      'id': '10',
      'name': 'SARAMAYA',
      'color': '0xFFEF6C00',
      'rating': 4.0,
      'reviews': 178,
    },
    {
      'id': '14',
      'name': 'CTKE WAYS',
      'color': '0xFF0D47A1',
      'rating': 4.4,
      'reviews': 198,
    },
    {
      'id': '15',
      'name': 'FTS',
      'color': '0xFFBF360C',
      'rating': 4.1,
      'reviews': 73,
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
    'SOTRACO': Color(0xFF00BCD4),
    'TCV': Color(0xFF006400),
    'ELITIS': Color(0xFF1565C0),
    'SARAMAYA': Color(0xFFEF6C00),
    'CTKE WAYS': Color(0xFF0D47A1),
    'FTS': Color(0xFFBF360C),
  };

  static Color getCompanyColor(String companyName) {
    return colors[companyName] ?? const Color(0xFF2196F3);
  }
}
