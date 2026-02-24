import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _key = 'recent_searches';
  static const int _maxItems = 5;

  static Future<List<Map<String, dynamic>>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final results = <Map<String, dynamic>>[];
    final valid = <String>[];
    for (final item in raw) {
      try {
        results.add(jsonDecode(item) as Map<String, dynamic>);
        valid.add(item);
      } on FormatException {
        // Skip invalid entries
      }
    }
    if (valid.length != raw.length) {
      await prefs.setStringList(_key, valid);
    }
    return results;
  }

  static Future<void> addSearch(Map<String, dynamic> search) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final encoded = jsonEncode(search);

    existing.remove(encoded);
    existing.insert(0, encoded);

    if (existing.length > _maxItems) {
      existing.removeRange(_maxItems, existing.length);
    }

    await prefs.setStringList(_key, existing);
  }
}
