import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localePrefKey = 'app_selected_locale_code';

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadSavedLocale();
    return null;
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localePrefKey);
      if (code != null && code.isNotEmpty) {
        state = Locale(code);
      }
    } catch (_) {
      // Fallback to system default
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_localePrefKey);
      } else {
        await prefs.setString(_localePrefKey, locale.languageCode);
      }
    } catch (_) {}
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class AppSupportedLocale {
  final Locale? locale;
  final String label;
  final String nativeLabel;
  final String flagEmoji;

  const AppSupportedLocale({
    required this.locale,
    required this.label,
    required this.nativeLabel,
    required this.flagEmoji,
  });
}

const List<AppSupportedLocale> kSupportedLanguages = [
  AppSupportedLocale(
    locale: null,
    label: 'Predeterminado del sistema',
    nativeLabel: 'System default',
    flagEmoji: '🌐',
  ),
  AppSupportedLocale(
    locale: Locale('es'),
    label: 'Español (Latinoamérica)',
    nativeLabel: 'Español',
    flagEmoji: '🇲🇽',
  ),
  AppSupportedLocale(
    locale: Locale('en'),
    label: 'English',
    nativeLabel: 'English',
    flagEmoji: '🇺🇸',
  ),
  AppSupportedLocale(
    locale: Locale('pt'),
    label: 'Português',
    nativeLabel: 'Português',
    flagEmoji: '🇧🇷',
  ),
];
