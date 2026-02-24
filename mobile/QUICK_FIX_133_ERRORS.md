# Guide Rapide: Fixer 133 Erreurs Dart (30-45min)

## 🎯 Plan d'ACTION

### PHASE 1: BookingModel (10 min)
**Problème**: 5 erreurs - BookingModel n'existe pas

**Solution** - Créer `lib/models/booking_model.dart`:
```dart
class BookingModel {
 final String id;
  final String userId;
  final String tripId;
  final int passengers;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.passengers,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['userId'],
      tripId: json['tripId'],
      passengers: json['passengers'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

**Import dans** `lib/providers/app_providers.dart`:
```dart
import '../models/booking_model.dart';
```

---

### PHASE 2: CompanyColors Import (5 min)
**Problème**: 8 erreurs - CompanyColors undefined (import manquant)

**Fix** - Ajouter import à ces 4 fichiers:
```dart
import '../../config/app_constants.dart';
```

**Fichiers**:
1. `lib/screens/booking/confirmation_screen.dart` - ligne 2
2. `lib/screens/companies/companies_screen.dart` - ligne 2
3. `lib/screens/companies/company_details_screen.dart` - ligne 2
4. `lib/screens/tickets/my_tickets_screen.dart` - ligne 4

---

### PHASE 3: Color Wrapper (5 min)
**Problème**: 4 erreurs - `int` passé au lieu de `Color`

**Before**:
```dart
color: CompanyColors.getCompanyColor(company)  // Retourne int
```

**After**:
```dart
color: Color(CompanyColors.getCompanyColor(company))
```

**Fichiers & lines**:
- `lib/screens/home/home_screen.dart`: lines 351-354 (4 x `Color()`)

---

### PHASE 4: Payment Screen (10 min)
**Problème**: 5 erreurs - Paramètres manquants/mal utilisés

**File**: `lib/screens/payment/payment_screen.dart` line 64
- ❌ `ProgressStepper(totalSteps: ...)` mauvais paramètre
- ✅ À corriger: Vérifier documentation widget et ajouter `steps:` parameter

**File**: `lib/screens/payment/payment_success_screen.dart`
- Lines 69, 75: Too many positional arguments
- ✅ À corriger: Vérifier signature XPService et remplacer par named params

---

### PHASE 5: ApiService (5 min)
**Problème**: 2 erreurs - `getUserBookings` n'existe pas

**Option A** - Ajouter à `lib/services/api_service.dart`:
```dart
Future<List<BookingModel>> getUserBookings(String userId) async {
  // Appel API backend
}
```

**Option B** (Recommandé) - Utiliser BookingService:
```dart
// Dans app_providers.dart:
final bookingService = BookingService();
final bookings = await bookingService.getUserBookings(userId);
```

---

## 🚀 COMMANDE FINALE

```bash
cd /home/armelki/Documents/projets/Ankata/mobile

# 1. Créer BookingModel
cat > lib/models/booking_model.dart << 'EOF'
class BookingModel {
  final String id;
  final String userId;
  final String tripId;
  final int passengers;
  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.passengers,
    required this.status,
    required this.createdAt,
  });
}
EOF

# 2. Tester
flutter analyze | grep -E "error" | head -20

# Si erreurs baissent → Tu es sur le bon chemin!
```

---

## 📊 Checklist

- [ ] BookingModel créé
- [ ] 4 imports app_constants ajoutés
- [ ] 4 x Color() wrapper home_screen
- [ ] Payment screen paramètres fixés
- [ ] ApiService méthode ajoutée
- [ ] Test: `flutter analyze` → <50 erreurs
- [ ] Test: `flutter run` → Pas de crash

---

## ⏱️ Temps Estimé

| Phase | Temps | Cumul |
|-------|-------|-------|
| P1: BookingModel | 10 min | 10 min |
| P2: Imports | 5 min | 15 min |
| P3: Color() | 5 min | 20 min |
| P4: PaymentScreens | 10 min | 30 min |
| P5: ApiService | 5 min | 35 min |
| **Total** | **~35 min** | - |

---

## 🎯 Success Criteria

Après ces changements:
- ✅ Dart errors < 50
- ✅ Build apk compiles
- ✅ App lance sur émulateur
- ✅ Pas de runtime crashes sur Home/Trips
