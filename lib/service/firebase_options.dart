import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBw4eAWM1a-lkR9nIO3KdkiYPKLZTnSOiM',
    appId: '1:296534550417:android:1072ea1b9b162dc6a51c30',
    messagingSenderId: '296534550417',
    projectId: 'books-discovery-261ff',
    databaseURL: 'https://books-discovery-261ff-default-rtdb.firebaseio.com',
    storageBucket: 'books-discovery-261ff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBw4eAWM1a-lkR9nIO3KdkiYPKLZTnSOiM',
    appId: '1:296534550417:ios:1072ea1b9b162dc6a51c30',
    messagingSenderId: '296534550417',
    projectId: 'books-discovery-261ff',
    databaseURL: 'https://books-discovery-261ff-default-rtdb.firebaseio.com',
    storageBucket: 'books-discovery-261ff.firebasestorage.app',
    iosBundleId: 'com.example.receiver',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBw4eAWM1a-lkR9nIO3KdkiYPKLZTnSOiM',
    appId: '1:296534550417:web:1072ea1b9b162dc6a51c30',
    messagingSenderId: '296534550417',
    projectId: 'books-discovery-261ff',
    authDomain: 'books-discovery-261ff.firebaseapp.com',
    databaseURL: 'https://books-discovery-261ff-default-rtdb.firebaseio.com',
    storageBucket: 'books-discovery-261ff.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBw4eAWM1a-lkR9nIO3KdkiYPKLZTnSOiM',
    appId: '1:296534550417:ios:1072ea1b9b162dc6a51c30',
    messagingSenderId: '296534550417',
    projectId: 'books-discovery-261ff',
    databaseURL: 'https://books-discovery-261ff-default-rtdb.firebaseio.com',
    storageBucket: 'books-discovery-261ff.firebasestorage.app',
    iosBundleId: 'com.example.receiver',
  );
}