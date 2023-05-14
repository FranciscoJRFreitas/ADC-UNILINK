import 'dart:async';

import 'package:unilink2023/screens/intro_page.dart';
import 'package:unilink2023/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/constants.dart';
import '../localstorage/web_cookies.dart' as cookies;
import 'package:unilink2023/screens/login_page.dart';
import 'package:unilink2023/localstorage/sqlite.dart';
import 'dart:io' as io;
import 'package:flutter/src/foundation/constants.dart';
import '../util/User.dart';
import 'package:unilink2023/util/cacheFactory.dart' as cache;

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
      const Duration(seconds: 2),
      () async {

        bool loginB = false;
        bool introB = false;

        if (kIsWeb){

          cookies.setCookie('cookie', 'start');

          if (cookies.getCookie('login') != null) loginB = true;
          if (cookies.getCookie('intro') != null) introB = true;

        } else if (io.Platform.isAndroid){

          if (SqliteService().getCheckLogin() == true) loginB = true;
          if (SqliteService().getCheckIntro() == true) introB = true;

        }


        if (introB == true) {
          if (loginB == true) {

            int response = 0;

            void doNothingSnackbar(String message, bool isError, bool show) {}
            if (kIsWeb){

            response = await login(context, cookies.getCookie('username')!, cookies.getCookie('password')!, doNothingSnackbar);

            } else if (io.Platform.isAndroid){

              final sqliteService = SqliteService();

              User user = await sqliteService.getUser();
              response = await login(context, user.username,  await sqliteService.getPassword(), doNothingSnackbar);
            }

            if(response != 200){

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
        backgroundColor: kBackgroundColor,
        body: Center(child: Image.asset('/images/NOVA_Logo.png')),
      ),
    );
  }
}
