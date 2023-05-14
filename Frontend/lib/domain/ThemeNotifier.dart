import 'package:flutter/material.dart';
import '../constants.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme;

  ThemeNotifier(this._currentTheme);

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_currentTheme == kDarkTheme) {
      _currentTheme = kLightTheme;
    } else {
      _currentTheme = kDarkTheme;
    }
    notifyListeners();
  }
}
