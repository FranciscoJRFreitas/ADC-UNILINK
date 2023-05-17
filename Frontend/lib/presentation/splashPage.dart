import 'dart:async';

import 'package:unilink2023/presentation/intro_page.dart';
import 'package:unilink2023/presentation/screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/constants.dart';
import '../data/web_cookies.dart' as cookies;
import 'package:unilink2023/presentation/login_page.dart';
import 'package:unilink2023/data/sqlite.dart';
import 'dart:io' as io;
import 'package:flutter/src/foundation/constants.dart';
import '../domain/User.dart';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;
//import 'package:video_player/video_player.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
      const Duration(seconds: 6),
      () async {
        bool loginB = false;
        bool introB = false;

        if (kIsWeb) {
          cookies.setCookie('cookie', 'start');
          cookies.setCookie('theme', 'Light');

          if (cookies.getCookie('login') != null) loginB = true;
          if (cookies.getCookie('intro') != null) introB = true;
        } else if (io.Platform.isAndroid) {
          if (SqliteService().getCheckLogin() == true) loginB = true;
          if (SqliteService().getCheckIntro() == true) introB = true;
        }

        if (introB == true) {
          if (loginB == true) {
            int response = 0;

            void doNothingSnackbar(String message, bool isError, bool show) {}
            if (kIsWeb) {
              response = await login(context, cookies.getCookie('username')!,
                  cookies.getCookie('password')!, doNothingSnackbar);
            } else if (io.Platform.isAndroid) {
              final sqliteService = SqliteService();

              User user = await sqliteService.getUser();
              response = await login(context, user.username,
                  await sqliteService.getPassword(), doNothingSnackbar);
            }

            if (response != 200) {
              cache.removeLoginCache();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomePage(),
                ),
              );
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage(),
              ),
            );
          }
        } else {
          Navigator.push(
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
        body: Center(
            child: Lottie.asset(
          'animation/NovaAnimation.mp4.lottie.json',
          repeat: true,
          reverse: false,
        )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
