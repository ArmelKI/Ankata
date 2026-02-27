import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'config/router.dart';
import 'providers/app_providers.dart';
import 'l10n/app_localizations.dart';
import 'services/ticket_cache_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'fr_FR';

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[OK] Firebase initialized successfully');
  } catch (e) {
    debugPrint('[WARNING] Firebase initialization error: $e');
  }

  await Hive.initFlutter();
  final userBox = await Hive.openBox('user_profile');
  final initialDarkMode = userBox.get('darkMode', defaultValue: false) as bool;
  final initialLocale = userBox.get('locale', defaultValue: 'fr') as String;

  // Initialize Services
  await TicketCacheService.init();
  await NotificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        darkModeProvider.overrideWith(
          (ref) => initialDarkMode,
        ),
        localeProvider.overrideWith(
          (ref) => Locale(initialLocale),
        ),
      ],
      child: const AnkataApp(),
    ),
  );
}

class AnkataApp extends ConsumerWidget {
  const AnkataApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(darkModeProvider);
    final dynamicPrimaryColor = ref.watch(dynamicThemeProvider);
    final currentLocale = ref.watch(localeProvider);

    AppColors.configureForBrightness(
      isDarkMode ? Brightness.dark : Brightness.light,
    );

    return MaterialApp.router(
      title: 'Ankata',
      theme: AppTheme.lightTheme(primaryColor: dynamicPrimaryColor),
      darkTheme: AppTheme.darkTheme(primaryColor: dynamicPrimaryColor),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: currentLocale,
    );
  }
}
