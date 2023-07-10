import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/cache_factory_provider.dart';

class LocaleProvider with ChangeNotifier {
  Locale _currentLocale =
      cacheFactory.get('settings', 'language') == 'portugues'
          ? Locale('pt')
          : Locale('en');

  Locale get currentLocale => _currentLocale;

  set currentLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;
    _currentLocale = locale;
    notifyListeners();
  }

  List<Locale> supportedLocales = [
    Locale('en'),
    Locale('pt'),
  ];
}
