import 'package:flutter/material.dart';
import 'package:unilink2023/domain/User.dart';

import '../presentation/chat_page.dart';
import '../presentation/home_page.dart';


class Routes {
  static Map<String, Widget Function(BuildContext)> list = <String, WidgetBuilder>{
    '/home': (_) => HomePage(user: new User(displayName: "null", username: "null", email: "null", role: null, educationLevel: null, birthDate: null, profileVisibility: null, state: null, landlinePhone: null, mobilePhone: null, occupation: null, workplace: null, address: null, additionalAddress: null, locality: null, postalCode: null, nif: null, photoUrl: null)),
    '/chat': (_) => ChatPage(),
  };

  static String initial = '/chat';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}