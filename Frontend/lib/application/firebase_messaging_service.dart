import '../domain/Routes.dart';
import '../domain/Notification.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final NotificationService _notificationService;
  final _databaseRef = FirebaseDatabase.instance.ref();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  FirebaseMessagingService(this._notificationService);

  Future<void> initialize() async {
    print('Initializing FirebaseMessagingService...');
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );

    _onMessage();
    _onMessageOpenedApp();
    getDeviceFirebaseToken();
  }

  getDeviceFirebaseToken() async {
    print('Retrieving Firebase Messaging token...');
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('=======================================');
      print('TOKEN: $token');
      print('=======================================');

/*       if (_currentUser != null) {
        // Store the token in the database
        await _databaseRef.child('users/${_currentUser!.uid}').set({
          'token': token
        });
      } */

    } catch (e) {
      print('Failed to get Firebase Messaging token: $e');
    }
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notificationService.showLocalNotification(
          CustomNotification(
            id: android.hashCode,
            title: notification.title!,
            body: notification.body!,
            payload: message.data['route'] ?? '',
          ),
        );
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String route = message.data['route'] ?? '';
    if (route.isNotEmpty) {
      Routes.navigatorKey?.currentState?.pushNamed(route);
    }
  }
}
