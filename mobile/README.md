# Ankata Mobile

Application Flutter de reservation de transports au Burkina Faso.

**Auteur :** Armel Stephane Novak  
**Version :** 1.0.0  
**Backend :** https://ankata.onrender.com

---

## Demarrage rapide

### Prerequis
- Flutter >= 3.0.0
- Dart >= 3.0.0
- Android SDK

### Installation

```bash
flutter pub get
flutter run
```

### Build APK release

```bash
flutter build apk --release
# Output : build/app/outputs/flutter-apk/app-release.apk
```

---

## Structure du projet

```
lib/
|-- config/         # Theme, router, constantes, l10n
|-- data/           # Donnees statiques (compagnies, lignes, horaires)
|-- l10n/           # Fichiers de localisation (fr, en)
|-- models/         # Modeles de donnees
|-- providers/      # Providers Riverpod
|-- screens/        # Ecrans de l'application
|   |-- auth/       # Splash, Onboarding, Login, Register
|   |-- booking/    # Passager, Confirmation
|   |-- bookings/   # Mes reservations
|   |-- companies/  # Liste et details des compagnies
|   |-- home/       # Ecran d'accueil et recherche
|   |-- payment/    # Paiement (en developpement)
|   |-- profile/    # Profil utilisateur
|   |-- ratings/    # Avis
|   |-- sotraco/    # Lignes urbaines Ouagadougou
|   |-- support/    # FAQ, Feedback, Mentions legales
|   |-- tickets/    # Mes billets
|   |-- trips/      # Resultats et details trajets
|-- services/       # API, paiement, streaks, XP
|-- utils/          # Helpers (haptic, validators, etc.)
|-- widgets/        # Composants reutilisables
|-- main.dart       # Point d'entree
```

---

## Fonctionnalites

- Authentification (email/mot de passe, Google)
- Recherche de trajets par origine/destination/date
- Reservation multi-passagers avec selection de sieges
- Mes billets et historique de reservations
- Annulation de reservation
- Avis et notations des compagnies
- Gestion du profil et de la photo
- Parrainage
- Mode sombre

---

## Configuration API

L'URL du backend est definie dans `lib/config/constants.dart` :

```dart
static const String apiBaseUrl = 'https://ankata.onrender.com/api';
```

---

## Depannage build

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Si erreur AAPT `lStar not found` :
```bash
# Patcher le plugin printing dans le cache pub
sed -i 's/compileSdkVersion 30/compileSdkVersion 36/g' \
  ~/.pub-cache/hosted/pub.dev/printing-5.12.0/android/build.gradle
```
