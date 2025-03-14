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
    apiKey: 'AIzaSyAFyARTe5htvFenm-AwoVUOES3iwce8sjM',
    appId: '1:327324836622:web:252e7906b04fde8136ad5f',
    messagingSenderId: '327324836622',
    projectId: 'eshop-multivendor-new',
    authDomain: 'eshop-multivendor-new.firebaseapp.com',
    storageBucket: 'eshop-multivendor-new.appspot.com',
    measurementId: 'G-J7Y3R8EJPC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWlkQydzinZ6dzeGys388g8t0B30_o8ZE',
    appId: '1:412412092775:android:5f36635793ef6c7b340fc2',
    messagingSenderId: '412412092775',
    projectId: 'baiexpress-9c7ca',
    storageBucket: 'baiexpress-9c7ca.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDN9QZzslXaxKryW5qN_OTL9O3o-tGkxpM',
    appId: '1:412412092775:ios:36a4cdf8723bfd9d340fc2',
    messagingSenderId: '412412092775',
    projectId: 'baiexpress-9c7ca',
    storageBucket: 'baiexpress-9c7ca.firebasestorage.app',
    androidClientId: '412412092775-iekn56e40ihh6hd8ibdcroqbc6rn8unh.apps.googleusercontent.com',
    iosClientId: '412412092775-mc14di59ffca5hhklldlheo4pvop1cjq.apps.googleusercontent.com',
    iosBundleId: 'com.baiexpress.customer',
  );

}