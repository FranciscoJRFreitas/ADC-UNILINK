import 'package:unilink2023/data/sqlite.dart';

import 'cache_factory.dart';

class CacheFactoryImpl implements CacheFactory {
  CacheFactoryImpl._();

  // Singleton instance
  static final CacheFactoryImpl _instance = CacheFactoryImpl._();

  // Factory method to get the singleton instance
  factory CacheFactoryImpl() {
    return _instance;
  }

  @override
  void initDB() {
    SqliteService().initializeDB();
  }

  @override
  void set(String property, dynamic value) async {
    if (property == 'checkIntro')
      await SqliteService().updateCheckIntro(value);
    else if (property == 'checkLogin')
      await SqliteService().updateCheckLogin(value);
    else if (property == 'index')
      await SqliteService().updateIndex(value);
    else if (property == 'theme')
      await SqliteService().updateTheme(value);
    //else if (property == 'user')
    //await SqliteService().updateUser(user, token, password);
  }

  @override
  Future<dynamic> get(String table, String value) async {
    if (value == 'db')
      return await SqliteService().getDatabase();
    else if (value == 'checkIntro')
      return await SqliteService().getCheckIntro();
    else if (value == 'checkLogin')
      return await SqliteService().getCheckLogin();
    else if (value == 'password')
      return await SqliteService().getPassword();
    else if (value == 'theme')
      return await SqliteService().getTheme();
    else if (value == 'token')
      return await SqliteService().getToken();
    else if (value == 'user')
      return await SqliteService().getUser();
    else
      return await SqliteService().getValue(table, value);
  }

  @override
  void delete(String value) async {
    if (value.isNotEmpty)
      await SqliteService().deleteUser(value);
    else
      await SqliteService().deleteUsersCache();
  }

  @override
  void removeLoginCache() {
    SqliteService().deleteUsersCache();
    SqliteService().updateCheckLogin('false');
  }

  @override
  void printDb() async {
    var db = await SqliteService().getDatabase();
    var result = await db.query('users');
    print("\nusers: \n");
    for (var row in result) {
      print(row);
    }
    print("\nsettings: \n");
    result = await db.query('settings');
    for (var row in result) {
      print(row);
    }
  }
}
