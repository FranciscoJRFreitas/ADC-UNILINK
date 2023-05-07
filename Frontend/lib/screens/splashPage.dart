import 'dart:async';

import 'package:apdc_ai_60313/screens/intro_page.dart';
import 'package:apdc_ai_60313/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:apdc_ai_60313/constants.dart';
import '../provider/intro_provider.dart';
import '../util/sharePreference.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  IntroProvider providerTrue;
  IntroProvider providerFalse;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
      const Duration(seconds: 5),
      () async {
        bool check = await providerTrue.readIntroPageShar();

        bool checkLogin = await loginCheck();

        // Future<bool?> check = Provider.of<IntroProvider>(context, listen: true)
        //     .readIntroPageShar();
        if (check) {
          if (checkLogin) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
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

        if (check == false) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IntroPage(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    providerTrue = Provider.of<IntroProvider>(context, listen: true);
    providerFalse = Provider.of<IntroProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Style.white,
        body: Center(
          child: Lottie.asset(
            '/animation/4.json',
            repeat: true,
            reverse: false,
          ),
        ),
      ),
    );
  }
}
