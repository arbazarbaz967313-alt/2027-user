import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjN72zb90c8GzasTiFx-wZHKk_XbL2XPw',
    appId: '1:93914740482:android:a28fd1647bfca1361e741b',
    messagingSenderId: '93914740482',
    projectId: 'dgsell',
    storageBucket: 'dgsell.firebasestorage.app',
    databaseURL: 'https://dgsell-default-rtdb.firebaseio.com',
  );
}
