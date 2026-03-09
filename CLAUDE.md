# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Analyze code (linting)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Build release APK
flutter build apk --release

# Install on physical device (PRESERVES app data)
flutter build apk --release && /Users/rafael/Library/Android/sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk

# ⚠️ NEVER use `flutter install` — it uninstalls the app first, WIPING ALL USER DATA
```

## Architecture

This is a Flutter health tracking app for migraine/aura episodes. All data is stored locally via `SharedPreferences` — there is no backend or network layer.

**Data flow:** Screens read/write through `StorageService`, which handles JSON serialization and stats computation. Models are plain Dart classes with `toJson`/`fromJson`.

### Key files

- `lib/main.dart` — App entry point, `MaterialApp` theme setup, bottom navigation shell (`MainShell`), locks to portrait orientation
- `lib/theme.dart` — Centralized dark palette (lavender `#A78BFA`, teal `#5EEAD4`, coral `#F0ABAB` on deep blue-black `#0D1117`)
- `lib/models/data_models.dart` — `MorningCheckin`, `EveningCheckin`, `Episode` data models + constants (`AuraTypes`, `PainLocations`, `LingeringSymptoms`, `ExerciseLevels`)
- `lib/services/storage_service.dart` — All SharedPreferences CRUD, JSON serialization, and stats aggregation (averages, frequencies, streaks)
- `lib/widgets/common_widgets.dart` — Shared UI primitives: `ScaleSelector` (1–6 pill buttons), `OptionCard` (multi-select), `ChipMultiSelect`, `EmojiBadge`

### Screens

- `home_screen.dart` — Calendar view with episode/check-in indicators (coral dots = episodes, teal = check-ins)
- `log_episode.dart` — 3-step episode wizard: context → aura/pain → timing
- `morning_checkin.dart` / `evening_checkin.dart` — Daily lifestyle tracking forms
- `second_day.dart` — Post-episode recovery questionnaire
- `stats_screen.dart` — Monthly/quarterly charts using `fl_chart`

### Design conventions

- All scales use 1–6 (not 1–10) consistently throughout the app
- UI is intentionally low-contrast and minimal-animation (migraine-friendly)
- Screens navigate via `Navigator.push`/`pop`; no named routes
- Theme colors are referenced from `theme.dart` constants, not hardcoded inline
