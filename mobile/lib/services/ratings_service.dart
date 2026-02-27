import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RatingsService {
  static const String _ratingsKey = 'ratings_store';
  static List<Map<String, dynamic>> _cache = [];
  static bool _loaded = false;

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ratingsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _cache = decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } on FormatException {
        _cache = [];
      }
    }
    _loaded = true;
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ratingsKey, jsonEncode(_cache));
  }

  static Future<void> addRating({
    required String companyId,
    required String tripId,
    required int rating,
    String comment = '',
    Map<String, int>? categories,
  }) async {
    await _ensureLoaded();
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'companyId': companyId,
      'tripId': tripId,
      'rating': rating,
      'comment': comment.trim(),
      'categories': categories ?? {},
      'createdAt': DateTime.now().toIso8601String(),
    };
    _cache.insert(0, entry);
    await _save();
  }

  static Future<Map<String, dynamic>> getCompanyStats(String companyId) async {
    await _ensureLoaded();
    final ratings =
        _cache.where((item) => item['companyId'] == companyId).toList();
    if (ratings.isEmpty) {
      return {'average': 0.0, 'count': 0, 'ratings': <Map<String, dynamic>>[]};
    }
    final total = ratings.fold<int>(
        0, (sum, item) => sum + (item['rating'] as int? ?? 0));
    return {
      'average': total / ratings.length,
      'count': ratings.length,
      'ratings': ratings,
    };
  }

  static Future<List<Map<String, dynamic>>> getCompanyReviews(
      String companyId) async {
    await _ensureLoaded();
    return _cache.where((item) => item['companyId'] == companyId).toList();
  }

  static Future<List<Map<String, dynamic>>> getTripReviews(
      String tripId) async {
    await _ensureLoaded();
    return _cache.where((item) => item['tripId'] == tripId).toList();
  }

  static Future<List<Map<String, dynamic>>> attachCompanyStats(
    List<Map<String, dynamic>> trips,
  ) async {
    await _ensureLoaded();
    final statsByCompany = <String, Map<String, dynamic>>{};
    for (final trip in trips) {
      final companyId = trip['companyId'] as String?;
      if (companyId == null) continue;
      statsByCompany.putIfAbsent(companyId, () {
        final ratings =
            _cache.where((item) => item['companyId'] == companyId).toList();
        if (ratings.isEmpty) {
          return {'average': 0.0, 'count': 0};
        }
        final total = ratings.fold<int>(
            0, (sum, item) => sum + (item['rating'] as int? ?? 0));
        return {'average': total / ratings.length, 'count': ratings.length};
      });
    }

    return trips.map((trip) {
      final companyId = trip['companyId'] as String?;
      final stats = companyId != null ? statsByCompany[companyId] : null;
      return {
        ...trip,
        'rating': (stats?['average'] as double?) ?? 0.0,
        'reviews': (stats?['count'] as int?) ?? 0,
      };
    }).toList();
  }
}
