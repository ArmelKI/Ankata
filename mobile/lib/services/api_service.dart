import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;

  ApiService() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          if (kDebugMode) {
            print('[API] ${options.method} ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('[API] Response: ${response.statusCode}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('[API] Error: ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> initialize() async {
    _token = await _secureStorage.read(key: AppConfig.tokenKey);
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> clearToken() async {
    _token = null;
    await _secureStorage.delete(key: AppConfig.tokenKey);
    _dio.options.headers.remove('Authorization');
  }

  // Auth Endpoints
  Future<Map<String, dynamic>> loginWithPassword(
      String phoneNumber, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'phoneNumber': phoneNumber, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> registerWithPassword(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken,
      {String? phoneNumber}) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'idToken': idToken, 'phoneNumber': phoneNumber},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getSecurityQuestions(String phoneNumber) async {
    try {
      final response = await _dio.get('/auth/security-questions/$phoneNumber');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/auth/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/users/$userId', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        '/upload/profile-picture',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitFeedback({
    required String type,
    String? subject,
    required String message,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final response = await _dio.post(
        '/feedback',
        data: {
          'type': type,
          'subject': subject,
          'message': message,
          'deviceInfo': deviceInfo,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Lines Endpoints
  Future<Map<String, dynamic>> searchLines(
    String originCity,
    String destinationCity,
    String date,
  ) async {
    try {
      final response = await _dio.get(
        '/lines/search',
        queryParameters: {
          'originCity': originCity,
          'destinationCity': destinationCity,
          'date': date,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getLineDetails(String lineId,
      {String? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date;
      }
      final response = await _dio.get(
        '/lines/$lineId',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Companies Endpoints
  Future<Map<String, dynamic>> getAllCompanies(
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/companies',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCompanyDetails(String companyId) async {
    try {
      final response = await _dio.get('/companies/$companyId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCompanyRatings(String companyId) async {
    try {
      final response = await _dio.get('/companies/$companyId/ratings');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Bookings Endpoints
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/bookings', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMyBookings({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      final response = await _dio.get(
        '/bookings/my-bookings',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    try {
      final response = await _dio.get('/bookings/$bookingId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> cancelBooking(
      String bookingId, String reason) async {
    try {
      final response = await _dio.post(
        '/bookings/$bookingId/cancel',
        data: {'reason': reason},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Companies Endpoints
  Future<Map<String, dynamic>> getCompanies() async {
    try {
      final response = await _dio.get('/companies');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCompanySchedules(
      String companySlug, String date) async {
    try {
      final response = await _dio.get(
        '/companies/$companySlug/schedules',
        queryParameters: {'date': date},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Ratings Endpoints
  Future<Map<String, dynamic>> getTripRatings(String tripId) async {
    try {
      final response = await _dio.get('/ratings/trip/$tripId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createRating(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/ratings', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserRatings() async {
    try {
      final response = await _dio.get('/ratings/my-ratings');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Notifications Endpoints
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
      String notificationId) async {
    try {
      final response = await _dio.post('/notifications/$notificationId/read');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Payments Endpoints
  Future<Map<String, dynamic>> initiatePayment(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/payments', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId/status');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Favorites Endpoints
  Future<Map<String, dynamic>> addFavoriteRoute(
      String fromCity, String toCity) async {
    try {
      final response = await _dio.post(
        '/favorites',
        data: {'fromCity': fromCity, 'toCity': toCity},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> removeFavoriteRoute(String routeId) async {
    try {
      final response = await _dio.delete('/favorites/$routeId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFavoriteRoutes() async {
    try {
      final response = await _dio.get('/favorites');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Passengers ---
  Future<List<dynamic>> getSavedPassengers() async {
    try {
      final response = await _dio.get('/passengers');
      return response.data['passengers'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createSavedPassenger(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/passengers', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateSavedPassenger(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/passengers/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSavedPassenger(String id) async {
    try {
      await _dio.delete('/passengers/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Users & Referral ---
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await _dio.get('/users/referral/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Promo Codes ---
  Future<Map<String, dynamic>> validatePromoCode(
      String code, int amount) async {
    try {
      final response = await _dio.post('/promocodes/validate', data: {
        'code': code,
        'amount': amount,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Wallet & Transactions ---
  Future<Map<String, dynamic>> getWalletData(
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get('/wallet/transactions', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // PRICE ALERTS
  // ============================================================================

  Future<Map<String, dynamic>> createPriceAlert({
    required String originCity,
    required String destinationCity,
    required double targetPrice,
  }) async {
    try {
      final response = await _dio.post('/price-alerts', data: {
        'originCity': originCity,
        'destinationCity': destinationCity,
        'targetPrice': targetPrice,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getPriceAlerts() async {
    try {
      final response = await _dio.get('/price-alerts');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePriceAlert(String id) async {
    try {
      await _dio.delete('/price-alerts/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> togglePriceAlert(String id) async {
    try {
      final response = await _dio.patch('/price-alerts/$id/toggle');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Favorites ---
  Future<List<dynamic>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      return response.data['favorites'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addFavorite({
    required String itemId,
    required String itemType,
    Map<String, dynamic>? itemData,
  }) async {
    try {
      final response = await _dio.post('/favorites', data: {
        'itemId': itemId,
        'itemType': itemType,
        'itemData': itemData,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeFavorite(String id,
      {String? itemId, String? itemType}) async {
    try {
      await _dio.delete('/favorites/$id', queryParameters: {
        if (itemId != null) 'itemId': itemId,
        if (itemType != null) 'itemType': itemType,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    String message = 'Une erreur inattendue est survenue.';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message =
          'Le délai de connexion a expiré. Veuillez vérifier votre réseau.';
    } else if (error.type == DioExceptionType.connectionError) {
      message =
          'Erreur de connexion : impossible de joindre le serveur. Assurez-vous d\'être connecté à Internet.';
    } else if (error.response != null) {
      final data = error.response?.data;
      if (data != null && data is Map && data.containsKey('error')) {
        message = data['error'].toString();
      } else if (error.response?.statusCode == 404) {
        message = 'La ressource demandée est introuvable (Erreur 404).';
      } else if (error.response?.statusCode == 500) {
        message = 'Erreur interne du serveur. Veuillez réessayer plus tard.';
      } else {
        message = 'Erreur serveur: ${error.response?.statusCode}';
      }
    } else {
      message = error.message ?? message;
    }

    if (kDebugMode) {
      print('[API Error] $message');
    }
    return Exception(message);
  }
}
