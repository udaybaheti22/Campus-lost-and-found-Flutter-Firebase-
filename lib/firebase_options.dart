import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABE7-d4tnFQaYfEPGlGiMvWPRdARBhX3A',
    authDomain: 'campus-lost-and-found-32fc3.firebaseapp.com',
    databaseURL: 'https://campus-lost-and-found-32fc3-default-rtdb.asia-southeast1.firebasedatabase.app',
    projectId: 'campus-lost-and-found-32fc3',
    storageBucket: 'campus-lost-and-found-32fc3.firebasestorage.app',
    messagingSenderId: '752031826212',
    appId: '1:752031826212:web:65c04d7c449f69c4bef3b1',
    measurementId: 'G-F13G4L1M9M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxjCH9LReN0Dd4tjKjFMIrEVdVsg0XlJA',
    projectId: 'campus-lost-and-found-32fc3',
    storageBucket: 'campus-lost-and-found-32fc3.firebasestorage.app',
    messagingSenderId: '752031826212',
    appId: '1:752031826212:android:db0fa25f1665012ebef3b1',
  );
}
