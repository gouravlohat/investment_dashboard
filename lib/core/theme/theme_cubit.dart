import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<AppThemeState> {
  static const _prefsKey = 'theme_mode';

  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(AppThemeState(_readInitialMode(_prefs)));

  static ThemeMode _readInitialMode(SharedPreferences prefs) {
    final saved = prefs.getString(_prefsKey);
    return switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  void toggleTheme() {
    final next = state.isDark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_prefsKey, next == ThemeMode.dark ? 'dark' : 'light');
    emit(AppThemeState(next));
  }
}
