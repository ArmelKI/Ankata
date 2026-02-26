/// Configuration API pour l'application Ankata
/// Adaptée pour USB Debug sur Google Pixel 9

class ApiConfig {
  // URL de base du backend - À adapter selon votre réseau
  // Pour USB Debug via adb forward : 10.0.2.2 (Android Emulator default)
  // Pour WiFi local : utilisez l'IP de votre machine (ex: 192.168.1.105)
  // Pour production : utilisez votre domaine
  
  static const String baseUrl = 'http://localhost:3000/api';
  // Alternative pour appareil physique sur même WiFi :
  // static const String baseUrl = 'http://localhost:3000/api';
  
  static const String healthEndpoint = 'http://localhost/health';
  
  // Endpoints API
  static const String companiesEndpoint = '/companies';
  static const String linesEndpoint = '/lines';
  static const String searchEndpoint = '/lines/search';
  static const String scheduleEndpoint = '/lines/:lineId/schedules';
  static const String bookingsEndpoint = '/bookings';
  static const String paymentsEndpoint = '/payments';
  static const String authEndpoint = '/auth';
  static const String ratingsEndpoint = '/ratings';
  
  // Configuration HTTP
  static const int connectTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000; // 30 secondes
  
  // Configuration des requêtes
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Obtenir l'URL complète pour une requête
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Obtenir l'URL de recherche avec paramètres
  static String getSearchUrl(String origin, String destination, String date) {
    return '$baseUrl$searchEndpoint?origin=$origin&destination=$destination&date=$date';
  }
  
  /// Obtenir l'URL des horaires pour une ligne
  static String getScheduleUrl(String lineId, String day) {
    return '$baseUrl${scheduleEndpoint.replaceFirst(':lineId', lineId)}?day=$day';
  }
}

/// Service de configuration pour l'application
class AppConfig {
  // Localisation par défaut
  static const String defaultLocale = 'fr';
  static const List<String> supportedLocales = ['fr', 'en'];
  
  // Configuration du thème
  static const bool useDarkTheme = false;
  static const bool useMaterialYou = true;
  
  // Configuration notifications
  static const bool enableNotifications = true;
  static const bool enablePushNotifications = true;
  
  // Configuration de stockage local
  static const String storageBox = 'ankata_box';
  static const String userPreferencesBox = 'user_preferences';
  static const String bookingsCacheBox = 'bookings_cache';
  
  // Versions de l'app
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  
  // Timeouts
  static const Duration imageLoadTimeout = Duration(seconds: 10);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Limitations
  static const int maxBookingsPerDay = 5;
  static const int maxPasswordAttempts = 3;
  static const int otpExpirationMinutes = 10;
}

/// Configuration de l'environnement
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const Environment currentEnvironment = Environment.development;
  
  static bool get isDevelopment => currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;
  
  /// Activer le mode debug
  static bool get enableDebugMode => isDevelopment;
  
  /// Afficher les logs de réseau
  static bool get logNetworkRequests => isDevelopment || isStaging;
}
