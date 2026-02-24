# 🚀 ACTIONS IMMÉDIATES - Ankata Flutter

**Statut** : 4 Erreurs critiques à fixer  
**Appareil** : Pixel 9a (détecté ✅)  
**Backend** : Fonctionnel ✅

---

## ⚡ QUICK START - Fixer Maintenant

### ÉTAPE 1 : Nettoyer et Réinstaller

```bash
cd /home/armelki/Documents/projets/Ankata/mobile

# Supprimer les anciens fichiers
rm -rf pubspec.lock build/ .dart_tool/

# Réinstaller
flutter pub get

# Format et fixes auto
dart format lib/ --fix
dart fix --apply
```

### ÉTAPE 2 : Analyser les Erreurs

```bash
flutter analyze
```

**Résultat attendu** : Moins de 70 issues (était 68)

### ÉTAPE 3 : Lancer sur Pixel 9a

```bash
# Voir tous les appareils
flutter devices

# Lancer sur Pixel 9a
flutter run -d 57191JEBF10407

# Ou simplement (détecte auto)
flutter run
```

---

## 🔴 4 ERREURS À FIXER MANUELLEMENT

### 1️⃣ RenderFlex Overflow (CRITIQUE)

**Fichier** : `lib/screens/companies/companies_screen.dart:367`

**Erreur** :
```
A RenderFlex overflowed by 6.9 pixels on the right
```

**Fix rapide** : Ouvrez le fichier et cherchez ligne 367, remplacez le `Row` par :

```dart
Row(
  children: [
    Expanded(
      child: Text(company.name, overflow: TextOverflow.ellipsis),
    ),
    const SizedBox(width: 8),
    // Widgets de droite
  ],
)
```

### 2️⃣ Type 'Null' is not a subtype of 'String'

**Causes** : `company.phone`, `company.whatsapp`, ou `company.rating` sont `null`

**Fix rapide** : Ajouter des vérifications null au lieu d'accès direct

```dart
// ❌ MAUVAIS
Text(company.phone ?? '...')

// ✅ BON
if (company.phone != null)
  Text(company.phone!)
```

### 3️⃣ Deprecated `.withOpacity()`

**Fichier** : 47 instances partout

**Replace All** : Utilisez l'éditeur VS Code

1. Appuyez sur `Ctrl+H` (Replace)
2. Chercher : `.withOpacity(`
3. Remplacer par : `.withValues(alpha: `
4. Remplacez tous

**Exemple** :
```dart
// ❌ AVANT
Colors.red.withOpacity(0.5)
Colors.blue.withOpacity(0.2)

// ✅ APRÈS
Colors.red.withValues(alpha: 0.5)
Colors.blue.withValues(alpha: 0.2)
```

### 4️⃣ Unused Imports

**Supprimez** :
- Ligne 12 dans `lib/config/router.dart` : `import '../screens/trips/trip_search_screen.dart';`
- Ligne 1 dans `lib/models/line_model.dart` : `import 'package:flutter/material.dart';`

---

## ✅ CHECKLIST FINAL

```bash
# 1. Nettoyer
rm -rf pubspec.lock build/ .dart_tool/ && flutter pub get

# 2. Formater
dart format lib/ --fix

# 3. Apprendre
dart fix --apply

# 4. Vérifier
flutter analyze

# 5. Lancer
flutter run
```

---

## 🎯 Vue d'ensemble

| Problème | Sévérité | Temps de fix | Status |
|----------|----------|-------------|--------|
| api_service.dart syntax | 🔴 | 30sec | ✅ FIXÉ |
| RenderFlex overflow | 🔴 | 5min | ⏳ URGENT |
| Null type errors | 🔴 | 10min | ⏳ URGENT |
| Deprecated APIs | 🟡 | 5min | ⏳ À FAIRE |
| Unused imports | 🟡 | 1min | ⏳ À FAIRE |

**Temps total estimé** : 20-30 minutes

---

## 📱 Test sur Pixel 9a

```bash
# Une fois les erreurs fixées :
flutter run -v

# Vous devriez voir :
✅ App lancée
✅ Interface en français  
✅ Connexion au backend
✅ Affichage des compagnies
```

---

##  🚀 Quoi Faire Après

1. **Test de recherche** : Essayez "Ouagadougou" → "Bobo-Dioulasso"
2. **Vérifier les compagnies** : Cliquez sur chaque compagnie
3. **Tester les horaires** : Regardez les horaires de chaque ligne
4. **Vérifier les prix** : Les prix doivent s'afficher correctement (FCFA)

---

Dites-moi quand vous avez lancé le script et je vous aiderai pour les corrections manuelles ! 🔧✨
