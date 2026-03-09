# Aura — Migraine Tracking App

A migraine-friendly, dark-themed Flutter app for tracking aura migraines, daily check-ins, and recovery.

## Features

### 📅 Calendar Home
- Visual calendar with episode markers (coral dots) and check-in indicators (teal dots)
- Tap any day to see logged data
- Episode count badge for current month
- Quick access to morning/evening check-ins
- Automatic prompt for second-day recovery when an episode was logged yesterday

### ⚡ Episode Logging (3-step wizard)
**Step 1 — Context:**
- Menstrual cycle day
- Perceived stress level (1–6)
- Hydration / glasses of water (1–6)

**Step 2 — Aura & Pain:**
- Visual aura type (6 options: zigzag lines, blind spot, scintillating scotoma, tunnel vision, kaleidoscope, blurring/haze)
- Pain severity (1–6 with color coding)
- Pain location (left, right, both sides, front, back)

**Step 3 — Timing:**
- Aura start time
- Headache start time
- Automatically calculates aura-to-headache gap

### ☀️ Morning Check-in
- Sleep duration (slider, 0–14 hours)
- Sleep quality (1–6 emoji scale, doubles as "freshness")

### 🌙 Evening Check-in
- Perceived stress (1–6)
- Hydration (1–6)
- Caffeine intake (1–3 cups)
- Screen time intensity (1–6)
- Exercise level (none / light / moderate / intense)

### 🩹 Second Day Recovery
- Functionality score (1–6)
- Lingering symptoms checklist (brain fog, neck pain, fatigue, light/sound sensitivity, nausea, dizziness, concentration, mood changes, food cravings)
- Free-text "what helped" notes

### 📊 Statistics
- Monthly and quarterly views with period selector
- Featured episode count
- Average pain, stress, hydration, sleep duration, sleep quality
- Check-in day streak
- Aura type frequency breakdown with bar charts
- Pain location distribution
- Lingering symptom frequency

## Setup

### Prerequisites
- Flutter SDK 3.1+ ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or VS Code with Flutter extensions
- An Android device or emulator

### Steps

```bash
# 1. Clone or copy the project
cd aura_tracker

# 2. Get the Nunito font (or remove font config from pubspec.yaml to use default)
#    Download from: https://fonts.google.com/specimen/Nunito
#    Place .ttf files in assets/fonts/

# 3. Install dependencies
flutter pub get

# 4. Run on a connected device or emulator
flutter run

# 5. Build release APK
flutter build apk --release
```

### Without custom fonts
If you don't want to download Nunito, simply remove the `fonts:` section from `pubspec.yaml`. The app will fall back to the system default font, which still looks good with the dark theme.

## Design

The app uses a migraine-friendly dark palette:
- **Background:** Deep blue-black (#0D1117)
- **Accent:** Soft lavender (#A78BFA)
- **Episodes:** Coral (#F0ABAB)
- **Recovery:** Amber (#FBBF24)
- **Success:** Sage green (#86EFAC)
- **Data:** Teal (#5EEAD4)

All scales are consistently 1–6 for quick, comparable input. The UI is intentionally low-contrast and low-stimulation — designed for someone who might be using it during or after a migraine.

## Data Storage

All data is stored locally on your device using `SharedPreferences`. Nothing is sent to any server. Your data stays with you.

## Project Structure

```
lib/
├── main.dart                  # App entry, theme, navigation shell
├── theme.dart                 # Color palette and ThemeData
├── models/
│   └── data_models.dart       # MorningCheckin, EveningCheckin, Episode + constants
├── services/
│   └── storage_service.dart   # SharedPreferences CRUD + stats computation
├── screens/
│   ├── home_screen.dart       # Calendar view + action cards
│   ├── morning_checkin.dart   # Morning form
│   ├── evening_checkin.dart   # Evening form
│   ├── log_episode.dart       # 3-step episode wizard
│   ├── second_day.dart        # Recovery questionnaire
│   └── stats_screen.dart      # Monthly/quarterly stats
└── widgets/
    └── common_widgets.dart    # ScaleSelector, OptionCard, ChipMultiSelect, etc.
```
