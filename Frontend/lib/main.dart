import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/features/intro/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'application/firebase_messaging_service.dart';
import 'data/cache_factory_provider.dart';
import 'domain/MapNotifier.dart';
import 'widgets/rightClickDisabler/disabler_provider.dart';
import 'domain/Notification.dart';
import 'domain/UserNotifier.dart';
import 'firebase_options.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  disablerFactory.disable();

  cacheFactory.initDB();
  if (await cacheFactory.get("settings", "theme") == null)
    cacheFactory.set('theme', 'Dark');
  if (await cacheFactory.get("settings", "index") == null)
    cacheFactory.set('index', 'News');
  if (await cacheFactory.get("settings", "currentPage") == null)
    cacheFactory.set('currentPage', "0");
  if (await cacheFactory.get("settings", "currentNews") == null)
    cacheFactory.set('currentNews', "0");

  dynamic themeSetting = await cacheFactory.get('settings', 'theme');

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ThemeNotifier(themeSetting),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'UniLink',
              theme: ThemeData(
                //textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
                scaffoldBackgroundColor: kBackgroundColor,
                //primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => UserNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => MapNotifier(),
            child: MyApp(),
          ),
          Provider<NotificationService>(
            create: (context) => NotificationService(),
          ),
          Provider<FirebaseMessagingService>(
            create: (context) =>
                FirebaseMessagingService(context.read<NotificationService>()),
          ),
        ],
        child: MyApp(),
      ),
    );
  }); //prevent landscape mode
}

class MyApp extends StatelessWidget {
  void initState(BuildContext context) {
    FirebaseMessagingService messagingService =
        FirebaseMessagingService(context.read<NotificationService>());
    messagingService.requestPermission();
    checkNotifications(context);
  }

  checkNotifications(BuildContext context) async {
    await Provider.of<NotificationService>(context, listen: false)
        .checkForNotifications();
  }

  @override
  Widget build(BuildContext context) {
    initState(context);

    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniLink',
      theme: themeNotifier.currentTheme,
      home: SplashPage(),
    );
  }
}
