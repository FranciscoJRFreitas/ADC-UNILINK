import '../domain/User.dart';

abstract class CacheFactory {
  void set(String property, dynamic value);
  Future<dynamic>? get(String table, String value);
  void delete(String value);
  void removeLoginCache();
  void initDB();
  void setUser(User user, String token, String password);
  void removeNewsCache();
  void printDb();
}
