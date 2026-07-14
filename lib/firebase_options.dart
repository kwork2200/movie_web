import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web FirebaseOptions are missing. Register a Web App in Firebase Console.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvEKqkOoPxviaP3G40Rq3tf-emm0yW-Bg',
    appId: '1:129949471050:android:4c4ec666efccdd7e7ef1b3',
    messagingSenderId: '129949471050',
    projectId: 'new-movie-app-two',
    storageBucket: 'new-movie-app-two.firebasestorage.app',
  );
}