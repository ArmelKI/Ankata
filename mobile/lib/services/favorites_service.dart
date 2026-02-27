import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_routes';

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> toggleFavorite(Map<String, dynamic> route) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final encoded = jsonEncode(route);

    if (raw.contains(encoded)) {
      raw.remove(encoded);
    } else {
      raw.insert(0, encoded);
    }

    await prefs.setStringList(_key, raw);
  }

  static Future<bool> isFavorite(Map<String, dynamic> route) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.contains(jsonEncode(route));
  }
}
