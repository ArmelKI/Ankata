import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';
import '../models/booking_model.dart';

// ============================================================================
// CORE PROVIDERS
// ============================================================================

/// API Service provider (singleton)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Biometric Service provider
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

// ============================================================================
// AUTH PROVIDERS
// ============================================================================

/// Current user authentication state
final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Authentication token
final authTokenProvider = StateProvider<String?>((ref) => null);

// ============================================================================
// SEARCH & FILTER PROVIDERS
// ============================================================================

/// Trip search parameters
final tripSearchParamsProvider = StateProvider<Map<String, String>>((ref) => {
      'originCity': 'Ouagadougou',
      'destinationCity': 'Bobo-Dioulasso',
      'date': DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0],
      'passengers': '1',
    });

/// Search results (with FutureProvider for async data)
final searchResultsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, String>>(
        (ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  final result = await apiService.searchLines(
    params['originCity'] ?? 'Ouagadougou',
    params['destinationCity'] ?? 'Bobo-Dioulasso',
    params['date'] ?? DateTime.now().toIso8601String().split('T')[0],
  );

  if (result['lines'] != null) {
    return List<Map<String, dynamic>>.from(result['lines']);
  }
  return [];
});

/// All companies list
final companiesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final result = await apiService.getCompanies();
  if (result['companies'] != null) {
    return List<Map<String, dynamic>>.from(result['companies']);
  }
  return [];
});

/// Selected trip for booking
final selectedTripProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

/// Trip sort option (price, duration, departure)
final tripSortProvider = StateProvider<String>((ref) => 'departure');

/// Trip filter options
final tripFilterProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'minPrice': 0,
      'maxPrice': 100000,
      'companies': <String>[],
      'departureTimeStart': 0, // 0-1440 minutes
      'departureTimeEnd': 1440,
    });

// ============================================================================
// BOOKING PROVIDERS
// ============================================================================

/// Current booking state
final currentBookingProvider = StateProvider<BookingModel?>((ref) => null);

/// Passenger information
final passengerInfoProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'firstName': '',
      'lastName': '',
      'phoneNumber': '',
      'dateOfBirth': '',
      'cnib': '',
      'gender': '',
    });

/// Selected seats for current booking
final selectedSeatsProvider = StateProvider<List<int>>((ref) => []);

/// Payment method selection
final paymentMethodProvider = StateProvider<String?>((ref) => null);

/// Payment options available
final paymentOptionsProvider = StateProvider<List<String>>((ref) => [
      'orange_money',
      'moov_money',
      'yenga_pay',
      'card',
    ]);

// ============================================================================
// RATINGS & REVIEWS PROVIDERS
// ============================================================================

/// Trip ratings
final tripRatingsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, tripId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final result = await apiService.getTripRatings(tripId);
    if (result['ratings'] != null) {
      return List<Map<String, dynamic>>.from(result['ratings']);
    }
  } catch (e) {
    // Handle error
  }
  return [];
});

/// User's rating input for current trip
final userRatingProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'rating': 0,
      'comment': '',
      'aspects': {
        'cleanliness': 0,
        'comfort': 0,
        'punctuality': 0,
        'driving': 0,
      },
    });

// ============================================================================
// UI/UX STATE PROVIDERS
// ============================================================================

/// Loading state for API calls
final loadingStateProvider = StateProvider<String>((ref) => '');

/// Error messages
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Navigation state
final currentScreenProvider = StateProvider<String>((ref) => 'home');

/// Dark mode toggle
final darkModeProvider = StateProvider<bool>((ref) => false);

/// Dynamic Theme Provider (Company-specific branding)
final dynamicThemeProvider = StateProvider<Color?>((ref) => null);

/// Locale Provider (Language support)
final localeProvider = StateProvider<Locale>((ref) => const Locale('fr'));

// ============================================================================
// LOCATION PROVIDERS
// ============================================================================

/// Selected origin city
final originCityProvider = StateProvider<String>((ref) => 'Ouagadougou');

/// Selected destination city
final destinationCityProvider =
    StateProvider<String>((ref) => 'Bobo-Dioulasso');

/// Available cities
final availableCitiesProvider = FutureProvider<List<String>>((ref) async {
  return [
    'Ouagadougou',
    'Bobo-Dioulasso',
    'Koudougou',
    'Ouahigouya',
    'Fada',
  ];
});

// ============================================================================
// NOTIFICATION PROVIDERS
// ============================================================================

/// User notifications
final notificationsProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Unread notification count
final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);

// ============================================================================
// USER PROFILE PROVIDERS
// ============================================================================

/// User bookings history
final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final result = await apiService.getMyBookings();
    if (result['bookings'] != null) {
      return (result['bookings'] as List)
          .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
          .toList();
    }
  } catch (e) {
    // Handle error
  }
  return [];
});

/// User favorites routes
final favoriteRoutesProvider =
    StateProvider<List<Map<String, String>>>((ref) => []);

// ============================================================================
// ANALYTICS PROVIDERS
// ============================================================================

/// Recent searches
final recentSearchesProvider =
    StateProvider<List<Map<String, String>>>((ref) => []);

/// Search analytics
final searchAnalyticsProvider = StateProvider<Map<String, int>>((ref) => {});
