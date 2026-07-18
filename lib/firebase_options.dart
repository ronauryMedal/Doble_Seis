// File generated manually from google-services.json (Android).
// Cuando configures iOS, regenera con: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDECn4Xg1-kOiwJRUkVrxLp2r6TpyAdWnk',
    appId: '1:662605938274:android:f78dd85e8ccff4371fdb3b',
    messagingSenderId: '662605938274',
    projectId: 'doble-seis-6788b',
    storageBucket: 'doble-seis-6788b.firebasestorage.app',
    // Si creaste Realtime Database en otra región, ajusta la URL:
    databaseURL: 'https://doble-seis-6788b-default-rtdb.firebaseio.com',
  );
}
