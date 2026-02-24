# Ankata Mobile App

Flutter mobile application for Ankata transport booking platform.

## Quick Start

### Prerequisites
- Flutter >= 3.0.0
- Dart >= 3.0.0
- Android SDK or Xcode (for iOS)
- Git

### Installation

1. Navigate to mobile directory:
   ```bash
   cd mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure API URL:
   - Edit `lib/config/constants.dart`
   - Update `apiBaseUrl` to your backend URL

4. Run the app:
   ```bash
   # iOS
   flutter run -d iPhone
   
   # Android
   flutter run
   
   # Web
   flutter run -d chrome
   ```

## Project Structure

```
lib/
├── config/
│   ├── theme.dart           # Material Design theme
│   ├── router.dart          # Go Router navigation
│   └── constants.dart       # App constants
├── models/
│   ├── user_model.dart
│   ├── company_model.dart
│   ├── line_model.dart
│   ├── schedule_model.dart
│   └── booking_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── lines_provider.dart
│   └── bookings_provider.dart
├── services/
│   ├── api_service.dart
│   ├── local_storage.dart
│   └── payment_service.dart
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── phone_auth_screen.dart
│   │   └── otp_verify_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── search_screen.dart
│   ├── trips/
│   │   ├── trip_search_results_screen.dart
│   │   └── trip_details_screen.dart
│   ├── bookings/
│   │   ├── booking_screen.dart
│   │   ├── booking_confirmation_screen.dart
│   │   └── my_bookings_screen.dart
│   ├── companies/
│   │   └── company_details_screen.dart
│   ├── ratings/
│   │   └── rating_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/
│   └── [Reusable components]
├── utils/
│   ├── logger.dart
│   └── validators.dart
└── main.dart
```

## Dependencies

### State Management
- **provider** - Service injection and state management
- **riverpod** - Reactive state management

### Navigation
- **go_router** - Type-safe routing with deep linking

### UI
- **flutter_svg** - SVG rendering
- **cached_network_image** - Image caching
- **shimmer** - Loading placeholders
- **lottie** - Animations

### Network
- **dio** - HTTP client
- **http** - Alternative HTTP package

### Storage
- **shared_preferences** - Local key-value storage
- **hive** - Local database

### Maps
- **google_maps_flutter** - Map integration
- **location** - Location services
- **geolocator** - Geolocation

### Payments
- **flutter_stripe** - Stripe integration
- **mobile_money_flutter** - Mobile money integration

### Notifications
- **firebase_core** - Firebase
- **firebase_messaging** - Push notifications
- **flutter_local_notifications** - Local notifications

## Configuration

### API Configuration
Edit `lib/config/constants.dart`:

```dart
class AppConfig {
  static const String apiBaseUrl = 'https://api.ankata.app/api';
  static const String environment = 'production';
  // ... other configs
}
```

### Theme Customization
Edit `lib/config/theme.dart`:

```dart
class AppTheme {
  static const Color primaryColor = Color(0xFF00A859);
  static const Color secondaryColor = Color(0xFF1E90FF);
  // ... other colors
}
```

## App Features

### Authentication
- WhatsApp OTP verification
- JWT token management
- Auto-login with stored credentials
- Profile management

### Search & Discovery
- Search lines by origin/destination/date
- Filter by company/price/duration
- View company details and ratings
- Check real-time seat availability

### Bookings
- 3-step booking flow
  1. Passenger info
  2. Luggage & extras
  3. Payment method
- Booking confirmation
- My bookings list (upcoming & past)
- Cancel bookings with reason

### Payments
- Orange Money integration
- Moov Money integration
- Payment status tracking
- Transaction history

### Ratings & Reviews
- Post-travel rating system
- Multi-criteria ratings (comfort, punctuality, cleanliness)
- Helpful votes
- View company statistics

### User Profile
- Personal information
- Saved payment methods
- Loyalty points
- Booking history
- Settings & preferences

## Development

### Code Style
- Follow Flutter best practices
- Use meaningful variable names
- Add comments for complex logic
- Use const constructors where possible

### State Management Pattern
```dart
final bookingProvider = StateNotifierProvider((ref) {
  return BookingNotifier();
});

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState.initial());
  
  void createBooking(Map<String, dynamic> data) async {
    // Implementation
  }
}
```

### API Calls Pattern
```dart
await apiService.searchLines(
  originCity,
  destinationCity,
  date,
).then((response) {
  // Handle success
}).catchError((error) {
  // Handle error
});
```

## Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk
```

### Android App Bundle
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS App
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widgets/
```

## Performance Tips

- Use `const` constructors
- Implement `shouldRebuild` in providers
- Use `ListView.builder` for long lists
- Cache images with `CachedNetworkImage`
- Use `RepaintBoundary` for expensive widgets
- Profile with DevTools: `flutter pub global activate devtools`

## Troubleshooting

### "flutter: command not found"
- Add Flutter to PATH
- Restart terminal

### Build Errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Hot Reload Not Working
- Save file manually
- Check for syntax errors
- Rebuild if logic changes

### API Connection Issues
- Check backend server status
- Verify API URL in constants
- Check network connectivity
- Review API response format

## Debugging

### Enable Logging
```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Use DevTools
```bash
flutter pub global activate devtools
devtools
```

## Authentication Flow

1. **Splash Screen** - Check if user is logged in
2. **Onboarding** - First-time users see feature showcase
3. **Phone Auth** - Enter phone number
4. **OTP Verification** - Verify OTP from WhatsApp
5. **Home Screen** - Main app interface
6. **Auto-login** - Use stored JWT for subsequent sessions

## Booking Flow

1. **Search** - Enter origin, destination, date
2. **Results** - View available trips
3. **Select Trip** - Choose specific schedule
4. **Booking Details** - Enter passenger info and luggage
5. **Payment** - Select payment method
6. **Confirmation** - Show booking code and ticket details

## Release Checklist

- [ ] Update version in pubspec.yaml
- [ ] Test on multiple devices
- [ ] Test on slow network
- [ ] Test deep linking
- [ ] Test payment flow
- [ ] Update app icons
- [ ] Update app screenshots
- [ ] Write release notes
- [ ] Sign APK/IPA
- [ ] Submit to Play Store/App Store

## Support

For issues and questions, contact: dev@axiane.agency

---

**Version:** 1.0.0  
**Last Updated:** 23 février 2026
