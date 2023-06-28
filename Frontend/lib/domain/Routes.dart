import 'package:flutter/material.dart';

import '../presentation/chat_page.dart';
import '../presentation/home_page.dart';
import 'User.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/home': (_) => HomePage(),
    '/chat': (_) => ChatPage(
          user: User(displayName: '', username: '', email: '', role: '', educationLevel: '', birthDate: '', profileVisibility: '', state: '', mobilePhone: '',
              occupation: '', creationTime: ''),
        ),
  };

  static String initial = '/chat';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
