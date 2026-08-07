import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'This platform is not configured.',
        );
    }
  }

  // Web Configuration - UPDATED WITH ACTUAL VALUES
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYZPhoOZEGumMSiRCFKql5bPBrMy62cZQ',
    appId: '1:775139980767:web:ceb2c76d4d9a01daa3406a',
    messagingSenderId: '775139980767',
    projectId: 'movie-web-db3ce',
    storageBucket: 'movie-web-db3ce.firebasestorage.app',
    authDomain: 'movie-web-db3ce.firebaseapp.com',
    measurementId: 'G-EHV1QSTL64',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvEKqkOoPxviaP3G40Rq3tf-emm0yW-Bg',
    appId: '1:129949471050:android:4c4ec666efccdd7e7ef1b3',
    messagingSenderId: '129949471050',
    projectId: 'new-movie-app-two',
    storageBucket: 'new-movie-app-two.firebasestorage.app',
  );
}