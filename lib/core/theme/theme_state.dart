import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppThemeState extends Equatable {
  final ThemeMode mode;

  const AppThemeState(this.mode);

  bool get isDark => mode == ThemeMode.dark;

  @override
  List<Object?> get props => [mode];
}
