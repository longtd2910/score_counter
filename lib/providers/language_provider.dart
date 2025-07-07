import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _locale;
  bool _useSystemLocale = true;
  static const String _localeKey = 'app_locale';
  static const String _useSystemLocaleKey = 'use_system_locale';

  LanguageProvider() {
    _loadSettings();
  }

  Locale? get locale => _useSystemLocale ? null : _locale;
  bool get useSystemLocale => _useSystemLocale;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final useSystem = prefs.getBool(_useSystemLocaleKey) ?? true;
    
    if (!useSystem) {
      final languageCode = prefs.getString(_localeKey);
      if (languageCode != null) {
        _locale = Locale(languageCode);
      }
    }
    
    _useSystemLocale = useSystem;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    _useSystemLocale = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    await prefs.setBool(_useSystemLocaleKey, false);
    
    notifyListeners();
  }

  Future<void> setUseSystemLocale() async {
    _useSystemLocale = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemLocaleKey, true);
    
    notifyListeners();
  }
} 