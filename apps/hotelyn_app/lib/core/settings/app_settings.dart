import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings({
    SharedPreferences? storage,
    Locale initialLocale = const Locale('tr'),
    ThemeMode initialThemeMode = ThemeMode.light,
  }) : _storage = storage,
       _locale = _readLocale(
         storage?.getString(_localeKey),
         initialLocale,
       ),
       _themeMode = _readThemeMode(
         storage?.getString(_themeKey),
         initialThemeMode,
       );

  static const _localeKey = 'site_locale';
  static const _themeKey = 'site_theme_mode';

  final SharedPreferences? _storage;
  Locale _locale;
  ThemeMode _themeMode;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> setLocale(Locale locale) async {
    if (!const {'tr', 'en', 'ar'}.contains(locale.languageCode)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported site language.');
    }
    _locale = locale;
    notifyListeners();
    final saved = await _storage?.setString(_localeKey, locale.languageCode);
    if (saved == false) {
      throw StateError('Could not save the selected language.');
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    final saved = await _storage?.setString(_themeKey, themeMode.name);
    if (saved == false) {
      throw StateError('Could not save the selected theme.');
    }
  }

  static ThemeMode _readThemeMode(String? value, ThemeMode fallback) {
    for (final mode in ThemeMode.values) {
      if (mode.name == value) return mode;
    }
    return fallback;
  }

  static Locale _readLocale(String? value, Locale fallback) {
    if (value != null && const {'tr', 'en', 'ar'}.contains(value)) {
      return Locale(value);
    }
    return fallback;
  }
}
