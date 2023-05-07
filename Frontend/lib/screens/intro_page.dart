import 'package:apdc_ai_60313/screens/screen.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:apdc_ai_60313/provider/intro_provider.dart';

class IntroPage extends StatefulWidget {
  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  IntroProvider providerTrue;
  IntroProvider providerFalse;

  @override
  Widget build(BuildContext context) {
    providerTrue = Provider.of<IntroProvider>(context, listen: true);
    providerFalse = Provider.of<IntroProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        body: IntroductionScreen(
          showDoneButton: true,
          onDone: () async {
            providerFalse.introPageShar();

            // Provider.of<IntroProvider>(context, listen: true)
            //     .readIntroPageShar();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage(),
              ),
            );
            // if (providerTrue!.intro == false) {
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const LoginPage(),
            //     ),
            //   );
            // }

            //  else {
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const LoginPage(),
            //     ),
            //   );
            // }
            // providerFalse!.introPageShar();
          },
          done: Text("done"),
          showNextButton: true,
          next: Text("next"),
          skip: Text("skip"),
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
              body: "Why are you waiting",
              title: "Go",
            ),
          ],
        ),
      ),
    );
  }
}
