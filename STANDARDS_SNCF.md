# 🏆 STANDARDS SNCF - ANKATA

**Objectif** : Qualité comparable à SNCF Connect (Application officielle SNCF)  
**Target**: Mars 15, 2026 (v1.0.0 Production)

---

## 📐 ARCHITECTURE CIBLE

### Clean Architecture Pattern

```
lib/
├── core/                           # Shared logic
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart        # Custom exceptions
│   │   └── failures.dart          # Error handling
│   ├── network/
│   │   ├── api_client.dart        # Dio wrapper
│   │   └── network_info.dart      # Connectivity check
│   └── utils/
│       ├── validators.dart        # Input validation
│       ├── formatters.dart        # Data formatting
│       └── extensions.dart        # Dart extensions
│
├── features/                       # Business logic by feature
│   ├── search/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/riverpod
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── booking/
│   ├── payment/
│   ├── auth/
│   ├── companies/
│   └── profile/
│
├── shared/                         # Shared across features
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   └── loaders/
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│
├── config/
│   ├── router.dart
│   ├── api_config.dart
│   └── environment.dart
│
└── main.dart
```

### Separation of Concerns

```
DATA LAYER
├── Remote (API calls)
├── Local (SQLite cache)
└── Models (JSON serialization)

DOMAIN LAYER
├── Entities (Business objects)
├── Repositories (Abstract)
└── Use Cases (Business logic)

PRESENTATION LAYER
├── Providers (Riverpod state)
├── Screens (Pages)
└── Widgets (Components)
```

---

## 🎨 DESIGN STANDARDS

### Color Palette (SNCF-Inspired)

```dart
class AnkataColors {
  // Primary Brand
  static const Color primary = Color(0xFF003380);      // SNCF Blue
  static const Color secondary = Color(0xFFFF6B35);    // Accent Orange
  static const Color tertiary = Color(0xFF00A859);     // Success Green
  
  // Semantic
  static const Color success = Color(0xFF00A859);      // Green
  static const Color warning = Color(0xFFFFA500);      // Amber
  static const Color error = Color(0xFFE53935);        // Red
  static const Color info = Color(0xFF0066CC);         // Blue
  
  // Grayscale
  static const Color background = Color(0xFFFFFFFF);   // White
  static const Color surface = Color(0xFFF5F5F5);      // Light Gray
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color onSurface = Color(0xFF212121);    // Black
  static const Color outline = Color(0xFFBDBDBD);      // Gray
  static const Color disabled = Color(0xFFBDBDBD);     // Gray
  
  // Company Colors (from DB)
  static const Map<String, Color> companyColors = {
    'sotraco': Color(0xFF00A859),      // Green
    'tsr': Color(0xFF1E90FF),          // Blue
    'staf': Color(0xFFFF6B00),         // Orange
    'rahimo': Color(0xFFDC143C),       // Crimson
    'rakieta': Color(0xFF8B0000),      // Dark Red
    'tcv': Color(0xFF006400),          // Dark Green
    'saramaya': Color(0xFF0044AA),     // Navy Blue
  };
}
```

### Typography (Google Fonts)

```dart
class AppTextStyles {
  // Headings
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );
}
```

### Spacing & Layout

```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  
  // Standard padding
  static const EdgeInsets padDefault = EdgeInsets.all(md);
  static const EdgeInsets padHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets padVertical = EdgeInsets.symmetric(vertical: md);
}

class AppDimensions {
  static const double buttonHeight = 48;
  static const double textFieldHeight = 48;
  static const double cardRadius = 12;
  static const double bottomSheetRadius = 24;
}
```

### Animations

```dart
class AppAnimations {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 800);
  
  // Curves
  static const Curve easingStandard = Curves.easeInOut;
  static const Curve easingAccelerate = Curves.easeIn;
  static const Curve easingDecelerate = Curves.easeOut;
}
```

### Responsive Design

```dart
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet &&
      MediaQuery.of(context).size.width < desktop;
}
```

---

## 🔒 SECURITY STANDARDS

### Authentication & Authorization

```dart
// JWT Token Management
class TokenManager {
  final SecureStorage _secureStorage;
  
  Future<void> saveToken(String token) async {
    await _secureStorage.write(
      key: 'auth_token',
      value: token,
    );
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
  
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      final decodedToken = JwtDecoder.decode(token);
      final exp = DateTime.fromMillisecondsSinceEpoch(
        decodedToken['exp'] * 1000,
      );
      return exp.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}

// API Interceptor for Token
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### Data Encryption

```dart
// Secure Storage for Sensitive Data
class SecurityService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  Future<String?> readSecure(String key) async {
    return await _storage.read(key: key);
  }
  
  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }
}

// Phone number encryption (for payment)
class PaymentSecurity {
  static String encryptPhone(String phone) {
    // One-way hash for security
    return Hmac(sha256, utf8.encode('secret_key'))
        .convert(utf8.encode(phone))
        .toString();
  }
}
```

### SSL Pinning

```dart
// For production, pin SSL certificates
class HttpClientFactory {
  static HttpClient createHttpClient() {
    final httpClient = HttpClient();
    
    httpClient.badCertificateCallback = (cert, host, port) {
      // In production: Implement certificate pinning
      // For now: Accept all (only for dev)
      return kDebugMode;
    };
    
    return httpClient;
  }
}
```

---

## 📱 PERFORMANCE STANDARDS

### Target Metrics (Based on SNCF Connect)

```
Metric                 Target      Current  Priority
─────────────────────────────────────────────────────
First Paint           <1.0s       ~3s      🔴
Time to Interactive   <1.5s       ~5s      🔴
Lighthouse Score      >85         ~70      🔴
APK Size              <80MB       ~100MB   🟡
Memory (home)         <80MB       TBD      🟡
FPS (scrolling)       60fps       TBD      🟡
API Response          <500ms      (OK)     ✅
Search Latency        <800ms      (OK)     ✅
```

### Optimization Checklist

```dart
// 1. Image Optimization
[ ] Use WebP format
[ ] Compress images (ImageMagick)
[ ] Lazy load images below fold
[ ] Use cached_network_image

// 2. Code Splitting
[ ] Lazy load screens (go_router)
[ ] Feature modules
[ ] Remove unused dependencies

// 3. Build Optimization
[ ] Enable ProGuard (Android)
[ ] Minify + Obfuscate
[ ] Use release mode only
[ ] Strip debug symbols

// 4. Runtime Optimization
[ ] Use const constructors
[ ] Avoid rebuilds (Riverpod selectAsync)
[ ] Efficient list rendering (ListView)
[ ] Avoid deep widget trees
```

### Profiling Commands

```bash
# Performance analysis
flutter run --profile
# Open DevTools: DevTools → Timeline

# APK analysis
flutter build apk --release --analyze-size

# Memory profiling
flutter run --prof
Dart DevTools → Memory tab

# Performance monitoring
flutter run --trace-startup
```

---

## 🧪 TESTING STANDARDS

### Unit Tests (Dart)

```dart
// Example: API Service Test
void main() {
  group('ApiService', () {
    late ApiService apiService;
    late MockDio mockDio;
    
    setUp(() {
      mockDio = MockDio();
      apiService = ApiService(dioClient: mockDio);
    });
    
    test('searchTrips returns list of trips', () async {
      // Arrange
      final mockResponse = {
        'lines': [
          {
            'id': '1',
            'company': {'name': 'SNCF'},
            'price': 50,
          }
        ]
      };
      when(mockDio.get(...)).thenAnswer(
        (_) async => Response(data: mockResponse),
      );
      
      // Act
      final result = await apiService.searchTrips(...);
      
      // Assert
      expect(result, isNotEmpty);
      expect(result[0].price, 50);
    });
  });
}

// Test Coverage Target: >80%
```

### Widget Tests (Flutter UI)

```dart
void main() {
  group('CompanyCard Widget', () {
    testWidgets('displays company name', (WidgetTester tester) async {
      final company = Company(
        id: '1',
        name: 'RAHIMO',
        rating: 4.6,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: CompanyCard(company: company),
        ),
      );
      
      expect(find.text('RAHIMO'), findsOneWidget);
      expect(find.text('4.6/5'), findsOneWidget);
    });
  });
}
```

### Integration Tests (E2E)

```dart
void main() {
  group('Booking Flow Integration Test', () {
    testWidgets('Complete booking from search to confirmation',
      (WidgetTester tester) async {
      
      // 1. Launch app
      await tester.pumpWidget(const AnkataApp());
      
      // 2. Search test
      await tester.enterText(find.byType(TextField).first, 'Ouagadougou');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      // 3. Results display
      expect(find.byType(CompanyCard), findsWidgets);
      
      // 4. Booking flow
      await tester.tap(find.byType(CompanyCard).first);
      await tester.pumpAndSettle();
      
      // 5. Confirmation
      expect(find.text('Réservation confirmée'), findsOneWidget);
    });
  });
}
```

---

## 📊 CODE QUALITY STANDARDS

### Linting Rules

```yaml
# analysis_options.yaml (Extended)
linter:
  rules:
    # Error Rules
    - avoid_empty_else
    - avoid_print
    - avoid_relative_import_paths
    - avoid_returning_null
    - avoid_returning_null_for_async
    - avoid_returning_this
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - invariant_booleans
    - iterable_contains_unrelated_type
    - list_remove_unrelated_type
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - prefer_void_to_null
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks
    
    # Style Rules
    - always_declare_return_types
    - always_put_control_body_on_new_line
    - always_put_required_named_parameters_first
    - annotate_overrides
    - avoid_bool_literals_in_conditional_expressions
    - avoid_catches_without_on_clauses
    - avoid_catching_errors
    - avoid_double_and_int_checks
    - avoid_field_initializers_in_const_classes
    - avoid_function_literals_in_foreach_calls
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_positional_boolean_parameters
    - avoid_private_typedef_functions
    - avoid_renaming_method_parameters
    - avoid_return_types_on_setters
    - avoid_returning_null_for_future
    - avoid_setters_without_getters
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_types_as_parameter_names
    - avoid_types_on_closure_parameters
    - avoid_unnecessary_containers
    - avoid_positional_boolean_parameters
    - avoid_private_typedef_functions
    
    # Pub Rules
    - depend_on_referenced_packages
    - sort_pub_dependencies
```

### Code Metrics

```dart
// Complexity limits (via Dart Code Metrics)
cyclomatic-complexity: 10  // Max function complexity
lines-of-code: 100         // Max function length
weighted-methods-per-class: 20
parameter-count: 5
source-lines-of-code: 1000 // Per file

// Examples:
✅ GOOD function
int calculatePrice(int seats) {
  return seats * 5000;  // Simple, clear
}

❌ COMPLEX function (>10 branches)
int calculatePrice(int seats, bool isStudent, bool isDisabled, 
                   bool isWeekend, bool isPeakHour) {
  // Too many branches...
}
```

---

## 📝 LOGGING & MONITORING

### Structured Logging

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    printEmojis: true,
  ),
);

// Usage
logger.i('Search for Ouaga→Bobo');
logger.w('API response slower than 500ms');
logger.e('Payment failed', error, stackTrace);
logger.d('User ID: ${user.id}');

// In production: Log to file
logger.d('Event logged', time: DateTime.now());
```

### Analytics

```dart
class AnalyticsService {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  Future<void> logSearch(String origin, String destination) async {
    await analytics.logEvent(
      name: 'search_initiated',
      parameters: {
        'origin': origin,
        'destination': destination,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> logBooking(String companyId, int price) async {
    await analytics.logEvent(
      name: 'booking_completed',
      parameters: {
        'company_id': companyId,
        'price': price,
      },
    );
  }
}
```

---

## 🚀 DEPLOYMENT STANDARDS

### Versioning

```
MAJOR.MINOR.PATCH+BUILD
v1.0.0+1   → v1.0.1+2 → v1.1.0+3 → v2.0.0+4

Major: Breaking changes
Minor: New features
Patch: Bug fixes
Build: Internal increments
```

### Release Checklist

```bash
# Before Release
[ ] All tests pass (unit + widget + integration)
[ ] Code review approved
[ ] No deprecation warnings
[ ] Performance benchmarks met
[ ] Security audit passed
[ ] Screenshots/Video recorded
[ ] Release notes written
[ ] CHANGELOG.md updated
[ ] Version bumped (pubspec.yaml)

# Build Commands
# Debug build
flutter build apk --debug
flutter build ios --debug

# Release build
flutter build apk --release --split-per-abi
flutter build appbundle --release

# Verification
flutter build apk --analyze-size
keytool -printcert -jarfile app-release.apk

# Upload
# Play Store / App Store (TestFlight)
```

### CI/CD Pipeline (GitHub Actions)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.2'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload coverage
        uses: codecov/codecov-action@v2
```

---

## ✨ SNCF-SPECIFIC FEATURES

### Accessibility (a11y)

```dart
class AccessibleSearchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: 'Rechercher un trajet de ${trip.origin} à ${trip.destination}',
      onTap: () => onTapSearch(),
      child: GestureDetector(
        onTap: () => onTapSearch(),
        child: Card(
          child: Column(
            children: [
              Tooltip(
                message: 'Départ: ${trip.departure}',
                child: Text(trip.origin),
              ),
              // ...
            ],
          ),
        ),
      ),
    );
  }
}
```

### Internationalization (i18n)

```yaml
# pubspec.yaml
flutter:
  generate: true

# lib/l10n/app_fr.arb
{
  "@@locale": "fr",
  "search": "Rechercher",
  "searchHint": "De quelle gare à quelle gare?",
  "companyRating": "{rating} / 5 ({count} avis)",
  "@companyRating": {
    "placeholders": {
      "rating": {"type": "double"},
      "count": {"type": "int"}
    }
  }
}
```

### Offline Support

```dart
class OfflineManager {
  final LocalRepository _localRepo;
  
  Future<List<Trip>> searchTripsOffline(
    String origin,
    String destination,
  ) async {
    // Fallback to cached data
    return await _localRepo.getCachedTrips(
      origin: origin,
      destination: destination,
    );
  }
  
  Future<void> syncOnConnect() async {
    if (await _networkInfo.isConnected) {
      // Sync pending bookings
      await _bookingRepo.syncPendingBookings();
    }
  }
}
```

---

## 📈 SUCCESS METRICS

### User-Centered Metrics

```
Metric                    Target    How to measure
────────────────────────────────────────────────────
New User Conversion       >30%      Analytics event
Booking Completion        >70%      Analytics event
Payment Success           >95%      Payment webhook
User Rating               >4.5/5    App Store reviews
Daily Active Users        >1000     Firebase DAU
Session Duration          >5 min    Analytics
Return Rate (Week 1)      >40%      Retention metrics
```

### Business Metrics

```
GTV (Gross Transaction Value)
- Weekly target: 50M FCFA
- Monthly target: 200M FCFA

Commissions
- Standard: 8%
- Volume bonus: +1-2% (>10K/day)

Customer Acquisition Cost
- Target: <500 FCFA
- Max: <1500 FCFA
```

---

## 🎯 ROADMAP - PATH TO SNCF-QUALITY

### March 2026 (Pre-Launch)
```
Week 1-2: Core features (v0.1.0)
Week 3: Payment integration (v0.2.0)
Week 4: Performance & stability (v0.2.5)
```

### April 2026 (Launch)
```
Week 1: Pre-launch QA
Week 2: Soft launch (10K users)
Week 3: Monitor & fix
Week 4: Official launch (100K users)
```

### May+ 2026 (Growth)
```
- Notifications
- Advanced features
- International (English)
- Payment providers expansion
```

---

## 📞 SNCF-QUALITY SUPPORT

### Incident Response SLA
```
Severity  Priority  Resolution Time  Escalation
────────────────────────────────────────────────
P0 (Down) Critical  15 min           CTO + Ops
P1 (Major) High     1 hour           PM + TeamLead
P2 (Minor) Medium   4 hours          Engineer
P3 (Info) Low       2 days           Backlog
```

### Support Channels
```
- In-app chat support (https://chat.ankata.bf)
- Email: support@ankata.bf
- WhatsApp: +226 XX XXX XXXX
- Twitter: @AnkataBF
- Facebook: /AnkataBF
```

---

**Document Version**: 1.0  
**Last Updated**: 23 Février 2026  
**Review Date**: 1er Mars 2026

