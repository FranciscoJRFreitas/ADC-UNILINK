import '../domain/Notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final NotificationService _notificationService;

  FirebaseMessagingService(this._notificationService) {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessage.listen(_handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    FirebaseMessaging.instance.getToken().then((String? token) {
      print('Token: $token');
    });
  }

  void requestPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _handleMessage(RemoteMessage message) {
    print('Got a message with data: ${message.data}');

    // Handle your message. You could, for example, show a notification:
    _notificationService.showLocalNotification(
      CustomNotification(
        id: int.tryParse(message.data['id'] ?? '') ?? 0,
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: message.data['url'],
      ),
    );
  }
}
