import 'dart:async';

import 'package:unilink2023/presentation/intro_page.dart';
import 'package:unilink2023/presentation/screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:unilink2023/presentation/login_page.dart';
import 'package:flutter/src/foundation/constants.dart';

import '../data/cache_factory_provider.dart';

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
      const Duration(seconds: kIsWeb ? 6 : 0),
      //TODO Changed for testing reasons
      () async {

        bool loginB = false;
        loginB = await cacheFactory.get('settings', 'checkLogin') == 'true';
        bool introB = false;
        introB = await cacheFactory.get('settings', 'checkIntro') == 'true';

        if (introB == true) {
          if (loginB == true) {

            void doNothingSnackbar(String message, bool isError, bool show) {}
            final username = await cacheFactory.get('users', 'username');
            final password = await cacheFactory.get('users', 'password');

            if(username != null && password != null) {
              final response = await login(
                  context,
                  username as String,
                  password as String,
                  doNothingSnackbar
              );

              if (response != 200) {
                cacheFactory.removeLoginCache();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(),
                  ),
                );
              }

            } else {
              print("Error in users cache.");
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
