// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBbWrIkr7UTvL6v4tcyM6FHW7eCqE9v-jY',
    appId: '1:138763580025:web:7898133b6564b3f04d9aa8',
    messagingSenderId: '138763580025',
    projectId: 'dogland-v0',
    authDomain: 'dogland-v0.firebaseapp.com',
    storageBucket: 'dogland-v0.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBb1u438Rj9wp-Htfh0YWLYGcYCjqJvAU',
    appId: '1:138763580025:android:37ce0e7c85f57ca14d9aa8',
    messagingSenderId: '138763580025',
    projectId: 'dogland-v0',
    storageBucket: 'dogland-v0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAE2rDUeab_vLqSL3LJJo2r-NGtIl9t5wE',
    appId: '1:138763580025:ios:d5ea30ba09095cec4d9aa8',
    messagingSenderId: '138763580025',
    projectId: 'dogland-v0',
    storageBucket: 'dogland-v0.appspot.com',
    iosBundleId: 'com.example.dogland',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAE2rDUeab_vLqSL3LJJo2r-NGtIl9t5wE',
    appId: '1:138763580025:ios:d5ea30ba09095cec4d9aa8',
    messagingSenderId: '138763580025',
    projectId: 'dogland-v0',
    storageBucket: 'dogland-v0.appspot.com',
    iosBundleId: 'com.example.dogland',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBbWrIkr7UTvL6v4tcyM6FHW7eCqE9v-jY',
    appId: '1:138763580025:web:07e85a29c9ed770e4d9aa8',
    messagingSenderId: '138763580025',
    projectId: 'dogland-v0',
    authDomain: 'dogland-v0.firebaseapp.com',
    storageBucket: 'dogland-v0.appspot.com',
  );

}