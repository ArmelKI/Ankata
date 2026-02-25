#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

commit_group() {
	local group_name="$1"
	local default_msg="$2"
	shift 2
	local paths=("$@")

	echo ""
	echo "=== ${group_name} ==="

	git add -A -- "${paths[@]}"

	if git diff --cached --quiet; then
		echo "No changes staged for this group."
		return
	fi

	git diff --cached --stat

	git commit -m "${default_msg}"
}

# 1) Backend core
commit_group "backend core" \
	"feat(backend): update core API, models, and auth" \
	backend/package.json \
	backend/package-lock.json \
	backend/src/index.js \
	backend/src/config/supabase.js \
	backend/src/controllers/auth.controller.js \
	backend/src/controllers/bookings.controller.js \
	backend/src/controllers/lines.controller.js \
	backend/src/controllers/users.controller.js \
	backend/src/middleware/auth.middleware.js \
	backend/src/models/Booking.js \
	backend/src/models/Schedule.js \
	backend/src/models/User.js \
	backend/src/routes/upload.routes.js \
	backend/src/routes/users.routes.js \
	backend/src/database/migrations/004_user_profile_fields.sql

# 2) Backend scripts, tests, and docs
commit_group "backend scripts and docs" \
	"chore(backend): add tooling scripts and docs" \
	backend/check_db.js \
	backend/fix-db.js \
	backend/fix_seed.js \
	backend/fix_seed_data.js \
	backend/fix_seed_schedules_uuid.js \
	backend/fix_seed_uuid.js \
	backend/get_user.js \
	backend/run-migration.js \
	backend/test-db.js \
	backend/test_booking.sh \
	backend/test_cancel.js \
	backend/test_ratings.js \
	backend/update_logos.js \
	backend/CORS_SECURITY_GUIDE.md \
	backend/SUPABASE_RLS_SETUP.sql \
	backend/logs.txt \
	backend/public/ \
	backend/scripts/

# 3) Mobile assets (logos, animations)
commit_group "mobile assets" \
	"chore(mobile): update assets and logos" \
	mobile/assets/animations/loading_bus.json \
	mobile/assets/images/README_LOGOS.md \
	mobile/assets/images/ctke_logo.png \
	mobile/assets/images/elitis_logo.png \
	mobile/assets/images/rahimo_logo.png \
	mobile/assets/images/rakieta_logo.png \
	mobile/assets/images/saramaya_logo.png \
	mobile/assets/images/staf_logo.png \
	mobile/assets/images/tcv_logo.png \
	mobile/assets/images/tsr_logo.png \
	mobile/assets/images/companies/

# 4) Mobile config and app wiring
commit_group "mobile config" \
	"feat(mobile): update app config, theme, and l10n" \
	mobile/lib/config/app_constants.dart \
	mobile/lib/config/app_theme.dart \
	mobile/lib/config/constants.dart \
	mobile/lib/config/l10n_helper.dart \
	mobile/lib/l10n/app_en.arb \
	mobile/lib/providers/logo_providers.dart \
	mobile/lib/main.dart

# 5) Mobile screens
commit_group "mobile screens" \
	"feat(mobile): refresh screens and flows" \
	mobile/lib/screens/booking/confirmation_screen.dart \
	mobile/lib/screens/booking/passenger_info_screen.dart \
	mobile/lib/screens/booking/payment_screen.dart \
	mobile/lib/screens/companies/companies_screen.dart \
	mobile/lib/screens/companies/company_details_screen.dart \
	mobile/lib/screens/home/home_screen.dart \
	mobile/lib/screens/profile/profile_screen.dart \
	mobile/lib/screens/ratings/rating_screen.dart \
	mobile/lib/screens/sotraco/sotraco_home_screen.dart \
	mobile/lib/screens/sotraco/sotraco_line_details_screen.dart \
	mobile/lib/screens/support/faq_screen.dart \
	mobile/lib/screens/support/feedback_screen.dart \
	mobile/lib/screens/support/legal_screen.dart \
	mobile/lib/screens/tickets/my_tickets_screen.dart \
	mobile/lib/screens/tickets/ticket_details_screen.dart \
	mobile/lib/screens/trips/trip_search_results_screen.dart \
	mobile/lib/screens/trips/trip_search_screen.dart

# 6) Mobile services and widgets
commit_group "mobile services/widgets" \
	"feat(mobile): extend services and UI widgets" \
	mobile/lib/services/api_service.dart \
	mobile/lib/services/badge_service.dart \
	mobile/lib/services/company_logo_service.dart \
	mobile/lib/services/streak_service.dart \
	mobile/lib/services/xp_service.dart \
	mobile/lib/widgets/animated_button.dart \
	mobile/lib/widgets/company_logo.dart \
	mobile/lib/widgets/edit_profile_dialog.dart \
	mobile/lib/widgets/progress_stepper.dart \
	mobile/lib/widgets/referral_dialog.dart \
	mobile/lib/widgets/scroll_to_top_button.dart \
	mobile/lib/widgets/seat_selection_widget.dart \
	mobile/lib/widgets/skeleton_loader.dart \
	mobile/lib/widgets/sponsor_banner.dart \
	mobile/lib/widgets/stops_list_widget.dart \
	mobile/lib/widgets/undo_snackbar.dart

# 7) Mobile deps and generated files
commit_group "mobile deps" \
	"chore(mobile): update dependencies and generated files" \
	mobile/pubspec.yaml \
	mobile/pubspec.lock \
	mobile/macos/Flutter/GeneratedPluginRegistrant.swift \
	mobile/test/api_service_test.dart

# 8) Mobile tooling and logs
commit_group "mobile tooling and logs" \
	"chore(mobile): add local tools and logs" \
	mobile/errors.txt \
	mobile/errors2.txt \
	mobile/errors3.txt \
	mobile/errors4.txt \
	mobile/fix_consts.py \
	mobile/refactor_colors.py \
	mobile/rapport_session.sh

# 9) Docs and reports (root)
commit_group "docs and reports" \
	"docs: add deployment and completion reports" \
	LIRE_MOI_EN_PREMIER.txt \
	DEPLOYMENT_GUIDE.md \
	P1_COMPLETION_REPORT.md \
	P1_TEST_CHECKLIST.md \
	SPRINT_3_COMPLETION_REPORT.md \
	commit_recent_changes.sh \
	commit_grouped.sh

# 10) Data and specs
commit_group "data and specs" \
	"docs(data): add transport data and specs" \
	$'Donn\303\251es_transport/' \
	$'Spec_projet /'

# 11) Flutter submodule update
commit_group "flutter submodule" \
	"chore(flutter): update submodule" \
	flutter

echo ""
echo "All groups processed."
