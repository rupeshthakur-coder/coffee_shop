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
    apiKey: 'AIzaSyAlGEfhso71PGARm68uf77OnF_n-zJtpXM',
    appId: '1:836714253742:web:41b8c22de94c27fd5a0c3f',
    messagingSenderId: '836714253742',
    projectId: 'you-27e0c',
    authDomain: 'you-27e0c.firebaseapp.com',
    storageBucket: 'you-27e0c.firebasestorage.app',
    measurementId: 'G-EYDG0GNEHT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1Sl3jjqQJFWsk3lyw3_7t_-NqJUEeq1U',
    appId: '1:836714253742:android:3ddd704349b342595a0c3f',
    messagingSenderId: '836714253742',
    projectId: 'you-27e0c',
    storageBucket: 'you-27e0c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqjz51hgb9E4rX6PivdZwUflfFByWJUb0',
    appId: '1:836714253742:ios:1a8003d6a81bdc255a0c3f',
    messagingSenderId: '836714253742',
    projectId: 'you-27e0c',
    storageBucket: 'you-27e0c.firebasestorage.app',
    iosClientId:
        '836714253742-5hkf1suuqc9eh7o7vo81n0knohuqophj.apps.googleusercontent.com',
    iosBundleId: 'com.example.coffeeShop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBqjz51hgb9E4rX6PivdZwUflfFByWJUb0',
    appId: '1:836714253742:ios:1a8003d6a81bdc255a0c3f',
    messagingSenderId: '836714253742',
    projectId: 'you-27e0c',
    storageBucket: 'you-27e0c.firebasestorage.app',
    iosClientId:
        '836714253742-5hkf1suuqc9eh7o7vo81n0knohuqophj.apps.googleusercontent.com',
    iosBundleId: 'com.example.coffeeShop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAlGEfhso71PGARm68uf77OnF_n-zJtpXM',
    appId: '1:836714253742:web:cddf83db2d69dd9e5a0c3f',
    messagingSenderId: '836714253742',
    projectId: 'you-27e0c',
    authDomain: 'you-27e0c.firebaseapp.com',
    storageBucket: 'you-27e0c.firebasestorage.app',
    measurementId: 'G-T16YR8X4Q1',
  );
}
