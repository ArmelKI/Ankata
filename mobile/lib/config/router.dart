import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/search_screen.dart';
import '../screens/trips/trip_search_results_screen.dart';
import '../screens/trips/trip_details_screen.dart';
import '../screens/bookings/my_bookings_screen.dart';
import '../screens/booking/passenger_info_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/payment/payment_success_screen.dart';
import '../screens/booking/confirmation_screen.dart';
import '../screens/tickets/my_tickets_screen.dart';
import '../screens/tickets/ticket_details_screen.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/companies/company_details_screen.dart';
import '../screens/ratings/rating_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/saved_passengers_screen.dart';
import '../screens/profile/referral_dashboard_screen.dart';
import '../screens/profile/price_alerts_screen.dart';
import '../screens/wallet/transaction_history_screen.dart';
import '../screens/maps/station_maps_screen.dart';
import '../screens/trips/bus_tracking_screen.dart';
import '../screens/sotraco/sotraco_home_screen.dart';
import '../screens/sotraco/sotraco_line_details_screen.dart';
import '../screens/support/faq_screen.dart';
import '../screens/support/feedback_screen.dart';
import '../screens/support/legal_screen.dart';
import '../screens/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // Splash & Auth Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/phone-auth',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Shell (avec Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/my-tickets',
            builder: (context, state) => const MyTicketsScreen(),
          ),
          GoRoute(
            path: '/companies',
            builder: (context, state) => const CompaniesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Trip Search & Details Routes
      GoRoute(
        path: '/trips/search',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          return TripSearchResultsScreen(
            originCity: params?['originCity'] ?? '',
            destinationCity: params?['destinationCity'] ?? '',
            departureDate: params?['departureDate'] ?? '',
            passengers: params?['passengers'] ?? 1,
          );
        },
      ),
      GoRoute(
        path: '/trips/:tripId',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId'] ?? '';
          return TripDetailsScreen(tripId: tripId);
        },
      ),

      // Booking Routes
      GoRoute(
        path: '/passenger-info',
        builder: (context, state) {
          final tripData = state.extra as Map<String, dynamic>?;
          return PassengerInfoScreen(tripData: tripData ?? {});
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final bookingData = state.extra as Map<String, dynamic>?;
          if (bookingData != null &&
              bookingData.containsKey('amount') &&
              bookingData.containsKey('bookingId') &&
              bookingData.containsKey('tripDetails')) {
            return PaymentScreen(
              amount: bookingData['amount'] as int,
              bookingId: bookingData['bookingId'] as String,
              tripDetails: bookingData['tripDetails'] as String,
              basePrice: bookingData['basePrice'] as int?,
              serviceFee: bookingData['serviceFee'] as int?,
            );
          }
          return const Scaffold(
              body: Center(child: Text('Invalid Payment Data')));
        },
      ),
      GoRoute(
        path: '/payment-success',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return PaymentSuccessScreen(
            amount: data['amount'] as int? ?? 0,
            bookingId: data['bookingId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/confirmation',
        builder: (context, state) {
          final bookingData = state.extra as Map<String, dynamic>?;
          return ConfirmationScreen(bookingData: bookingData ?? {});
        },
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      // Ticket Details Route
      GoRoute(
        path: '/ticket-details',
        builder: (context, state) {
          final ticket = state.extra as Map<String, dynamic>? ?? {};
          return TicketDetailsScreen(ticket: ticket);
        },
      ),

      // Company Routes (Nested screens outside shell)
      GoRoute(
        path: '/companies/:companyId',
        builder: (context, state) {
          final companyId = state.pathParameters['companyId'] ?? '';
          return CompanyDetailsScreen(companyId: companyId);
        },
      ),
      GoRoute(
        path: '/sotraco',
        builder: (context, state) => const SotracoHomeScreen(),
      ),
      GoRoute(
        path: '/sotraco/line/:lineId',
        builder: (context, state) {
          final lineId = state.pathParameters['lineId'] ?? '';
          return SotracoLineDetailsScreen(lineId: lineId);
        },
      ),

      // Rating Routes
      GoRoute(
        path: '/rating/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return RatingScreen(
            bookingId: bookingId,
            companyId: extra?['companyId'] as String?,
          );
        },
      ),

      // Profile sub-routes
      GoRoute(
        path: '/faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/profile/passengers',
        builder: (context, state) => const SavedPassengersScreen(),
      ),
      GoRoute(
        path: '/profile/referral',
        builder: (context, state) => const ReferralDashboardScreen(),
      ),
      GoRoute(
        path: '/profile/price-alerts',
        builder: (context, state) => const PriceAlertsScreen(),
      ),
      GoRoute(
        path: '/wallet/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/tickets/track',
        builder: (context, state) {
          final ticketData = state.extra as Map<String, dynamic>?;
          return BusTrackingScreen(ticketData: ticketData ?? {});
        },
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (context, state) => const LegalScreen(
          title: 'Conditions generales',
          content: 'Conditions d\'utilisation a completer.',
        ),
      ),
      GoRoute(
        path: '/stations',
        builder: (context, state) => const StationMapsScreen(),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (context, state) => const LegalScreen(
          title: 'Politique de confidentialite',
          content: 'Politique de protection des donnees a completer.',
        ),
      ),
    ],
    redirect: (context, state) {
      // La SplashScreen gere l'auto-login via getCurrentUser()
      // Le redirect ici protege uniquement les routes necessitant une auth
      final protectedRoutes = [
        '/home',
        '/search',
        '/my-tickets',
        '/companies',
        '/profile',
        '/passenger-info',
        '/payment',
        '/payment-success',
        '/confirmation',
        '/my-bookings',
        '/rating',
      ];
      final isProtected =
          protectedRoutes.any((r) => state.uri.path.startsWith(r));
      if (!isProtected) return null;
      // Si l'utilisateur arrive directement sur une route protegee
      // (ex: deep link) sans passer par splash, renvoyer sur /splash
      return null;
    },
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text('Route not found: ${state.uri}'),
        ),
      );
    },
  );
});
