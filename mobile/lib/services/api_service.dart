  Future<Map<String, dynamic>> getCancelledBookings() async {
    try {
      final response = await _dio.get('/bookings/cancelled');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
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
