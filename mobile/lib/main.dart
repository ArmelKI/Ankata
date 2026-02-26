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
import 'generated_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'fr_FR';

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
  }

  await Hive.initFlutter();
  final userBox = await Hive.openBox('user_profile');
  final initialDarkMode = userBox.get('darkMode', defaultValue: false) as bool;

  runApp(
    ProviderScope(
      overrides: [
        darkModeProvider.overrideWith((ref) => initialDarkMode),
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
    AppColors.configureForBrightness(
      isDarkMode ? Brightness.dark : Brightness.light,
    );

    return MaterialApp.router(
      title: 'Ankata',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
