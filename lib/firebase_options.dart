import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const _webApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const _webAuthDomain =
      String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN');
  static const _webDatabaseUrl =
      String.fromEnvironment('FIREBASE_WEB_DATABASE_URL');
  static const _webProjectId =
      String.fromEnvironment('FIREBASE_WEB_PROJECT_ID');
  static const _webStorageBucket =
      String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET');
  static const _webMessagingSenderId =
      String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID');
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _webMeasurementId =
      String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID');

  static const _androidApiKey =
      String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const _androidProjectId =
      String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID');
  static const _androidStorageBucket =
      String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET');
  static const _androidMessagingSenderId =
      String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID');
  static const _androidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID');

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      _ensureConfigured(
        platform: 'web',
        requiredValues: {
          'FIREBASE_WEB_API_KEY': _webApiKey,
          'FIREBASE_WEB_PROJECT_ID': _webProjectId,
          'FIREBASE_WEB_APP_ID': _webAppId,
        },
      );
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _ensureConfigured(
          platform: 'android',
          requiredValues: {
            'FIREBASE_ANDROID_API_KEY': _androidApiKey,
            'FIREBASE_ANDROID_PROJECT_ID': _androidProjectId,
            'FIREBASE_ANDROID_APP_ID': _androidAppId,
          },
        );
        return android;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static void _ensureConfigured({
    required String platform,
    required Map<String, String> requiredValues,
  }) {
    final missing = requiredValues.entries
        .where((entry) => entry.value.isEmpty)
        .map((entry) => entry.key)
        .join(', ');

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing Firebase environment values for $platform: $missing',
      );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _webApiKey,
    authDomain: _webAuthDomain,
    databaseURL: _webDatabaseUrl,
    projectId: _webProjectId,
    storageBucket: _webStorageBucket,
    messagingSenderId: _webMessagingSenderId,
    appId: _webAppId,
    measurementId: _webMeasurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _androidApiKey,
    projectId: _androidProjectId,
    storageBucket: _androidStorageBucket,
    messagingSenderId: _androidMessagingSenderId,
    appId: _androidAppId,
  );
}
