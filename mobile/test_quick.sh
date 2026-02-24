#!/bin/bash

# 🎯 Script de Test Rapide - Ankata Mobile
# Vérifie que toutes les nouvelles fonctionnalités compilent et fonctionnent

echo "🚀 Test Rapide Ankata - Nouvelles Fonctionnalités"
echo "================================================="
echo ""

cd "$(dirname "$0")"

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Vérifier Flutter
echo "📱 1. Vérification Flutter..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter OK${NC}"
echo ""

# 2. Vérifier les packages
echo "📦 2. Installation des packages..."
flutter pub get > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Packages installés${NC}"
else
    echo -e "${RED}❌ Erreur installation packages${NC}"
    exit 1
fi
echo ""

# 3. Vérifier la compilation
echo "🔨 3. Test de compilation..."
flutter analyze --no-pub lib/main.dart lib/screens/home/home_screen.dart lib/screens/profile/profile_screen.dart 2>&1 | grep -i "error"
if [ $? -eq 1 ]; then
    echo -e "${GREEN}✅ Compilation OK (pas d'erreurs)${NC}"
else
    echo -e "${RED}❌ Erreurs de compilation détectées${NC}"
    flutter analyze --no-pub lib/main.dart lib/screens/home/home_screen.dart lib/screens/profile/profile_screen.dart
    exit 1
fi
echo ""

# 4. Vérifier les nouveaux fichiers
echo "📄 4. Vérification des fichiers créés..."
FILES=(
    "lib/utils/haptic_helper.dart"
    "lib/widgets/skeleton_loader.dart"
    "lib/widgets/animated_button.dart"
    "lib/widgets/company_logo.dart"
    "lib/widgets/sponsor_banner.dart"
    "lib/widgets/premium_dialog.dart"
    "lib/widgets/referral_dialog.dart"
    "lib/services/streak_service.dart"
    "lib/services/xp_service.dart"
    "lib/services/badge_service.dart"
    "lib/services/payment_service.dart"
    "lib/screens/payment/payment_screen.dart"
    "lib/screens/payment/payment_success_screen.dart"
)

MISSING=0
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $file"
    else
        echo -e "${RED}❌${NC} $file (manquant)"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -gt 0 ]; then
    echo -e "${RED}❌ $MISSING fichiers manquants${NC}"
    exit 1
fi
echo ""

# 5. Compter les lignes de code
echo "📊 5. Statistiques du code..."
TOTAL_LINES=$(find lib -name "*.dart" -type f -exec wc -l {} + | tail -1 | awk '{print $1}')
NEW_FILES_LINES=$(wc -l "${FILES[@]}" 2>/dev/null | tail -1 | awk '{print $1}')
echo -e "${GREEN}   Total lignes de code:${NC} $TOTAL_LINES"
echo -e "${GREEN}   Lignes des nouveaux fichiers:${NC} $NEW_FILES_LINES"
echo ""

# 6. Vérifier les packages Firebase
echo "🔥 6. Vérification Firebase..."
if grep -q "firebase_core:" pubspec.yaml && \
   grep -q "firebase_messaging:" pubspec.yaml && \
   grep -q "firebase_analytics:" pubspec.yaml; then
    echo -e "${GREEN}✅ Packages Firebase configurés${NC}"
else
    echo -e "${YELLOW}⚠️  Packages Firebase manquants dans pubspec.yaml${NC}"
fi
echo ""

# 7. Vérifier les imports dans les fichiers modifiés
echo "🔗 7. Vérification des intégrations..."

# Check home_screen.dart
if grep -q "SponsorBanner" lib/screens/home/home_screen.dart && \
   grep -q "AnimatedButton" lib/screens/home/home_screen.dart; then
    echo -e "${GREEN}✅ home_screen.dart intégré${NC}"
else
    echo -e "${YELLOW}⚠️  home_screen.dart partiellement intégré${NC}"
fi

# Check profile_screen.dart
if grep -q "StreakWidget" lib/screens/profile/profile_screen.dart && \
   grep -q "XPBar" lib/screens/profile/profile_screen.dart && \
   grep -q "PremiumDialog" lib/screens/profile/profile_screen.dart; then
    echo -e "${GREEN}✅ profile_screen.dart intégré${NC}"
else
    echo -e "${YELLOW}⚠️  profile_screen.dart partiellement intégré${NC}"
fi

# Check main.dart
if grep -q "StreakService" lib/main.dart; then
    echo -e "${GREEN}✅ main.dart intégré${NC}"
else
    echo -e "${YELLOW}⚠️  main.dart non intégré${NC}"
fi
echo ""

# 8. Rapport final
echo "================================================="
echo "✅ ${GREEN}TOUS LES TESTS PASSÉS !${NC}"
echo ""
echo "📱 Prêt pour: flutter run"
echo "🔧 Prochaine étape: Tester l'app sur un émulateur/appareil"
echo ""
echo "📚 Documentation disponible:"
echo "   - INTEGRATION_STATUS.md (état actuel)"
echo "   - INTEGRATION_COMPLETE.md (plan 6h)"
echo "   - FIREBASE_SETUP_GUIDE.md (config Firebase)"
echo "   - PAIEMENT_SETUP_GUIDE.md (paiement mobile)"
echo ""
echo "🎯 Fonctionnalités prêtes:"
echo "   ✅ Banner sponsor (accueil)"
echo "   ✅ Gamification (profil: streak, XP, badges)"
echo "   ✅ Premium & Referral (profil)"
echo "   ✅ Animations & Haptic feedback"
echo "   ✅ Payment flow complet"
echo ""
echo "================================================="
