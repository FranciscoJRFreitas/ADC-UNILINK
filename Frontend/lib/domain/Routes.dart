import 'package:flutter/material.dart';
import 'package:unilink2023/domain/User.dart';

import '../presentation/chat_page.dart';
import '../presentation/home_page.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/home': (_) => HomePage(),
    '/chat': (_) => ChatPage(username: 'null',),
  };

  static String initial = '/chat';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
