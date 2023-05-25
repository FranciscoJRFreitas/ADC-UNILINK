import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/presentation/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'data/android_implementation.dart';
import 'data/cache_factory_provider.dart';
import 'firebase_options.dart';
import 'constants.dart';
//import 'package:unilink2023/domain/cacheFactory.dart' as cache;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  cacheFactory.initDB();
  cacheFactory.printDb();
  cacheFactory.set('theme', 'Dark');
  cacheFactory.printDb();
  dynamic themeSetting = await cacheFactory.get('settings', 'theme');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(themeSetting),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniLink',
        theme: ThemeData(
          //textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          scaffoldBackgroundColor: kBackgroundColor,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniLink',
      theme: themeNotifier.currentTheme,
      home: SplashPage(),
    );
  }
}
