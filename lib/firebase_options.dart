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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyAw70XonqJIguCkxXdy1Ib1nq6NxCcTZ1I',
    appId: '1:436277947185:web:658d54667261f1d39bde10',
    messagingSenderId: '436277947185',
    projectId: 'english-test-app',
    authDomain: 'english-test-app.firebaseapp.com',
    storageBucket: 'english-test-app.appspot.com',
    measurementId: 'G-RLZQN8GF05',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUjP7o76GUZo_Qru46qdj-YlgLg-7WjeQ',
    appId: '1:436277947185:android:fba3bda2fbc94e6b9bde10',
    messagingSenderId: '436277947185',
    projectId: 'english-test-app',
    storageBucket: 'english-test-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjkY985TqCukKNNfVSM04qrWpt48LNh4U',
    appId: '1:436277947185:ios:92e139f1466f8a1f9bde10',
    messagingSenderId: '436277947185',
    projectId: 'english-test-app',
    storageBucket: 'english-test-app.appspot.com',
    iosClientId: '436277947185-1u6nm5h4h6fl5nbfo90p37h73rimg5hl.apps.googleusercontent.com',
    iosBundleId: 'com.example.englishTestApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAjkY985TqCukKNNfVSM04qrWpt48LNh4U',
    appId: '1:436277947185:ios:9023239940cc55de9bde10',
    messagingSenderId: '436277947185',
    projectId: 'english-test-app',
    storageBucket: 'english-test-app.appspot.com',
    iosClientId: '436277947185-grko2bu3cr61v8ms0frhmf5urau8dmvh.apps.googleusercontent.com',
    iosBundleId: 'com.example.englishTestApp.RunnerTests',
  );
}