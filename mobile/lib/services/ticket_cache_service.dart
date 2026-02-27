import 'package:hive_flutter/hive_flutter.dart';

class TicketCacheService {
  static const String boxName = 'tickets_cache';

  static Future<void> init() async {
    await Hive.openBox<Map>(boxName);
  }

  static Future<void> cacheTickets(List<Map<String, dynamic>> tickets) async {
    final box = Hive.box<Map>(boxName);
    await box.clear();
    for (var i = 0; i < tickets.length; i++) {
      await box.put(i, tickets[i]);
    }
  }

  static List<Map<String, dynamic>> getCachedTickets() {
    final box = Hive.box<Map>(boxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> clearCache() async {
    final box = Hive.box<Map>(boxName);
    await box.clear();
  }
}
