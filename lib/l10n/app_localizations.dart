import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Score Counter'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @selectOrCreateGameMode.
  ///
  /// In en, this message translates to:
  /// **'Select or create a game mode'**
  String get selectOrCreateGameMode;

  /// No description provided for @viewSavedGames.
  ///
  /// In en, this message translates to:
  /// **'View Saved Games'**
  String get viewSavedGames;

  /// No description provided for @seePreviouslySavedGames.
  ///
  /// In en, this message translates to:
  /// **'See previously saved games'**
  String get seePreviouslySavedGames;

  /// No description provided for @viewGameHistory.
  ///
  /// In en, this message translates to:
  /// **'View Game History'**
  String get viewGameHistory;

  /// No description provided for @seeActionsHistoryLog.
  ///
  /// In en, this message translates to:
  /// **'See actions history log'**
  String get seeActionsHistoryLog;

  /// No description provided for @keepScreenAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen Awake'**
  String get keepScreenAwake;

  /// No description provided for @preventScreenFromTurningOff.
  ///
  /// In en, this message translates to:
  /// **'Prevent screen from turning off'**
  String get preventScreenFromTurningOff;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @savedGames.
  ///
  /// In en, this message translates to:
  /// **'Saved Games'**
  String get savedGames;

  /// No description provided for @gameDetails.
  ///
  /// In en, this message translates to:
  /// **'Game Details'**
  String get gameDetails;

  /// No description provided for @chooseGameMode.
  ///
  /// In en, this message translates to:
  /// **'Choose Game Mode'**
  String get chooseGameMode;

  /// No description provided for @createNewGameMode.
  ///
  /// In en, this message translates to:
  /// **'Create New Game Mode'**
  String get createNewGameMode;

  /// No description provided for @scoreCounter.
  ///
  /// In en, this message translates to:
  /// **'Score Counter'**
  String get scoreCounter;

  /// No description provided for @noSavedGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No saved games yet'**
  String get noSavedGamesYet;

  /// No description provided for @deleteSavedGames.
  ///
  /// In en, this message translates to:
  /// **'Delete Saved Games'**
  String get deleteSavedGames;

  /// No description provided for @deleteConfirmSingle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this saved game? This action cannot be undone.'**
  String get deleteConfirmSingle;

  /// No description provided for @deleteConfirmMultiple.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete these {count} saved games? This action cannot be undone.'**
  String deleteConfirmMultiple(int count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
