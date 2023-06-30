import 'dart:convert';
import 'dart:html';
import 'package:unilink2023/domain/User.dart';

import '../domain/FeedItem.dart';
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
    if (table == 'news') return await getNews();
    if (table == 'users' && value == 'user') return await getUser();
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
    String? birthDate = await get("", 'birthDate') ?? '';
    String? profileVisibility = await get("", 'profileVisibility') ?? '';
    String? state = await get("", 'state') ?? '';
    String? mobilePhone = await get("", 'mobilePhone') ?? '';
    String? occupation = await get("", 'occupation') ?? '';
    String? creationTime = await get("", 'creationTime') ?? '';

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
    if (get('users', 'username') != null) delete('username');
    if (get('users', 'token') != null) delete('token');
    if (get('users', 'password') != null) delete('password');
    if (get('users', 'checkLogin') != null) delete('checkLogin');
    if (get('users', 'displayName') != null) delete('displayName');
    if (get('users', 'email') != null) delete('email');
    if (get('users', 'creationTime') != null) delete('creationTime');
    if (get('users', 'role') != null) delete('role');
    if (get('users', 'occupation') != null) delete('occupation');
    if (get('users', 'mobilePhone') != null) delete('mobilePhone');
    if (get('users', 'profileVisibility') != null) delete('profileVisibility');
    if (get('users', 'educationLevel') != null) delete('educationLevel');
    if (get('users', 'birthDate') != null) delete('birthDate');
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

  Future<List<dynamic>> _getNewsList() async {
    String? jsonString = window.localStorage['news'];
    if (jsonString != null) {
      return jsonDecode(jsonString);
    } else {
      return [];
    }
  }

  void _setNewsList(List<dynamic> newsList) {
    window.localStorage['news'] = jsonEncode(newsList);
  }

  @override
  void setNews(FeedItem newsItem) {
    _getNewsList().then((newsList) {
      bool isPresent = newsList.any((element) => element['title'] == newsItem.title);
      if (!isPresent) {
        newsList.add(newsItem.toMap());
        _setNewsList(newsList);
      }
    });
  }

  Future<List<FeedItem>> getNews() async {
    List<dynamic>? jsonNewsList = await _getNewsList();
    return jsonNewsList.map((jsonNews) => FeedItem.fromMap(jsonNews)).toList();
  }

  @override
  void removeNewsCache() {
    window.localStorage.remove('news');
    if (get('settings', 'currentPage') != null) delete('currentPage');
    if (get('settings', 'currentNews') != null) delete('currentNews');
  }
}
