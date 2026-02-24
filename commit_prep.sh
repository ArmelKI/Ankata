#!/bin/bash
# commit_prep.sh - Script pour commiter proprement le travail précédent

echo "Committing Backend..."
git add backend/
git commit -m "feat(backend): Setup complete Ankata backend structure with unified tables and endpoints"

echo "Committing Base Mobile App..."
git add mobile/pubspec.yaml mobile/lib/config/ mobile/lib/utils/ mobile/lib/services/ mobile/lib/widgets/
git commit -m "feat(mobile): Setup core services, config, utils and shared widgets"

echo "Committing Auth & Profile & Core Screens..."
git add mobile/lib/screens/auth/ mobile/lib/screens/profile/ mobile/lib/screens/home/ mobile/lib/screens/sotraco/
git commit -m "feat(mobile): Integrate Auth, Profile, Home and Sotraco map with geolocation"

echo "Committing Booking & Payments..."
git add mobile/lib/screens/booking/ mobile/lib/screens/trips/ mobile/lib/screens/payment/ mobile/lib/screens/tickets/
git commit -m "feat(mobile): Refactor booking flow, integrate monetisation and unified payment screen"

echo "Committing remaining Mobile & Assets..."
git add mobile/
git commit -m "feat(mobile): Finalize GoRouter migration, Secure Storage and Splash screen with new logo"

echo "Committing Flutter Engine & Docs..."
git add flutter/ package-lock.json *.md *.txt *.sh *.xlsx
git commit -m "docs: Add extensive project documentation, deliverables and audits"

# Just in case there are missing files
git add .
git commit -m "chore: Minor updates and missed files"

echo "Git commit process completed successfully."
