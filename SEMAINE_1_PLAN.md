# 🎬 PLAN D'ACTION SEMAINE 1 - Ankata

**Période** : Lundi 23 Février → Vendredi 27 Février 2026  
**Objectif** : Version 0.1.0 Beta (Testable)  
**Priorité** : 🔴 Corrections + 🟡 Core features

---

## 📅 JOUR 1 (AUJOURD'HUI - LUNDI 23/02)

### ⏰ Matin (2 heures)

#### Tâche 1.1 : Corriger Compilation ✅ EN COURS
```bash
cd /home/armelki/Documents/projets/Ankata/mobile

# Nettoyage complet
rm -rf pubspec.lock build/ .dart_tool/
flutter pub get

# Fixes automatiques
dart fix --apply
dart format lib/ --fix

# Vérifier compilation
flutter analyze
flutter build apk --debug
```

**Résultat attendu** : 0 erreurs, <5 warnings

#### Tâche 1.2 : Corriger Imports Non Utilisés ⏳
```bash
# Supprimez ces 2 lignes :

# 1. lib/config/router.dart:12
- import '../screens/trips/trip_search_screen.dart';

# 2. lib/models/line_model.dart:1
- import 'package:flutter/material.dart';
```

### ⏰ Après-midi (2 heures)

#### Tâche 1.3 : Test sur Pixel 9a ⏳
```bash
# Connecter le téléphone via USB Debug
flutter devices  # Voir Pixel 9a

# Lancer l'app
flutter run -d 57191JEBF10407

# Tester navigation
✅ Home screen
✅ Companies list
✅ Navigation menu
```

**Success Criteria** :
- App se lance sans crash
- Interface en français
- Connexion API OK (voir logo SOTRACO)

#### Tâche 1.4 : Documentation Initial ✅
```bash
# Lire les fichiers
- README.md (backend)
- DATABASE_README.md
- API_TESTS.md (backend)
- CORRECTIONS_GUIDE.md (mobile)
```

---

## 📅 JOUR 2 (MARDI 24/02)

### ⏰ Matin (3 heures)

#### Tâche 2.1 : Implémenter Origin-Destination Pickers 📍

**Fichier** : `lib/screens/home/home_screen.dart`

**Fonctionnalités** :
```dart
- [x] Liste des villes (Ouagadougou, Bobo-Dioulasso, etc.)
- [x] Autocomplete search city
- [x] Swap origin/destination button
- [x] Recent searches display

// Pseudo-code
Column(
  children: [
    CityPickerField(
      label: 'D'où?',
      value: originCity,
      onChanged: (city) => setOrigin(city),
    ),
    
    SwapButton(onPressed: () => swap()),
    
    CityPickerField(
      label: 'Vers où?',
      value: destinationCity,
      onChanged: (city) => setDestination(city),
    ),
  ],
)
```

**Temps estimé** : 90 min

#### Tâche 2.2 : Implémenter Date Picker 📅

**Fichier** : `lib/screens/home/home_screen.dart`

```dart
- [x] DateTimeRange picker
- [x] Min date: today
- [x] Max date: +30 days
- [x] Disable past dates
- [x] Format: "23 Février 2026"

GestureDetector(
  onTap: () => showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 30)),
  ),
)
```

**Temps estimé** : 60 min

### ⏰ Après-midi (2 heures)

#### Tâche 2.3 : Intégrer API Search 🔍

**Fichier** : `lib/services/api_service.dart`

**Endpont** :
```
GET /api/lines/search?origin=Ouagadougou&destination=Bobo-Dioulasso&date=2026-02-24
```

**Response Mapping** :
```dart
class SearchResult {
  final String lineId;
  final String companyName;
  final String companySlug;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int price;  // FCFA
  final int availableSeats;
  final double rating;
  
  // Factory from JSON
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      lineId: json['id'] as String,
      companyName: json['company']['name'] as String,
      // ... etc
    );
  }
}
```

**Temps estimé** : 60 min

#### Tâche 2.4 : Créer Results Screen ⏳

**Fichier** : `lib/screens/trips/trip_search_results_screen.dart`

```dart
- [x] ListView of SearchResults
- [x] Sort by price/duration/rating
- [x] Filter by company
- [x] Show price en FCFA
- [x] Show duration (hh:mm)
- [x] Tap to view details

Card(
  child: Column(
    children: [
      CompanyHeader(company: result.company),
      PriceRow('${result.price} FCFA'),
      TimesRow('${result.departureTime} → ${result.arrivalTime}'),
      DurationRow('${result.duration}h'),
      RatingRow(result.rating),
    ],
  ),
)
```

**Temps estimé** : 90 min

---

## 📅 JOUR 3 (MERCREDI 25/02)

### ⏰ Matin (2.5 heures)

#### Tâche 3.1 : Page Détails Compagnie 🏢

**Fichier** : `lib/screens/companies/company_details_screen.dart`

```dart
Sections:
[x] Header (logo, nom, couleur primaire)
[x] Rating & stats
[x] Contact info (phone, WhatsApp)
[x] Description
[x] Flotte (nombre bus, types)
[x] Horaires moyens
[x] Avis clients (top 5)
[x] Badge (Premium, Prix bas, etc.)

// Afficher aussi
- [x] Heure de départ moyenne
- [x] Durée moyenne
- [x] Prix moyen
```

**Temps estimé** : 90 min

#### Tâche 3.2 : Intégrer Ratings Backend ⭐

**API Endpoint** :
```
GET /api/companies/{id}/ratings
```

**Display** :
```dart
- [x] Moyenne globale (4.5/5)
- [x] Nombre d'avis (2847)
- [x] Distribution (5 stars: 60%, 4 stars: 30%, etc.)
- [x] Récents avis (nom, texte, date, note)
```

**Temps estimé** : 60 min

### ⏰ Après-midi (2 heures)

#### Tâche 3.3 : Intégrer Horaires Détaillés ⏰

**API Endpoint** :
```
GET /api/lines/{lineId}/schedules?day=LUNDI
```

**Display** :
```dart
- [x] Day selector (LUNDI, MARDI, ...)
- [x] List of departure times
- [x] Pour chaque: Heure, prix, sièges dispo, type (standard/VIP)
- [x] Tap to select for booking

// Exemple affichage
"Lundi 24 février"
05:50 → 05:50 | 150 FCFA | 42/60 sièges | Éco
06:05 → 06:05 | 150 FCFA | 55/60 sièges | Éco
...
```

**Temps estimé** : 60 min

---

## 📅 JOUR 4 (JEUDI 26/02)

### ⏰ Matin (3 heures)

#### Tâche 4.1 : Implémenter Booking Flow 🎫

**Fichiers** : `lib/screens/booking/`

```
Flow:
home
  ↓ Cherche Ouaga→Bobo Lundi
search_results
  ↓ RAHIMO à 07:30 pour 6500 FCFA
booking_screen (SELECT SEATS) ← JOUR 4.1
  ↓ Sélectionne 2 sièges
passenger_info_screen (PASSENGER INFO) ← JOUR 4.2
  ↓ Nom, Phone
payment_screen (PAYMENT) ← JOUR 4.3
  ↓ Choisit Orange Money
confirmation_screen ← JOUR 4.4
```

**4.1 - SelectSeatsScreen** : 
```dart
- [x] Affiche plan bus (60/70 sièges)
- [x] Sièges verts = dispo, gris = occupés
- [x] Tap pour sélectionner
- [x] Multi-select
- [x] Affiche prix total dynamique
- [x] Button "Continuer"

UI: Grid(6 colonnes) affichant sièges
```

**Temps estimé** : 90 min

#### Tâche 4.2 : Info Passager ✍️

**PassengerInfoScreen** :
```dart
- [x] Form fields:
    - [x] Nom complet
    - [x] Email
    - [x] Téléphone
    - [x] Pièce d'identité (optionnel)
- [x] Validation
- [x] Button "Continuer au paiement"
```

**Temps estimé** : 45 min

#### Tâche 4.3 : Intégration OTP Auth 🔐

**Fichier** : `lib/screens/auth/phone_auth_screen.dart`

```dart
// Phone verification flow
1. User enters phone
2. Backend sends OTP via SMS
3. User enters OTP code
4. Verify + get JWT token
5. Store token in secure storage

// Endpoints
POST /api/auth/send-otp
{
  "phone": "+22670123456"
}

POST /api/auth/verify-otp
{
  "phone": "+22670123456",
  "code": "123456"
}
```

**Temps estimé** : 90 min

### ⏰ Après-midi (2 heures)

#### Tâche 4.4 : Payment Screen (Base) 💳

**PaymentScreen** :
```dart
Methods (actuellement):
[ ] Orange Money ← JOUR 5.1
[ ] Moov Money ← JOUR 5.2
[ ] Manual transfer

Display:
- [x] Method selection
- [x] Price recap
- [x] Terms & conditions
- [x] Button "Confirmer réservation"
```

**Temps estimé** : 60 min

#### Tâche 4.5 : Confirmation Screen ✅

**ConfirmationScreen** :
```dart
- [x] Booking code (8 digits)
- [x] Itinerary summary
- [x] Booking details
- [x] Download ticket/screenshots
- [x] Button "Accueil"
```

**Temps estimé** : 60 min

---

## 📅 JOUR 5 (VENDREDI 27/02)

### ⏰ Toute la journée (6 heures)

#### Tâche 5.1-5.2 : Intégration Payment APIs ⏳

**À faire matin** :
```bash
# Contacter les providers:
- Orange Money (API docs)
- Moov Money (API docs)

# Intégrer endpoints:
- Create payment session
- Handle callback/webhook
- Update booking status
```

**Temps estimé** : 120 min

#### Tâche 5.3-5.4 : Test Complet End-To-End 🧪

```bash
# Test sur Pixel 9a:

1. Search Flow (20 min)
   ✅ Ouvrir app
   ✅ Sélectionner Ouaga → Bobo
   ✅ Choisir date
   ✅ Voir 8 résultats
   ✅ Affichage correct (prix, durée, rating)

2. Company Details (15 min)
   ✅ Cliquer sur RAHIMO
   ✅ Voir logo/couleur
   ✅ Affichage infos (4.6/5 stars, 432 avis)
   ✅ Horaires par jour

3. Booking Flow (20 min)
   ✅ Sélectionner horaire
   ✅ Layout bus s'affiche
   ✅ Sélectionner 2 sièges
   ✅ Entrer info passager
   ✅ Voir prix final (13,000 FCFA)
   ✅ Confirmation code généré

4. Performance Check (10 min)
   ✅ Search <500ms
   ✅ App 60 FPS
   ✅ Pas de memory leaks
```

**Temps estimé** : 120 min

#### Tâche 5.5 : Nettoyage & Documentation ⏳

```bash
# Final cleanup
flutter clean
flutter pub get
dart fix --apply
dart format lib/ --fix
flutter analyze  # 0 errors

# Build release APK
flutter build apk --release

# Commit
git add .
git commit -m "feat: Complete Ankata v0.1.0 Beta Core Features"
git push
```

**Temps estimé** : 30 min

#### Tâche 5.6 : Sprint Review & Roadmap 📊

```bash
# Documentation for next sprint:
- [x] Créer ROADMAP_V0.2.md
- [x] List feedback from testing
- [x] Préparer tasks pour semaine 2
```

---

## 🎯 DEFINITION OF DONE

### Code Quality ✅
```
[x] 0 compile errors
[x] 0 critical warnings
[x] All code formatted (dart format)
[x] All imports clean
[x] Null safety strict mode
```

### Testing ✅
```
[x] Manual E2E on Pixel 9a
[x] All screens navigable
[x] API responses handled
[x] Error states tested
[x] Performance >60 FPS
```

### Documentation ✅
```
[x] Code comments for complex logic
[x] Function documentation
[x] Error handling docs
[x] API integration docs
```

### Git ✅
```
[x] Meaningful commit messages
[x] One commit per feature
[x] No broken commits
[x] Clean history
```

---

## 📊 VELOCITY ESTIMATES

```
Semaine 1: 42 heures (5 jours)

Detailing:
- Jour 1: 4h (Fixes + Setup)
- Jour 2: 5h (Search + Pickers)
- Jour 3: 5h (Details + Ratings)
- Jour 4: 7h (Booking flow + Auth)
- Jour 5: 6h (Payment + Testing)
Total: 27h development + 15h testing/doc/cleanup = 42h

Story Points (Planning Poker):
- Search feature: 13 points
- Booking flow: 21 points
- Details page: 8 points
- Auth OTP: 13 points
- Payment: 13 points
Total: 68 points
Velocity: 13-14 points/day
```

---

## 🚨 CRITICAL PATH

```
BLOCKER 1: Compilation (Done Today - 2h)
  └─ Needed for: Everything
  
BLOCKER 2: API Connection (Today - 1h)
  └─ Needed for: All API calls
  
BLOCKER 3: Search Feature (Tue - 4h)
  └─ Needed for: Results, Booking
  
BLOCKER 4: OTP Auth (Thu - 2h)
  └─ Needed for: Booking confirmation
  
BLOCKER 5: Payment Integration (Fri - 2h)
  └─ Needed for: Complete booking flow
```

---

## 💼 RESOURCE ALLOCATION

```
Full-time: 1 developer (vous)
Part-time: 0.5 backend support (clarifications)
Tools: VS Code, Pixel 9a, Postman

Meetings:
- Daily standup: 10 min (async → Slack)
- Mid-week review (Wed EOD): 30 min
- Friday retrospective: 45 min
```

---

## 🎉 SUCCESS METRICS

**End of Week 1:**
```
[x] Version 0.1.0 Beta deployed internally
[x] All 5 screens navigable on Pixel 9a
[x] Search working (Ouaga→Bobo)
[x] Can book 1 trip end-to-end
[x] No critical bugs
[x] Performance >60 FPS
[ ] Payment API connected (stretch)
```

**NPS Score Prediction** : 3.5/5 (Beta feedback target)

---

**Generated**: 23 Février 2026  
**Owner**: Vous  
**Status**: Ready to Execute 🚀

