import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;
import '../data/web_cookies.dart' as cookies;
import 'package:unilink2023/data/sqlite.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = cache.getValue('settings', 'theme') == 'Light'
      ? ThemeData.light()
      : ThemeData.dark();

  ThemeData get currentTheme => _currentTheme;

  Future<void> toggleTheme() async {
    if (_currentTheme == ThemeData.dark()) {
      _currentTheme = ThemeData.light();
      cookies.setCookie('theme', 'Light');
      SqliteService().updateTheme('Light');
      //... other actions for light theme
    } else {
      _currentTheme = ThemeData.dark();
      cookies.setCookie('theme', 'Dark');
      SqliteService().updateTheme('Dark');
      //... other actions for dark theme
    }
    notifyListeners();
  }
}
