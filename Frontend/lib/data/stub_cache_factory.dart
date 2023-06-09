import 'package:unilink2023/domain/User.dart';

import 'cache_factory.dart';

class CacheFactoryImpl extends CacheFactory{
  @override
  void delete(String value) {
  }

  @override
  Future? get(String table, String value) {
    throw UnimplementedError();
  }

  @override
  void printDb() {
  }

  @override
  void removeLoginCache() {
  }

  @override
  void set(String property, value) {
  }

  @override
  void initDB() async {
  }

  @override
  void setUser(User user, String token, String password) {
  }

}