import 'dart:async';

import 'package:provider/provider.dart';
import 'package:unilink2023/constants.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'package:unilink2023/features/intro/intro_page.dart';
import 'package:unilink2023/features/navigation/not_logged_in_page.dart';
import 'package:unilink2023/features/userManagement/presentation/userAuth/login_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/foundation/constants.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    const int msMobile = 2500;
    const int msWeb = 3500;
    const bool testing = true; // set this to true when testing

    super.initState();
    Timer(
      Duration(milliseconds: testing ? 0 : (kIsWeb ? msWeb : msMobile)),
      //TODO Changed for testing reasons
      () async {
        var loginB = await cacheFactory.get('settings', 'checkLogin');
        var introB = await cacheFactory.get('settings', 'checkIntro');

        String page = await cacheFactory.get("settings", "index");
        int index = 0;
        if (page == "News") index = 0;
        if (page == "Contacts") index = 1;
        if (page == "Campus") index = 3;

        if (introB == 'true' || introB == '1') {
          if (loginB == 'true' || loginB == '1') {
            void doNothingSnackbar(String message, bool isError, bool show) {}
            final username = await cacheFactory.get('users', 'username');
            final password = await cacheFactory.get('users', 'password');

            if (username != null && password != null) {
              final response = await login(context, username as String,
                  password as String, doNothingSnackbar);

              if (response != 200) {
                cacheFactory.removeLoginCache();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotLoggedInScreen(index: index),
                  ),
                );
              }
            } else {
              print("Error in users cache.");
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NotLoggedInScreen(index: index),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => IntroPage(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: Image.asset(
                kIsWeb
                    ? Provider.of<ThemeNotifier>(context).currentTheme! ==
                            kDarkTheme
                        ? 'assets/animation/NOVAanimation-web_dark.gif'
                        : 'assets/animation/NOVAanimation-web.gif'
                    : Provider.of<ThemeNotifier>(context).currentTheme! ==
                            kDarkTheme
                        ? 'assets/animation/NOVAanimation-mobile_dark.gif'
                        : 'assets/animation/NOVAanimation-mobile.gif',
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
