import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;
import '../data/web_cookies.dart' as cookies;
import 'package:unilink2023/data/sqlite.dart';
import 'dart:io' as io;

class ThemeNotifier with ChangeNotifier {
  ThemeData? _currentTheme;

  ThemeNotifier(String themeSetting) {
    _currentTheme = themeSetting == 'Dark'
      ? ThemeData.dark()
      : ThemeData.light();
  }

  ThemeData? get currentTheme => _currentTheme;

  Future<void> toggleTheme() async {
    if (await cache.getValue('settings', 'theme') == 'Dark') {
      _currentTheme = ThemeData.light();

      if (kIsWeb)
        cookies.setCookie('theme', 'Light');
      else if (io.Platform.isAndroid)
        SqliteService().updateTheme('Light');
      //... other actions for light theme
    } else {
      _currentTheme = ThemeData.dark();
      if (kIsWeb)
        cookies.setCookie('theme', 'Dark');
      else if (io.Platform.isAndroid)
        SqliteService().updateTheme('Dark');
      //... other actions for dark theme
    }
    notifyListeners();
  }
}
