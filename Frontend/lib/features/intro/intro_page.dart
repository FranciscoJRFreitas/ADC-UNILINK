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
          dotsFlex: 2,
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
                  'assets/images/news_slider.png',
                  height: 200,
                ),
              ),
              body:
                  "Stay tuned with the latest happenings and updates from your university.",
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
                  "Engage in enriching conversations with your professors and fellow students through our interactive chat feature.",
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
                  "Efficiently organize your schedule and never miss out on important class events with our personalized calendar tool.",
              title: "Calendar",
            ),
            PageViewModel(
              image: Center(
                child: Image.asset(
                  'assets/images/map_slider.png',
                  height: 200,
                ),
              ),
              body:
                  "Navigate our campus with ease, discover locations, and get real-time directions with our intuitive Maps feature.",
              title: "Maps",
            ),
            if (!kIsWeb)
              PageViewModel(
                title: "Activate Notifications",
                body:
                    "For real-time updates and crucial information, kindly enable our streamlined floating notifications.",
                image: Center(
                  child: Icon(Icons.notifications,
                      size: 100, color: Color(0xFF5857a2)),
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
            PageViewModel(
              image: Center(
                child: Image.asset(
                  'assets/images/jumpIn_slider.png',
                  height: 200,
                ),
              ),
              body: "Unleash the power of our university app!",
              title: "Dive in and explore now!",
            ),
          ],
        ),
      ),
    );
  }
}
