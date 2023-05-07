// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBG1SLvxu_9fOCB7sor3TANEhGBwvfSINM',
    appId: '1:55982237431:web:3cab3a2da88b14f5f595f2',
    messagingSenderId: '55982237431',
    projectId: 'unilink2023',
    authDomain: 'unilink2023.firebaseapp.com',
    storageBucket: 'unilink2023.appspot.com',
    measurementId: 'G-25XL02NSV4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4ktovWvTTMZ2NRSqCwB23ApXK6j--0FI',
    appId: '1:55982237431:android:6c54171c07fb5038f595f2',
    messagingSenderId: '55982237431',
    projectId: 'unilink2023',
    storageBucket: 'unilink2023.appspot.com',
  );
}
