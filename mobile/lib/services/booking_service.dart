import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Annuler une réservation
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
        'cancellationReason': reason,
      });
      return true;
    } catch (e) {
      print('Erreur annulation: $e');
      return false;
    }
  }

  /// Récupérer réservations utilisateur
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final snapshot = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('departureDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erreur récupération réservations: $e');
      return [];
    }
  }

  /// Créer une réservation
  Future<String?> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final doc = await _db.collection('bookings').add({
        ...bookingData,
        'createdAt': Timestamp.now(),
        'status': 'confirmed',
      });
      return doc.id;
    } catch (e) {
      print('Erreur création réservation: $e');
      return null;
    }
  }
}
