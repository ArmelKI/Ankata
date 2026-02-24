# 🔧 GUIDE COMPLET DES CORRECTIONS - ANKATA

**Date** : 23 Février 2026  
**Statut** : En correction  
**Appareil** : Pixel 9a (Android 16)

---

## 📊 RÉSUMÉ DES PROBLÈMES

| # | Sévérité | Problème | Localisation | Statut |
|---|----------|----------|--------------|--------|
| 1 | 🔴 CRITIQUE | Erreur syntaxe Dart (if dans paramètre) | `api_service.dart:142,195` | ✅ FIXÉ |
| 2 | 🔴 CRITIQUE | RenderFlex overflow 6.9px | `companies_screen.dart:367` | ⏳ À FIXER |
| 3 | 🟠 GRAVE | Type Null vs String | Données null non gérées | ⏳ À FIXER |
| 4 | 🟡 MOYEN | Deprecated APIs | `.withValues(alpha:)` → `.withValues()` | ⏳ À FIXER |
| 5 | 🟡 MOYEN | Import non utilisé | `router.dart:12`, `line_model.dart:1` | ⏳ À FIXER |

**Total : 68 issues trouvées**

---

## 1️⃣ ERREUR SYNTAXE DART - FIXÉE ✅

### ❌ Problème
```dart
// Ligne 142 et 195 - MAUVAIS
queryParameters: if (date != null) {'date': date},
```

### ✅ Solution Appliquée
```dart
// Utiliser un Map temporaire
final queryParams = <String, dynamic>{};
if (date != null) {
  queryParams['date'] = date;
}
queryParameters: queryParams,
```

**Fichiers corrigés :**
- `lib/services/api_service.dart` - lignes 138-151 et 191-204

---

## 2️⃣ RENDERFLEX OVERFLOW - À FIXER 🔴

### ❌ Problème
```
A RenderFlex overflowed by 6.9 pixels on the right.
Location: companies_screen.dart:367:21 (Row widget)
Constraints: BoxConstraints(0.0<=w<=227.4, 0.0<=h<=Infinity)
```

### 🔍 Diagnostic
Le widget `Row` à la ligne 367 contient des enfants qui dépassent la largeur disponible (227.4px). C'est souvent dû à :
- Texte trop long sans `Expanded` ou `Flexible`
- Icônes/badge de compagnie mal espacés
- Padding/margin excessif

### ✅ Solutions Recommandées

**Option 1 : Utiliser `Expanded`**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Text(companyName), // Permet l'ellipsis
    ),
    RatingWidget(), // Reste à droite
  ],
)
```

**Option 2 : Wrapper avec `Flexible`**
```dart
Row(
  children: [
    Flexible(
      flex: 2,
      child: CompanyInfo(),
    ),
    Flexible(
      flex: 1,
      child: RatingBadge(),
    ),
  ],
)
```

**Option 3 : Utiliser `SingleChildScrollView` horizontal**
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(children: [...]),
)
```

### 📝 Fichier à corriger
- `lib/screens/companies/companies_screen.dart:367`

---

## 3️⃣ TYPE NULL ERRORS - À FIXER 🔴

### ❌ Problèmes
```
type 'Null' is not a subtype of type 'String'
```

Survient quand le code reçoit `null` mais attend une `String`.

### 🔍 Causes Possibles

1. **Phone/WhatsApp null** : Données de compagnie incomplètes
```dart
// ❌ MAUVAIS
company.whatsapp.contains('+')  // null.contains()

// ✅ BON
company.whatsapp?.contains('+') ?? false
```

2. **Rating null** : Compagnie sans évaluations
```dart
// ❌ MAUVAIS
company.rating.toString()

// ✅ BON
(company.rating ?? 0.0).toString()
```

3. **Logo URL null** : Pas d'image disponible
```dart
// ❌ MAUVAIS
Image.network(company.logoUrl)

// ✅ BON
company.logoUrl != null 
  ? Image.network(company.logoUrl!) 
  : Icon(Icons.business)
```

### ✅ Corrections à Appliquer

**Fichier : `lib/screens/companies/companies_screen.dart`**
- Ajouter null-coalescing `??` partout
- Utiliser `?.` pour optional chaining
- Fournir des valeurs par défaut

**Exemple complet :**
```dart
class CompanyCard extends StatelessWidget {
  final Company company;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Logo avec fallback
          company.logoUrl != null
              ? Image.network(company.logoUrl!)
              : Icon(Icons.business),
          
          // Nom (ne devrait jamais être null)
          Text(company.name),
          
          // Rating avec valeur par défaut
          Row(
            children: [
              Icon(Icons.star),
              Text('${company.rating ?? 0.0}/5'),
            ],
          ),
          
          // Phone avec safe access
          if (company.phone != null)
            Text(company.phone!),
          
          // WhatsApp avec safe access
          if (company.whatsapp != null)
            ElevatedButton(
              onPressed: () => launchWhatsApp(company.whatsapp!),
              child: Text('WhatsApp'),
            ),
        ],
      ),
    );
  }
}
```

---

## 4️⃣ DEPRECATED APIS - À FIXER ⏳

### ❌ Problèmes (47 instances)
```
'withOpacity' is deprecated. Use .withValues() instead.
```

### ✅ Conversion

**Avant :**
```dart
Colors.red.withValues(alpha:0.5)
```

**Après :**
```dart
Colors.red.withValues(alpha: 0.5)
```

### 📋 Fichiers à corriger (38 occurrences)

```
lib/config/app_theme.dart : 4x
lib/screens/booking/confirmation_screen.dart : 4x
lib/screens/booking/passenger_info_screen.dart : 3x
lib/screens/booking/payment_screen.dart : 5x
lib/screens/companies/companies_screen.dart : 2x
lib/screens/companies/company_details_screen.dart : 1x
lib/screens/home/home_screen.dart : 1x
lib/screens/profile/profile_screen.dart : 2x
lib/screens/tickets/my_tickets_screen.dart : 2x
lib/screens/trips/trip_search_results_screen.dart : 1x
lib/screens/trips/trip_search_screen.dart : 2x
```

### Autres Deprecated APIs

**Radio buttons (26 instances) :**
```dart
// ❌ MAUVAIS
Radio(
  groupValue: selectedValue,
  value: option,
  onChanged: (value) => setState(() => selectedValue = value),
)

// ✅ BON
Radio(
  value: option,
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**Opacity deprecated (1 instance) :**
```dart
// À : lib/screens/booking/payment_screen.dart:324
// ❌ MAUVAIS
if (paymentMethod != null) { ... }

// ✅ BON
if (paymentMethod != null && paymentMethod is String) { ... }
```

---

## 5️⃣ IMPORTS NON UTILISÉS - À FIXER ⏳

### Problèmes
```
Unused import: '../screens/trips/trip_search_screen.dart' 
  → lib/config/router.dart:12

Unused import: 'package:flutter/material.dart' 
  → lib/models/line_model.dart:1
```

### Solution
```bash
# Supprimez les lignes :
import '../screens/trips/trip_search_screen.dart';  // router.dart:12
import 'package:flutter/material.dart';  // line_model.dart:1
```

---

## 6️⃣ IMPROVE CODE QUALITY - SUGGESTIONS ⏳

### A. Utiliser `const` constructors
```dart
// ❌ 
SizedBox(height: 16)

// ✅
const SizedBox(height: 16)
```

**Fichiers affectés** (30+ instances) :
- `auth/phone_auth_screen.dart`
- `auth/splash_screen.dart`
- `booking/payment_screen.dart`
- `companies/companies_screen.dart`
- etc.

### B. Utiliser `final` pour les champs privés
```dart
class HomeScreen extends StatefulWidget {
  // ❌ MAUVAIS
  List<Passenger> _passengers = [];
  
  // ✅ BON
  final List<Passenger> _passengers = [];
}
```

### C. Null safety stricte
```dart
// ❌ Condition inutile
if (paymentMethod != null) { }

// ✅ Optimisé
if (paymentMethod case String method) { }
```

---

## 🎯 PLAN D'ACTION (Priorité)

### 🔴 IMMÉDIAT (Bloquer l'app)
1. ✅ Fixer syntax error dans `api_service.dart` 
2. ⏳ Fixer RenderFlex overflow dans `companies_screen.dart`
3. ⏳ Fixer type Null errors dans compagnie/rating/phone handling

### 🟡 URGENT (Avant production)
4. ⏳ Remplacer `.withValues(alpha:)` par `.withValues()`
5. ⏳ Fixer deprecated Radio buttons
6. ⏳ Supprimer imports non utilisés

### 🟢 STANDARD (Nice-to-have)
7. ⏳ Ajouter `const` constructors
8. ⏳ Utiliser `final` pour les champs privés
9. ⏳ Optimiser null safety

---

## 🚀 COMMANDES POUR APPLIQUER

```bash
# 1. Analyse complète
cd /mobile
flutter analyze

# 2. Fix automatique des imports
dart fix --apply

# 3. Formatter
dart format lib/

# 4. Build (teste la compilation)
flutter build apk --debug

# 5. Run avec logs
flutter run -v
```

---

## 🔗 RESSOURCES

- [Deprecated APIs - Flutter](https://api.flutter.dev/flutter/dart-io/Stdout/withValues.html)
- [RenderFlex - Layout Issues](https://docs.flutter.dev/development/ui/layout/troubleshooting)
- [Null Safety](https://dart.dev/null-safety)
- [Dart Fix](https://dart.dev/tools/dart-fix)

---

## 📝 NOTES

- **Pixel 9a détecté** ✅ : Android 16 (API 36)
- **Flutter version** : 3.41.2
- **Dart version** : Récent

L'app fonctionne mais a besoin de nettoyage. Tous les bugs sont corrigeables rapidement.

