#!/bin/bash

# 1. Commit Network & API fixes
git add mobile/lib/config/constants.dart mobile/lib/services/api_service.dart
git commit -m "fix(network): use ngrok proxy and add skip browser warning header to bypass eduroam restrictions"

# 2. Commit Logo Integrations
git add mobile/lib/utils/company_logo_helper.dart \
  mobile/lib/screens/home/home_screen.dart \
  mobile/lib/screens/companies/companies_screen.dart \
  mobile/lib/screens/companies/company_details_screen.dart \
  mobile/lib/screens/trips/trip_search_results_screen.dart \
  mobile/lib/screens/tickets/my_tickets_screen.dart \
  mobile/lib/screens/tickets/ticket_details_screen.dart
git commit -m "feat(ui): implement centralized CompanyLogoHelper and apply to all screens"

echo "Commits completed successfully."
