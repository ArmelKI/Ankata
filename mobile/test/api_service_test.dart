import 'package:flutter_test/flutter_test.dart';
import 'package:ankata/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    group('Auth Endpoints', () {
      test('registerWithPassword should return registered user response',
          () async {
        final response = await apiService.registerWithPassword({
          'phoneNumber': '226XXXXXXXX',
          'password': 'password123',
          'firstName': 'Test',
          'lastName': 'User',
        });
        expect(response, isNotNull);
      });

      test('loginWithPassword should return user token on success', () async {
        final response =
            await apiService.loginWithPassword('226XXXXXXXX', 'password123');
        expect(response, isNotNull);
      });

      test('getCurrentUser should return user data', () async {
        final response = await apiService.getCurrentUser();
        expect(response, isNotNull);
        expect(response['user'], isNotNull);
      });
    });

    group('Search Endpoints', () {
      test('searchLines should return list of trips', () async {
        final response = await apiService.searchLines(
          'Ouagadougou',
          'Bobo-Dioulasso',
          DateTime.now().toIso8601String().split('T')[0],
        );
        expect(response, isNotNull);
        expect(response['lines'], isA<List>());
      });

      test('getLineDetails should return line details', () async {
        final response = await apiService.getLineDetails('1');
        expect(response, isNotNull);
        expect(response['line'], isNotNull);
      });

      test('searchLines with invalid date should handle error gracefully',
          () async {
        try {
          await apiService.searchLines(
            'InvalidCity',
            'AnotherInvalidCity',
            'invalid-date',
          );
        } catch (e) {
          expect(e, isException);
        }
      });
    });

    group('Companies Endpoints', () {
      test('getCompanies should return list of companies', () async {
        final response = await apiService.getCompanies();
        expect(response, isNotNull);
        expect(response['companies'], isA<List>());
      });

      test('getCompanyDetails should return company data', () async {
        final response = await apiService.getCompanyDetails('sotraco');
        expect(response, isNotNull);
        expect(response['company'], isNotNull);
      });

      test('getCompanySchedules should return schedules for date', () async {
        final response = await apiService.getCompanySchedules(
          'sotraco',
          DateTime.now().toIso8601String().split('T')[0],
        );
        expect(response, isNotNull);
        expect(response['schedules'], isA<List>());
      });
    });

    group('Bookings Endpoints', () {
      test('createBooking should return booking confirmation', () async {
        final response = await apiService.createBooking({
          'lineId': '1',
          'seats': [1, 2],
          'passengers': [
            {
              'firstName': 'Test',
              'lastName': 'User',
              'phoneNumber': '226XXXXXXXX',
              'email': 'test@example.com',
            }
          ],
        });
        expect(response, isNotNull);
        expect(response['bookingId'], isNotNull);
      });

      test('getMyBookings should return user bookings', () async {
        final response = await apiService.getMyBookings();
        expect(response, isNotNull);
        expect(response['bookings'], isA<List>());
      });

      test('getBookingDetails should return booking details', () async {
        final response = await apiService.getBookingDetails('booking-123');
        expect(response, isNotNull);
        expect(response['booking'], isNotNull);
      });

      test('cancelBooking should return cancellation confirmation', () async {
        final response = await apiService.cancelBooking(
          'booking-123',
          'Personal reasons',
        );
        expect(response, isNotNull);
        expect(response['status'], equals('cancelled'));
      });
    });

    group('Ratings Endpoints', () {
      test('getTripRatings should return ratings list', () async {
        final response = await apiService.getTripRatings('trip-1');
        expect(response, isNotNull);
        expect(response['ratings'], isA<List>());
      });

      test('createRating should return rating confirmation', () async {
        final response = await apiService.createRating({
          'bookingId': 'booking-123',
          'rating': 5,
          'comment': 'Excellent service',
        });
        expect(response, isNotNull);
        expect(response['ratingId'], isNotNull);
      });

      test('getUserRatings should return user ratings', () async {
        final response = await apiService.getUserRatings();
        expect(response, isNotNull);
        expect(response['ratings'], isA<List>());
      });
    });

    group('Favorites Endpoints', () {
      test('addFavoriteRoute should return success', () async {
        final response = await apiService.addFavoriteRoute(
          'Ouagadougou',
          'Bobo-Dioulasso',
        );
        expect(response, isNotNull);
        expect(response['success'], isTrue);
      });

      test('getFavoriteRoutes should return favorites', () async {
        final response = await apiService.getFavoriteRoutes();
        expect(response, isNotNull);
        expect(response['favorites'], isA<List>());
      });

      test('removeFavoriteRoute should return success', () async {
        final response = await apiService.removeFavoriteRoute('route-1');
        expect(response, isNotNull);
        expect(response['success'], isTrue);
      });
    });

    group('Payments Endpoints', () {
      test('initiatePayment should return payment session', () async {
        final response = await apiService.initiatePayment({
          'bookingId': 'booking-123',
          'amount': 4500,
          'method': 'orange_money',
          'phoneNumber': '226XXXXXXXX',
        });
        expect(response, isNotNull);
        expect(response['paymentId'], isNotNull);
      });

      test('checkPaymentStatus should return payment status', () async {
        final response = await apiService.checkPaymentStatus('payment-123');
        expect(response, isNotNull);
        expect(response['status'], isNotNull);
      });
    });

    group('Notifications Endpoints', () {
      test('getNotifications should return notifications', () async {
        final response = await apiService.getNotifications();
        expect(response, isNotNull);
        expect(response['notifications'], isA<List>());
      });

      test('markNotificationAsRead should return success', () async {
        final response = await apiService.markNotificationAsRead('notif-1');
        expect(response, isNotNull);
        expect(response['success'], isTrue);
      });
    });
  });
}
