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
import 'dart:math' as math;

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    super.initState();
    Timer(
      Duration(milliseconds: (kIsWeb ? 0 : 2500)),
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 4, 62, 129),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: Transform.rotate(
                angle: _controller.value * 2.0 * math.pi,
                child: Image.asset(
                  /*kIsWeb
                      ? Provider.of<ThemeNotifier>(context).currentTheme! ==
                              kDarkTheme
                          ? 'assets/icon/ICON_UNILINK-03.png'
                          : 'assets/icon/ICON_UNILINK-03.png' // por o fundo branco
                      : Provider.of<ThemeNotifier>(context).currentTheme! ==
                              kDarkTheme
                          ? 'assets/icon/ICON_UNILINK-03.png'
                          : 'assets/icon/ICON_UNILINK-03.png',*/
                  'assets/icon/3dgifmaker67696.gif',
                  width: 300,
                  height: 300,
                  //fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
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
    _controller.dispose();
  }
}
