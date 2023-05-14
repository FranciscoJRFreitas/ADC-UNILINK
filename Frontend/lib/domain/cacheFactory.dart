import '../data/web_cookies.dart' as cookies;
import 'package:unilink2023/data/sqlite.dart';
import 'dart:io' as io;
import 'package:flutter/src/foundation/constants.dart';

Future<String?> getValue(String table, String key) async {
  if (kIsWeb)
    return cookies.getCookie(key);
  else if (io.Platform.isAndroid)
    return await SqliteService().getValue(table, key);

  return null;
}

void removeLoginCache() {
  if (kIsWeb) {
    cookies.deleteCookie('username');
    cookies.deleteCookie('token');
    cookies.deleteCookie('password');
    cookies.deleteCookie('login');

    cookies.deleteCookie('displayName');
    cookies.deleteCookie('email');
  } else if (io.Platform.isAndroid) {
    SqliteService().deleteUsersCache();
    SqliteService().updateCheckLogin(0);
  }
}
