import 'package:unilink2023/presentation/screen.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../data/web_cookies.dart' as cookies;
import 'dart:io' as io;
import 'package:flutter/src/foundation/constants.dart';
import '../data/sqlite.dart';

class IntroPage extends StatefulWidget {
  @override
  State<IntroPage> createState() => _IntroPageState();
}

void navigateToWelcomePage(BuildContext context) {
  if (kIsWeb) {
    cookies.setCookie('intro', 'true');
  } else if (io.Platform.isAndroid) {
    SqliteService().updateCheckIntro(1);
    SqliteService().updateTheme('Dark');
  }
  // Provider.of<IntroProvider>(context, listen: true)
  //     .readIntroPageShar();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => WelcomePage(),
    ),
  );
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IntroductionScreen(
          showDoneButton: true,
          onSkip: () { 
            navigateToWelcomePage(context);
          },
          onDone: () {
            navigateToWelcomePage(context);
          },
          done: Text("done", style: TextStyle(color: Colors.white)),
          showNextButton: true,
          next: Text("next", style: TextStyle(color: Colors.white)),
          skip: Text("skip", style: TextStyle(color: Colors.white)),
          showSkipButton: true,
          pages: [
            PageViewModel(
              image: Center(
                child: Lottie.asset(
                  'assets/animation/1.json',
                  repeat: true,
                  reverse: false,
                ),
              ),
              body:
                  "Rigid belief systems, including skeptism, is signing up for the suppression of curiosity.",
              title: "Sign Up",
            ),
            PageViewModel(
              image: Center(
                child: Lottie.asset(
                  'assets/animation/2.json',
                  repeat: true,
                  reverse: false,
                ),
              ),
              body:
                  "To remember our login details, we use the Remember Password Option displayed in Official site or work in an email account or any social / login to your sites",
              title: "Sign in",
            ),
            PageViewModel(
              image: Center(
                child: Lottie.asset(
                  'assets/animation/3.json',
                  repeat: true,
                  reverse: false,
                ),
              ),
              body: "Why are you waiting?",
              title: "Jump in!",
            ),
          ],
        ),
      ),
    );
  }
}
