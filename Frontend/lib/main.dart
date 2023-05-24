import 'package:provider/provider.dart';
import 'package:unilink2023/presentation/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'data/android_implementation.dart';
import 'data/cache_factory_provider.dart';
import 'firebase_options.dart';
import 'constants.dart';
//import '../data/web_cookies.dart' as cookies;
//import 'package:unilink2023/domain/cacheFactory.dart' as cache;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (cacheFactory is AndroidImplementation)
    (cacheFactory as AndroidImplementation).initDB();

  cacheFactory.set('theme', 'Dark');

  //await SqliteService().initializeDB();

  //await SqliteService().printAllTables();
/*
  if(kIsWeb) {
    if (cookies.getCookie('theme') == null) {
      cookies.setCookie('theme', 'Dark');
    }
  } else {
    await SqliteService().updateTheme('Dark');
  }*/

  //await SqliteService().printTableContent('settings');

  String? themeSetting = await cacheFactory.get('settings', 'theme')
      as String?; //await cacheFactory.getValue('settings', 'theme');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(themeSetting!),
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
