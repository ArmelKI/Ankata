import 'package:flutter/foundation.dart';
import 'api_service.dart';

class BookingService {
  BookingService(this._apiService);

  final ApiService _apiService;

  /// Annuler une réservation
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      await _apiService.cancelBooking(bookingId, reason);
      return true;
    } catch (e) {
      debugPrint('Erreur annulation: $e');
      return false;
    }
  }

  /// Récupérer réservations utilisateur
  Future<List<Map<String, dynamic>>> getUserBookings({String? status}) async {
    try {
      final response = await _apiService.getMyBookings(status: status);
      final raw = response['bookings'] ??
          response['upcoming'] ??
          response['past'] ??
          [];
      if (raw is List) {
        return raw
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur récupération réservations: $e');
      return [];
    }
  }

  /// Créer une réservation
  Future<Map<String, dynamic>?> createBooking(
      Map<String, dynamic> bookingData) async {
    try {
      final response = await _apiService.createBooking(bookingData);
      if (response['booking'] is Map) {
        return Map<String, dynamic>.from(response['booking'] as Map);
      }
      return response;
    } catch (e) {
      debugPrint('Erreur création réservation: $e');
      return null;
    }
  }
}
