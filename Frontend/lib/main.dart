import 'package:provider/provider.dart';
import 'package:unilink2023/screens/intro_page.dart';
import 'package:unilink2023/screens/settings_page.dart';
import 'package:unilink2023/screens/splashPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilink2023/util/ThemeNotifier.dart';
import 'firebase_options.dart';
import 'constants.dart';
import './screens/screen.dart';

// //void main() async {
//     runApp(
//       MultiProvider(providers: [
//         ChangeNotifierProvider(
//           create: (_) => ThemeNotifier(kDarkTheme),
//         ),
//         ChangeNotifierProvider(create: (context) => IntroProvider()),
//       ], child: MyApp()),
//     );
//
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }
void main() async {
  runApp(
       MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniLink',
        theme: ThemeData(
          //textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          scaffoldBackgroundColor: kBackgroundColor,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashPage(),
      ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
