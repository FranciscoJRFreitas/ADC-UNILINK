import 'package:provider/provider.dart';
import 'package:unilink2023/presentation/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'application/firebase_messaging_service.dart';
import 'data/cache_factory_provider.dart';
import 'domain/Notification.dart';
import 'domain/UserNotifier.dart';
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
  if (await cacheFactory.get("settings", "theme") == null)
    cacheFactory.set('theme', 'Dark');
  cacheFactory.printDb();
  dynamic themeSetting = await cacheFactory.get('settings', 'theme');

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
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserNotifier(),
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
}

class MyApp extends StatelessWidget {
  
  
  void initState(BuildContext context) {
    
    FirebaseMessagingService messagingService = FirebaseMessagingService(context.read<NotificationService>());
    messagingService.requestPermission();
    checkNotifications(context);
  }

 
  checkNotifications(BuildContext context) async {
    await Provider.of<NotificationService>(context, listen: false).checkForNotifications();
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
