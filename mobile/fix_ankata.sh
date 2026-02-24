#!/bin/bash
# Script de nettoyage et correction automatisée pour Ankata Flutter App
# Usage: chmod +x fix_ankata.sh && ./fix_ankata.sh

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🔧 ANKATA FLUTTER - SCRIPT CORRECTION AUTOMATISÉE        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonctions
log_start() {
  echo -e "${BLUE}▶▶▶ $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅  $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌  $1${NC}"
}

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
  log_error "pubspec.yaml non trouvé. Exécutez ce script depuis le répertoire 'mobile'"
  exit 1
fi

log_start "ÉTAPE 1 : Nettoyer les fichiers de build"
rm -rf build/ .dart_tool/ pubspec.lock
log_success "Fichiers de build supprimés"
echo ""

log_start "ÉTAPE 2 : Réinstaller les dépendances"
flutter pub get
log_success "Dépendances réinstallées"
echo ""

log_start "ÉTAPE 3 : Appliquer les fixes Dart automatiquement"
dart fix --apply
log_success "Fixes automatiques appliquées"
echo ""

log_start "ÉTAPE 4 : Formater le code"
dart format lib/ --fix
log_success "Code formaté"
echo ""

log_start "ÉTAPE 5 : Analyser le projet"
echo ""
flutter analyze --no-pub
echo ""
echo ""

log_start "ÉTAPE 6 : Résumé des problèmes"
echo ""
echo "Les problèmes restants doivent être corrigés manuellement :"
echo "  1. RenderFlex overflow - lib/screens/companies/companies_screen.dart:367"
echo "  2. Type Null errors - Ajouter null checks sur phone/whatsapp/rating"
echo "  3. Deprecated APIs - Utiliser .withValues() au lieu de .withOpacity()"
echo "  4. Const constructors - Ajouter 'const' aux constructeurs"
echo ""
log_warning "Consultez CORRECTIONS_GUIDE.md pour les détails"
echo ""

log_start "ÉTAPE 7 : Prêt pour test"
echo ""
echo "Commandes suivantes recommandées :"
echo ""
echo "  # Test complet avec logs"
echo "  flutter run -v"
echo ""
echo "  # Build APK release"
echo "  flutter build apk --release"
echo ""
echo "  # Analyser les performances"
echo "  flutter run --profile"
echo ""

log_success "Script de correction terminé !"
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✨ Application prête à être testée sur Pixel 9a           ║"
echo "╚════════════════════════════════════════════════════════════╝"
