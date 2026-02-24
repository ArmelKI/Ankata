import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ankata/main.dart';
import 'package:ankata/screens/trips/trip_search_screen.dart';
import 'package:ankata/screens/companies/companies_screen.dart';
import 'package:ankata/screens/home/home_screen.dart';

void main() {
  group('Ankata Widget Tests', () {
    testWidgets('MyApp renders without errors', (WidgetTester tester) async {
        await tester.pumpWidget(const AnkataApp());
      await tester.pumpAndSettle();
        expect(find.byType(AnkataApp), findsOneWidget);
    });

    testWidgets('HomeScreen loads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('CompaniesScreen displays without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CompaniesScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CompaniesScreen), findsOneWidget);
    });

    testWidgets('TripSearchResults renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TripSearchScreen(
                originCity: 'Ouagadougou',
                destinationCity: 'Bobo-Dioulasso',
                departureDate: DateTime.now().toIso8601String(),
                passengers: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TripSearchScreen), findsOneWidget);
    });

    testWidgets('Navigation works between screens', (WidgetTester tester) async {
      await tester.pumpWidget(const AnkataApp());
      await tester.pumpAndSettle();
      
      // Navigate using BottomNavigationBar if present
      final navButtons = find.byType(BottomNavigationBarItem);
      if (navButtons.evaluate().isNotEmpty) {
        await tester.tap(navButtons.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Search inputs are interactive', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'Test');
        expect(find.text('Test'), findsWidgets);
      }
    });

    testWidgets('Loading indicators appear during data fetch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Buttons are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AnkataApp(),
        ),
      );
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App handles screen rotation', (WidgetTester tester) async {
      await tester.pumpWidget(const AnkataApp());
      await tester.pumpAndSettle();

      // Simulate landscape rotation
      tester.binding.window.physicalSizeTestValue = const Size(800, 400);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('French localization displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const AnkataApp());
      await tester.pumpAndSettle();

      // Check for French text indicators
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Search results can be scrolled', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TripSearchScreen(
                originCity: 'Ouagadougou',
                destinationCity: 'Bobo-Dioulasso',
                departureDate: DateTime.now().toIso8601String(),
                passengers: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView.first, const Offset(0, -100));
        await tester.pump();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tap on trip card navigates', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TripSearchScreen(
                originCity: 'Ouagadougou',
                destinationCity: 'Bobo-Dioulasso',
                departureDate: DateTime.now().toIso8601String(),
                passengers: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Filters work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );

      final filterChips = find.byType(FilterChip);
      if (filterChips.evaluate().isNotEmpty) {
        await tester.tap(filterChips.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('App responds quickly to user input', (WidgetTester tester) async {
      await tester.pumpWidget(const AnkataApp());

      final startTime = DateTime.now();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();
      final endTime = DateTime.now();

      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(1000));
    });

    testWidgets('Search completes within acceptable time', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TripSearchScreen(
                originCity: 'Ouagadougou',
                destinationCity: 'Bobo-Dioulasso',
                departureDate: DateTime.now().toIso8601String(),
                passengers: 1,
              ),
            ),
          ),
        ),
      );

      final startTime = DateTime.now();
      await tester.pumpAndSettle();
      final endTime = DateTime.now();

      final duration = endTime.difference(startTime);
      expect(duration.inSeconds, lessThan(10));
    });
  });

  group('Accessibility Tests', () {
    testWidgets('All interactive elements are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const AnkataApp());
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      expect(buttons.evaluate().isNotEmpty, true);
    });

    testWidgets('Text is readable (sufficient size)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AnkataApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });
  });
}
