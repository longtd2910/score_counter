import 'package:flutter/material.dart';
import 'app_localizations.dart';

class L10n {
  static final supportedLocales = [
    const Locale('en'), // English
    const Locale('vi'), // Vietnamese
  ];

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return languageCode;
    }
  }
} 