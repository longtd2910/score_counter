# Score Counter

A cross-platform [Flutter](https://flutter.dev) app for tracking pool and billiards scores during live games. Built for quick tap-and-drag scoring, configurable game modes (9-ball, 10-ball, and custom rules), and offline persistence so you can pick up where you left off.

The app is published on Android as **Pool Counter** (`com.pleiadex.pool_counter`).

## Features

- **Game modes** — Preset modes (e.g. 9-ball 3/6/9, 9-ball 5/9, 10-ball 5/10) plus custom modes with per-ball point values. Favourite modes for faster selection.
- **Live scoring** — Color-coded player cards with +/- controls; ball-based scoring via a draggable action bar tied to the active game mode.
- **Balance indicator** — App bar shows when scores are unbalanced, who is ahead when balanced, or a tie.
- **Players** — Add, rename, recolor, and remove players; compact layout when five or more are in the game.
- **Session tools** — Undo last action, save snapshots, reset scores, or start a new game. Current session auto-saves and restores on launch.
- **History** — Timestamped log of score changes, player updates, and related actions.
- **Saved games** — Browse and open previously saved game states.
- **Settings** — Game mode management, saved games, history, keep-screen-awake, and language (English / Vietnamese).
- **Theming** — Material 3 UI with light/dark mode following the system, Quicksand typography.

## Tech stack

| Area | Choice |
|------|--------|
| Framework | Flutter (SDK ^3.8) |
| State | [provider](https://pub.dev/packages/provider) |
| Storage | [shared_preferences](https://pub.dev/packages/shared_preferences) (JSON-serialized models) |
| i18n | `flutter_localizations` + ARB files (`en`, `vi`) |
| Other | `wakelock_plus`, `live_activities` (iOS groundwork), `uuid` |

## Project structure

```
lib/
├── main.dart              # App entry, routing, theme, localization
├── models/                # GameMode, Player, HistoryEntry, SavedGame
├── providers/             # GameProvider, LanguageProvider
├── screens/               # Score, game mode, settings, history, saved games
├── services/              # StorageService (SharedPreferences)
├── widgets/               # Player cards, balls, action bar, dialogs
└── l10n/                  # ARB sources and generated localizations
```

Platform folders (`android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`) follow the standard Flutter multi-platform layout.

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with Dart ^3.8
- For Android release builds: a `key.properties` file and keystore (see `android/app/build.gradle.kts`)

### Run locally

```bash
flutter pub get
flutter run
```

Localization is generated automatically when you build or run (`flutter: generate: true` in `pubspec.yaml`).

### Useful commands

```bash
flutter analyze
flutter test
flutter build apk
flutter build ios
```

## Configuration

- **Default game modes** — Defined in `lib/models/game_mode.dart` (`getDefaultGameModes()`).
- **Launcher icon** — `flutter_launcher_icons.yaml` and `dart run flutter_launcher_icons`.
- **Android app label** — `android/app/src/main/res/values/strings.xml` (`Pool Counter`).

## License

No license file is included in this repository. Add one if you plan to distribute or open-source the project.
