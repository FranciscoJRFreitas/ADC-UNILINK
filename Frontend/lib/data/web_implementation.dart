import 'dart:html';
import 'package:unilink2023/domain/User.dart';

import 'cache_factory.dart';

class CacheFactoryImpl implements CacheFactory {
  CacheFactoryImpl._();

  static final CacheFactoryImpl _instance = CacheFactoryImpl._();

  factory CacheFactoryImpl() {
    return _instance;
  }

  @override
  void set(String property, dynamic value) {
    document.cookie = '$property=${value.toString()}';
  }

  @override
  Future<dynamic>? get(String table, String value) async {
    final cookies = document.cookie?.split(';');
    for (final cookie in cookies!) {
      final parts = cookie.split('=');
      final cookieName = parts[0].trim();
      if (parts.length >= 2) {
        // Check if there are at least two parts
        final cookieValue = parts[1].trim();
        if (cookieName == value) {
          return cookieValue;
        }
      }
    }
    return null;
  }

  @override
  void delete(String value) {
    dynamic currentValue = get("", value)!;

    // Check if the cookie exists
    if (currentValue != 'not_found') {
      // Set the cookie value to an empty string and set the expires attribute to a date in the past
      document.cookie =
          '$value=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    }
  }

  @override
  void removeLoginCache() {
    delete('username');
    delete('token');
    delete('password');
    delete('checkLogin');
    delete('displayName');
    delete('email');
  }

  @override
  void printDb() {
    final cookies = document.cookie?.split(';');
    for (final cookie in cookies!) {
      print(cookie);
    }
  }

  @override
  void initDB() async {
  }

  @override
  void setUser(User user, String token, String password) {
  }
}