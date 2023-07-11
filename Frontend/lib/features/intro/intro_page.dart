import 'package:flutter/foundation.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/features/navigation/not_logged_in_page.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:android_intent/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';

void openNotificationSettings() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final AndroidIntent intent = AndroidIntent(
    action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
    data: 'package:${packageInfo.packageName}',
  );
  await intent.launch();
}

class IntroPage extends StatefulWidget {
  @override
  State<IntroPage> createState() => _IntroPageState();
}

void navigateToWelcomePage(BuildContext context) {
  cacheFactory.set('checkIntro', 'true');

  // Provider.of<IntroProvider>(context, listen: true)
  //     .readIntroPageShar();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => NotLoggedInScreen(),
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
                child: Image.asset(
                  'assets/images/university_slider.png',
                  height: 200,
                ),
              ),
              body:
                  "Now you have access to the information of your university in any place ",
              title: "Welcome",
            ),
            PageViewModel(
              image: Center(
                child: Image.asset(
                  'assets/images/news_slider.png',
                  height: 200,
                ),
              ),
              body: "Don't lose the last news about your university",
              title: "News",
            ),
            PageViewModel(
              image: Center(
                child: Image.asset(
                  'assets/images/chat_slider.png',
                  height: 200,
                ),
              ),
              body:
                  "Interact with your professors and colleagues with our chat",
              title: "Chat",
            ),
            PageViewModel(
              image: Center(
                child: Image.asset(
                  'assets/images/calendar_slider.png',
                  height: 200,
                ),
              ),
              body:
                  "Manage our own calendar and always be update of the events of your classes",
              title: "Calendar",
            ),
            PageViewModel(
              image: Center(
                child: Image.asset(
                  'assets/images/jumpIn_slider.png',
                  height: 200,
                ),
              ),
              body: "What are you waiting for ?",
              title: "Jump in!",
            ),
            if (!kIsWeb)
              PageViewModel(
                title: "Activate Notifications",
                body:
                    "To receive updates and important information, please enable floating notifications.",
                image: Center(
                  child: Icon(Icons.notifications, size: 100),
                ),
                footer: Center(
                  // Wrap the Container inside a Center widget
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.5, // 50% of screen width
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                      ),
                      onPressed: openNotificationSettings,
                      child: Text('Enable Notifications'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
