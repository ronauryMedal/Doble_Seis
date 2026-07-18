// Opciones Firebase (Android). La API key NO va en el repo.
// Copia firebase_api_key.local.example.dart → firebase_api_key.local.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'core/config/firebase_api_key.local.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web no configurado aún para Firebase.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS no configurado. Añade la app iOS en Firebase Console '
          'o ejecuta flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'Firebase no está configurado para esta plataforma.',
        );
    }
  }

  static FirebaseOptions get android {
    final key = firebaseAndroidApiKeyLocal.trim();
    if (key.isEmpty) {
      throw StateError(
        'Falta lib/core/config/firebase_api_key.local.dart con la API key. '
        'Copia firebase_api_key.local.example.dart y pega la clave de '
        'google-services.json.',
      );
    }
    return FirebaseOptions(
      apiKey: key,
      appId: '1:662605938274:android:f78dd85e8ccff4371fdb3b',
      messagingSenderId: '662605938274',
      projectId: 'doble-seis-6788b',
      storageBucket: 'doble-seis-6788b.firebasestorage.app',
      databaseURL: 'https://doble-seis-6788b-default-rtdb.firebaseio.com',
    );
  }
}
