import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'xp_service.dart';

class FavoritesService {
  static const String _key = 'favorite_routes';

  static Future<List<Map<String, dynamic>>> getFavorites(
      {ApiService? api}) async {
    if (api != null) {
      try {
        final backendFavorites = await api.getFavorites();
        // Item data is stored in 'item_data' field in backend
        return backendFavorites.map((fav) {
          final data = fav['item_data'] as Map<String, dynamic>;
          data['backend_id'] = fav['id'];
          return data;
        }).toList();
      } catch (e) {
        print('Error fetching favorites from backend: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> toggleFavorite(Map<String, dynamic> route,
      {ApiService? api}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final encoded = jsonEncode(route);

    bool isAdding = !raw.contains(encoded);

    if (api != null) {
      try {
        if (isAdding) {
          // Identify the item. Trips have 'id', companies also.
          final itemId =
              route['id']?.toString() ?? route['code']?.toString() ?? 'unknown';
          final itemType =
              route.containsKey('departure_time') ? 'trip' : 'company';

          await api.addFavorite(
            itemId: itemId,
            itemType: itemType,
            itemData: route,
          );

          // Award XP for favoriting
          await XPService.addXP(XPService.xpActions['favorite'] ?? 2,
              reason: 'Favori ajouté');
        } else {
          final itemId =
              route['id']?.toString() ?? route['code']?.toString() ?? 'unknown';
          final itemType =
              route.containsKey('departure_time') ? 'trip' : 'company';
          await api.removeFavorite('', itemId: itemId, itemType: itemType);
        }
      } catch (e) {
        print('Error syncing favorite with backend: $e');
      }
    }

    if (!isAdding) {
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
