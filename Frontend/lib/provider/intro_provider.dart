import 'dart:async';

import 'package:apdc_ai_60313/screens/welcome_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/intro_page.dart';

class IntroProvider extends ChangeNotifier {
  void introPageShar() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('introPage', true);
    notifyListeners();
  }

  Future<bool> readIntroPageShar() async {
    final prefs = await SharedPreferences.getInstance();
    bool check = prefs.getBool('introPage');
    return check;
  }

  void check(BuildContext context) async {
    var check = await readIntroPageShar();
    Timer(
      Duration(seconds: 3),
      () {
        if (check == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(),
            ),
          );
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
}
