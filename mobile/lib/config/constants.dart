class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://ankata.onrender.com/api';
  static const String apiTimeout = '30000'; // milliseconds

  // Environment
  static const String environment = 'production';

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // App Info
  static const String appName = 'Ankata';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Authentication
  static const int otpExpirationSeconds = 600; // 10 minutes
  static const int otpLength = 6;
  static const int maxOtpAttempts = 3;

  // Pagination
  static const int pageSize = 20;
  static const int maxPages = 100;

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Cache
  static const int cacheExpirationHours = 24;

  // Payment
  static const String orangeMoneyKey = 'ORANGE_MONEY_KEY';
  static const String waveKey = 'WAVE_KEY';
  static const String moovMoneyKey = 'MOOV_MONEY_KEY';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String lastSearchKey = 'last_search';
}
