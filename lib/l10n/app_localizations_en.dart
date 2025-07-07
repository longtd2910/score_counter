// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Score Counter';

  @override
  String get settings => 'Settings';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get selectOrCreateGameMode => 'Select or create a game mode';

  @override
  String get viewSavedGames => 'View Saved Games';

  @override
  String get seePreviouslySavedGames => 'See previously saved games';

  @override
  String get viewGameHistory => 'View Game History';

  @override
  String get seeActionsHistoryLog => 'See actions history log';

  @override
  String get keepScreenAwake => 'Keep Screen Awake';

  @override
  String get preventScreenFromTurningOff => 'Prevent screen from turning off';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get cancel => 'Cancel';

  @override
  String get history => 'History';

  @override
  String get savedGames => 'Saved Games';

  @override
  String get gameDetails => 'Game Details';

  @override
  String get chooseGameMode => 'Choose Game Mode';

  @override
  String get createNewGameMode => 'Create New Game Mode';

  @override
  String get scoreCounter => 'Score Counter';

  @override
  String get noSavedGamesYet => 'No saved games yet';

  @override
  String get deleteSavedGames => 'Delete Saved Games';

  @override
  String get deleteConfirmSingle =>
      'Are you sure you want to delete this saved game? This action cannot be undone.';

  @override
  String deleteConfirmMultiple(int count) {
    return 'Are you sure you want to delete these $count saved games? This action cannot be undone.';
  }

  @override
  String get delete => 'Delete';
}
