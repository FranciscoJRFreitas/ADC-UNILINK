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
    if (table == 'users' && value == 'user') return getUser();
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

  Future<User> getUser() async {
    String displayName = await get("", 'displayName') ?? '';
    String username = await get("", 'username') ?? '';
    String email = await get("", 'email') ?? '';
    String? role = await get("", 'role') ?? '';
    String? educationLevel = await get("", 'educationLevel') ?? '';
    String? birthDate = await get("", 'birthDate')?? '';
    String? profileVisibility = await get("", 'profileVisibility')?? '';
    String? state = await get("", 'state')?? '';
    String? mobilePhone = await get("", 'mobilePhone')?? '';
    String? occupation = await get("", 'occupation')?? '';
    String? creationTime = await get("", 'creationTime')?? '';

    return User(
      displayName: displayName,
      username: username,
      email: email,
      role: role,
      educationLevel: educationLevel,
      birthDate: birthDate,
      profileVisibility: profileVisibility,
      state: state,
      mobilePhone: mobilePhone,
      occupation: occupation,
      creationTime: creationTime,
    );
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
  void initDB() async {}

  @override
  void setUser(User user, String token, String password) {
    set('displayName', user.displayName);
    set('email', user.email);
    set('educationLevel', user.educationLevel);
    set('birthDate', user.birthDate);
    set('profileVisibility', user.profileVisibility);
    set('state', user.state);
    set('mobilePhone', user.mobilePhone);
    set('occupation', user.occupation);
    set('username', user.username);
    set('role', user.role);
    set('password', password);
    set('token', token);
    set('creationTime', user.creationTime);
  }

  @override
  void removeNewsCache() {
    // TODO: implement removeNewsCache
  }
}
