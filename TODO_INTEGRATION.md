# ✅ TODO LIST - INTÉGRATION ANKATA

## ⚡ FAIT AUTOMATIQUEMENT

- [x] 21 nouveaux fichiers créés
- [x] pubspec.yaml mis à jour (Firebase, share_plus, etc.)
- [x] main.dart mis à jour (streak check au démarrage)
- [x] HomeScreen: SponsorBanner ajoutée
- [x] HomeScreen: AnimatedButton + Haptic
- [x] ProfileScreen: UserAvatar
- [x] ProfileScreen: StreakWidget + XPBar
- [x] ProfileScreen: Section Badges
- [x] ProfileScreen: Section Premium & Referral

---

## 📦 ÉTAPE 1: PACKAGES (5 min)

- [ ] `cd mobile && flutter pub get`
- [ ] Vérifier qu'il n'y a pas d'erreur de package

---

## 🎨 ÉTAPE 2: UX CORE (1h30)

### Haptic Feedback (35 min)
- [ ] Ajouter `HapticHelper.lightImpact()` dans TOUS les boutons existants
- [ ] trip_search_results_screen.dart → Tap sur trajet
- [ ] companies_screen.dart → Tap sur compagnie
- [ ] booking_details_screen.dart → Boutons actions
- [ ] Tous les autres boutons/taps

### Skeleton Loaders (35 min)
- [ ] HomeScreen → Remplacer CircularProgressIndicator par TripCardSkeleton
- [ ] CompaniesScreen → Remplacer par CompanyCardSkeleton
- [ ] ProfileScreen → Remplacer par ProfileSkeleton
- [ ] trip_search_results_screen.dart → TripCardSkeleton list
- [ ] Tous les autres spinners

### Animated Buttons (20 min)
- [ ] trip_search_screen.dart → Bouton "Rechercher"
- [ ] passenger_info_screen.dart → Bouton "Continuer"
- [ ] login_screen.dart → Bouton "Se connecter"
- [ ] register_screen.dart → Bouton "S'inscrire"
- [ ] Tous les autres ElevatedButton

---

## 📍 ÉTAPE 3: NAVIGATION & FLOW (45 min)

### Progress Stepper (15 min)
- [ ] trip_search_screen.dart → `ProgressStepper(currentStep: 0, totalSteps: 4)`
- [ ] trip_search_results_screen.dart → `currentStep: 1`
- [ ] passenger_info_screen.dart → `currentStep: 2`
- [ ] payment_screen.dart → `currentStep: 3` (déjà fait normalement)

### Scroll to Top Button (10 min)
- [ ] trip_search_results_screen.dart → Ajouter ScrollToTopButton
- [ ] companies_screen.dart → Ajouter ScrollToTopButton
- [ ] my_bookings_screen.dart → Ajouter ScrollToTopButton

### Undo Snackbar (20 min)
- [ ] Remplacer tous les SnackBar standards par UndoSnackbar
- [ ] my_bookings_screen.dart → Annulation réservation avec undo
- [ ] Suppression favori avec undo
- [ ] Déconnexion avec confirmation

---

## 🎨 ÉTAPE 4: VISUELS (35 min)

### Company Logos (20 min)
- [ ] trip_card.dart → Ajouter CompanyLogo
- [ ] company_card.dart → Remplacer initiale par CompanyLogo
- [ ] company_details_screen.dart → CompanyLogo + VerifiedBadge
- [ ] booking_details_screen.dart → CompanyLogo
- [ ] Tous les autres affichages compagnie

### User Avatars (15 min)
- [ ] review_card.dart → UserAvatar pour reviewers
- [ ] Toutes les listes d'utilisateurs

---

## 💰 ÉTAPE 5: MONÉTISATION (50 min)

### Premium Dialog (30 min)
- [ ] trip_search_results_screen.dart → Déclencher après 3 recherches
  ```dart
  final prefs = await SharedPreferences.getInstance();
  final searchCount = prefs.getInt('search_count') ?? 0;
  if (searchCount == 3) {
    Future.delayed(Duration(seconds: 2), () => showPremiumDialog(context));
  }
  await prefs.setInt('search_count', searchCount + 1);
  ```

### Referral Dialog (20 min)
- [ ] payment_success_screen.dart → Déclencher après 1ère réservation
  ```dart
  Future.delayed(Duration(seconds: 5), () {
    showReferralDialog(context);
  });
  ```

---

## 🎮 ÉTAPE 6: GAMIFICATION (1h10)

### XP Tracking (40 min)
- [ ] Après réservation → `XPService.addXP(10, 'Réservation effectuée')`
- [ ] Après note → `XPService.addXP(5, 'Avis laissé')`
- [ ] Après referral → `XPService.addXP(20, 'Ami parrainé')`
- [ ] Profil complété → `XPService.addXP(50, 'Profil complété')`
- [ ] 1ère réservation → `XPService.addXP(100, 'Première réservation! 🎉')`

### Badge Checks (30 min)
- [ ] Après chaque réservation → Vérifier badges
  ```dart
  final badges = await BadgeService.checkAndUnlockBadges(userStats);
  if (badges.isNotEmpty) {
    for (var badge in badges) {
      showBadgeUnlockedDialog(context, badge);
    }
  }
  ```

---

## 💳 ÉTAPE 7: PAIEMENT (1h)

### Integration Payment Flow
- [ ] passenger_info_screen.dart → Bouton "Continuer vers le paiement"
  ```dart
  Navigator.push(context, MaterialPageRoute(
    builder: (context) => PaymentScreen(
      amount: trip.price * passengerCount,
      bookingId: bookingId,
      tripDetails: '${trip.origin} → ${trip.destination}',
    ),
  ));
  ```

### Routes (app_router.dart)
- [ ] Ajouter route `/payment`
- [ ] Ajouter route `/payment-success`
- [ ] Ajouter route `/payment-history`

---

## 🔥 ÉTAPE 8: FIREBASE (1-2h - OPTIONNEL)

- [ ] Créer projet Firebase Console
- [ ] Télécharger `google-services.json` → `android/app/`
- [ ] Télécharger `GoogleService-Info.plist` → `ios/Runner/`
- [ ] Modifier `android/build.gradle.kts` (voir FIREBASE_SETUP_GUIDE.md)
- [ ] Modifier `android/app/build.gradle.kts`
- [ ] Décommenter imports Firebase dans main.dart
- [ ] Créer `lib/services/firebase_service.dart` (code dans guide)
- [ ] Tester notification

---

## 🧪 ÉTAPE 9: TESTS (1h)

- [ ] `flutter run` sur émulateur
- [ ] Tester flow complet booking
  - [ ] Recherche trajet
  - [ ] Sélection trajet
  - [ ] Infos passagers
  - [ ] Paiement (mock)
  - [ ] Succès avec confetti
- [ ] Tester gamification
  - [ ] Streak au démarrage
  - [ ] XP gagné après action
  - [ ] Badge unlock
- [ ] Tester UI
  - [ ] Toutes les animations fluides
  - [ ] Haptic feedback fonctionne
  - [ ] Skeleton loaders s'affichent
- [ ] Tester navigation
  - [ ] Progress stepper affiche correctement
  - [ ] Scroll to top apparaît
- [ ] Tester monetization
  - [ ] Premium dialog après 3 recherches
  - [ ] Referral dialog affiche bien

---

## 🚀 ÉTAPE 10: RELEASE (1h)

- [ ] Version bump dans pubspec.yaml: `version: 0.2.0+2`
- [ ] Changelog
- [ ] `flutter build apk --release`
- [ ] `flutter build appbundle --release`
- [ ] Tester APK sur vrai device
- [ ] Upload Play Store
- [ ] Upload App Store (si iOS)

---

## 🔮 POST-LAUNCH

### Backend Paiement (2-3 jours)
- [ ] Contacter Orange Money: digitalservices@orange.bf
- [ ] Obtenir credentials Orange
- [ ] Implémenter backend routes (voir PAIEMENT_SETUP_GUIDE.md)
- [ ] Tester en sandbox
- [ ] Déployer en production

### Monitoring
- [ ] Vérifier Firebase Analytics fonctionne
- [ ] Monitorer crash rate
- [ ] Monitorer conversion funnel

### Marketing
- [ ] Push initial parrainage
- [ ] Négocier sponsors (3 partenaires minimum)
- [ ] Lancer premium (early bird pricing?)

---

## 📊 TEMPS TOTAL ESTIMÉ

| Phase | Temps |
|-------|-------|
| Packages | 5 min |
| UX Core | 1h30 |
| Navigation & Flow | 45 min |
| Visuels | 35 min |
| Monétisation | 50 min |
| Gamification | 1h10 |
| Paiement | 1h |
| Firebase | 1-2h (optionnel) |
| Tests | 1h |
| Release | 1h |
| **TOTAL** | **~8-9h** |

---

## 🎯 TRACK PROGRESS

**Progression**: _____ / 50+ tâches complétées

Quand tu as tout coché ✅ → **L'app est prête à exploser! 🚀**

**Commence maintenant**: `cd mobile && flutter pub get`

