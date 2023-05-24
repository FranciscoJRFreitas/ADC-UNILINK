import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = cacheFactory.get('settings', 'theme') == 'Light'
      ? kLightTheme
      : kDarkTheme;

  ThemeNotifier(String themeSetting) {
    _currentTheme = themeSetting == 'Dark' ? kDarkTheme : kLightTheme;
  }

  ThemeData? get currentTheme => _currentTheme;

  Future<void> toggleTheme() async {
    if (await cacheFactory.get('settings', 'theme') == 'Dark') {
      _currentTheme = kLightTheme;
      cacheFactory.set('theme', 'Light');
    } else {
      _currentTheme = kDarkTheme;
      cacheFactory.set('theme', 'Dark');
    }
    notifyListeners();
  }
}
