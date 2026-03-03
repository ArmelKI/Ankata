# FIREBASE SETUP COMPLET - ANKATA

## Vue d'ensemble

Firebase fournit:
- ️ **Cloud Messaging (FCM)**: Notifications push
- **Analytics**: Tracking comportement utilisateurs
- **Crashlytics**: Détection bugs automatique
- **Remote Config**: Paramètres dynamiques sans redéployer
- **Authentication**: Auth sociale (Google, Phone, etc)

**Impact**: Rétention +40%, Debug -80% temps, Analytics complet

---

## Étape 1: Configuration Firebase Console

### 1.1 Créer Projet Firebase

1. Aller sur [console.firebase.google.com](https://console.firebase.google.com)
2. Cliquer "Ajouter un projet"
3. Nom: **Ankata**
4. Activer Google Analytics: **Oui**
5. Compte Analytics: Créer nouveau ou utiliser existant
6. Créer projet (prend ~1 min)

### 1.2 Ajouter App Android

1. Dans console Firebase → **Project Overview**
2. Cliquer icône Android
3. **Package name**: `com.ankata.app` (doit matcher `mobile/android/app/build.gradle.kts`)
4. **App nickname**: Ankata Mobile
5. **SHA-1**: Optionnel pour v1 (requis pour Google Sign-In)
 ```bash
 # Obtenir SHA-1:
 cd mobile/android
 ./gradlew signingReport
 # Copier SHA-1 depuis output
 ```
6. Télécharger `google-services.json`
7. **Placer fichier**: `mobile/android/app/google-services.json`

### 1.3 Ajouter App iOS (Si applicable)

1. Cliquer icône iOS
2. **Bundle ID**: `com.ankata.app`
3. Télécharger `GoogleService-Info.plist`
4. Placer: `mobile/ios/Runner/GoogleService-Info.plist`

---

## Étape 2: Configuration Code Android

### 2.1 Modifier `android/build.gradle.kts`

```kotlin
// Fichier: mobile/android/build.gradle.kts

buildscript {
 dependencies {
  // Ajouter cette ligne:
  classpath("com.google.gms:google-services:4.4.0")
 }
}
```

### 2.2 Modifier `android/app/build.gradle.kts`

```kotlin
// Fichier: mobile/android/app/build.gradle.kts

plugins {
 id("com.android.application")
 id("kotlin-android")
 id("dev.flutter.flutter-gradle-plugin")
 // Ajouter cette ligne:
 id("com.google.gms.google-services")
}

dependencies {
 // Ajouter ces dépendances:
 implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
 implementation("com.google.firebase:firebase-analytics")
 implementation("com.google.firebase:firebase-messaging")
 implementation("com.google.firebase:firebase-crashlytics")
}
```

### 2.3 Permissions Android

```xml
<!-- Fichier: mobile/android/app/src/main/AndroidManifest.xml -->

<manifest>
 <!-- Ajouter ces permissions avant <application> -->
 <uses-permission android:name="android.permission.INTERNET"/>
 <uses-permission android:name="android.permission.VIBRATE"/>
 <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
 <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
 
 <application>
  <!-- Ajouter ce service pour FCM -->
  <service
   android:name=".Application"
   android:exported="false">
   <intent-filter>
    <action android:name="com.google.firebase.MESSAGING_EVENT"/>
   </intent-filter>
  </service>
 </application>
</manifest>
```

---

## Étape 3: Ajouter Packages Flutter

### 3.1 Modifier `pubspec.yaml`

```yaml
# Fichier: mobile/pubspec.yaml

dependencies:
 # Firebase Core (requis)
 firebase_core: ^2.24.0
 
 # Cloud Messaging (Notifications)
 firebase_messaging: ^14.7.6
 flutter_local_notifications: ^16.3.0
 
 # Analytics
 firebase_analytics: ^10.8.0
 
 # Crashlytics (Bug tracking)
 firebase_crashlytics: ^3.4.8
 
 # Remote Config
 firebase_remote_config: ^4.3.8
 
 # Performance Monitoring
 firebase_performance: ^0.9.3+8
```

### 3.2 Installer packages

```bash
cd mobile
flutter pub get
```

---

## Étape 4: Initialiser Firebase dans App

### 4.1 Créer Service Firebase

Créer: `mobile/lib/services/firebase_service.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
 static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
 static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
 static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

 /// Initialise Firebase (appeler au démarrage app)
 static Future<void> initialize() async {
 try {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
  };
  
  // Setup Notifications
  await _setupNotifications();
  
  // Setup Analytics
  await _analytics.setAnalyticsCollectionEnabled(true);
  
  debugPrint(' Firebase initialized successfully');
 } catch (e) {
  debugPrint(' Firebase initialization error: $e');
 }
 }

 /// Configure les notifications
 static Future<void> _setupNotifications() async {
 // Request permission
 final settings = await _messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
 );
 
 if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  debugPrint(' Notification permission granted');
  
  // Get FCM token
  final token = await _messaging.getToken();
  debugPrint(' FCM Token: $token');
  // TODO: Envoyer token au backend
  
  // Setup foreground handler
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  
  // Setup background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  
  // Setup local notifications
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const settings = InitializationSettings(
  android: androidSettings,
  iOS: iosSettings,
  );
  await _localNotifications.initialize(settings);
 }
 }

 /// Handler pour messages en foreground
 static void _handleForegroundMessage(RemoteMessage message) {
 debugPrint(' Foreground message: ${message.notification?.title}');
 
 // Afficher notification locale
 _showLocalNotification(
  title: message.notification?.title ?? 'Ankata',
  body: message.notification?.body ?? '',
  payload: message.data.toString(),
 );
 }

 /// Affiche notification locale
 static Future<void> _showLocalNotification({
 required String title,
 required String body,
 String? payload,
 }) async {
 const androidDetails = AndroidNotificationDetails(
  'ankata_channel',
  'Ankata Notifications',
  channelDescription: 'Notifications pour réservations, trajets, etc.',
  importance: Importance.high,
  priority: Priority.high,
  showWhen: true,
 );
 
 const iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
 );
 
 const details = NotificationDetails(
  android: androidDetails,
  iOS: iosDetails,
 );
 
 await _localNotifications.show(
  DateTime.now().millisecond,
  title,
  body,
  details,
  payload: payload,
 );
 }

 /// Log événement Analytics
 static Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
 await _analytics.logEvent(name: name, parameters: parameters);
 }

 /// Log écran Analytics
 static Future<void> logScreen(String screenName) async {
 await _analytics.logScreenView(screenName: screenName);
 }

 /// Set User ID pour Analytics
 static Future<void> setUserId(String userId) async {
 await _analytics.setUserId(id: userId);
 }

 /// Log erreur custom Crashlytics
 static Future<void> logError(dynamic error, StackTrace? stackTrace) async {
 await FirebaseCrashlytics.instance.recordError(error, stackTrace);
 }
}

/// Background handler (doit être top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
 await Firebase.initializeApp();
 debugPrint(' Background message: ${message.notification?.title}');
}
```

### 4.2 Modifier `main.dart`

```dart
// Fichier: mobile/lib/main.dart

import 'package:flutter/material.dart';
import 'services/firebase_service.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
 
 // Initialize Firebase
 await FirebaseService.initialize();
 
 runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});

 @override
 Widget build(BuildContext context) {
 return MaterialApp(
  // ... votre config existante
  navigatorObservers: [
  FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
 );
 }
}
```

---

## Étape 5: Utilisation dans l'App

### 5.1 Envoyer Notification Test

Dans Firebase Console:
1. **Cloud Messaging** → **Envoyer votre premier message**
2. Titre: "Test Ankata"
3. Texte: "Notification de test"
4. Cible: **Application unique** → Sélectionner "Ankata"
5. **Envoyer message de test**
6. Coller FCM token (visible dans logs)
7. Tester

### 5.2 Logger Analytics

```dart
// Dans n'importe quel screen
import '../services/firebase_service.dart';

// Log écran
@override
void initState() {
 super.initState();
 FirebaseService.logScreen('HomeScreen');
}

// Log événement
void onBookingComplete() {
 FirebaseService.logEvent('booking_completed', {
 'trip_id': '123',
 'amount': 5000,
 'company': 'STAF',
 });
}

// Log erreur
try {
 // Code susceptible d'erreur
} catch (e, stack) {
 FirebaseService.logError(e, stack);
}
```

### 5.3 Crashlytics - Test Crash

```dart
// Bouton de test (à enlever en production)
ElevatedButton(
 onPressed: () {
 throw Exception('Test crash');
 },
 child: Text('Test Crash'),
);
```

---

## Étape 6: Backend - Envoyer Notifications

### 6.1 Obtenir Server Key

1. Firebase Console → **Project Settings** → **Cloud Messaging**
2. Copier **Server key** (legacy)
3. Ou créer **Service Account** pour nouvelle API

### 6.2 Envoyer depuis Backend (Node.js)

```javascript
// backend/src/utils/firebase.js

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Télécharger depuis Firebase Console

admin.initializeApp({
 credential: admin.credential.cert(serviceAccount),
});

async function sendNotification(fcmToken, title, body, data = {}) {
 const message = {
 notification: {
  title,
  body,
 },
 data,
 token: fcmToken,
 };

 try {
 const response = await admin.messaging().send(message);
 console.log(' Notification sent:', response);
 return response;
 } catch (error) {
 console.error(' Notification error:', error);
 throw error;
 }
}

// Usage:
// sendNotification(
// userFcmToken,
// 'Réservation confirmée',
// 'Ton trajet vers Bobo est confirmé pour demain 8h',
// { trip_id: '123', type: 'booking_confirmed' }
// );

module.exports = { sendNotification };
```

---

## Coûts Firebase (Gratuit jusqu'à ces limites)

| Service | Plan Gratuit | Suffisant pour |
|---------|--------------|----------------|
| **Cloud Messaging** | Illimité | Toujours OK |
| **Analytics** | Illimité | Toujours OK |
| **Crashlytics** | Illimité | Toujours OK |
| **Remote Config** | Illimité | Toujours OK |

**Conclusion**: Tout est GRATUIT pour MVP et même au-delà de 100K utilisateurs !

---

## Checklist Finale

- [ ] Projet Firebase créé
- [ ] `google-services.json` placé dans `android/app/`
- [ ] `build.gradle.kts` modifiés
- [ ] Packages Flutter ajoutés
- [ ] `FirebaseService` créé
- [ ] `main.dart` modifié
- [ ] Notification test envoyée et reçue 
- [ ] Analytics logs visible dans console
- [ ] Crashlytics test crash visible

---

## Prochaines Étapes

1. **Intégrer partout**: Ajouter `FirebaseService.logScreen()` dans tous les screens
2. **Events business**: Logger achats, recherches, réservations
3. **Segments utilisateurs**: Créer audiences dans Analytics pour remarketing
4. **A/B Testing**: Utiliser Remote Config pour tester features

**Impact estimé**: +40% rétention, analytics complet, zéro crash invisible

