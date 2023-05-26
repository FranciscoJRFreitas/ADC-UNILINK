import '../domain/User.dart';
import 'stub_cache_factory.dart'
    if (dart.library.html) 'web_implementation.dart'
    if (dart.library.io) 'android_implementation.dart';

    class CacheGeneral {
        final CacheFactoryImpl impl;

        CacheGeneral() : impl = CacheFactoryImpl();

        void set(String property, dynamic value) {
            impl.set(property, value);
        }

        void setUser(User user, String token, String password) {
            impl.setUser(user, token, password);
        }

        Future<dynamic>? get(String table, String value) async {
            return impl.get(table, value);
        }
        void delete(String value) {
            impl.delete(value);

        }
        void removeLoginCache() {
            impl.removeLoginCache();
        }

        void printDb() {
            impl.printDb();
        }

        void initDB() {
            impl.initDB();
        }
    }

final CacheGeneral cacheFactory = CacheGeneral();
