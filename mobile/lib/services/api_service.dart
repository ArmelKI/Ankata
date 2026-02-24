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
  Future<Map<String, dynamic>> requestOTP(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/auth/request-otp',
        data: {'phoneNumber': phoneNumber},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );
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

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final errorMessage = error.response!.data['error'] ?? error.message;
      return Exception(errorMessage);
    }
    return Exception(error.message);
  }
}
