import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'cloud_sync.dart';

/// Sincronización de historial/victorias con Firebase Realtime Database.
///
/// Rutas:
/// `users/{uid}/meta` — presencia / perfil
/// `users/{uid}/history/{entryId}` ← historial
class FirebaseCloudSync implements CloudSync {
  FirebaseCloudSync({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = database ??
            FirebaseDatabase.instanceFor(
              app: Firebase.app(),
              databaseURL:
                  'https://doble-seis-6788b-default-rtdb.firebaseio.com',
            ),
        _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseDatabase _db;
  final GoogleSignIn _google;

  bool _googleReady = false;

  /// Web client ID de Firebase (Authentication → Google → ID de cliente web).
  /// Necesario en Android para obtener `idToken` usable por Firebase Auth.
  ///
  /// Déjalo vacío hasta configurarlo; [signInWithGoogle] lo pedirá si falta.
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  @override
  bool get isConfigured => Firebase.apps.isNotEmpty;

  @override
  String? get userId => _auth.currentUser?.uid;

  @override
  bool get isSignedIn => userId != null;

  @override
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  @override
  bool get isGoogleLinked {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  @override
  String? get displayName => _auth.currentUser?.displayName;

  @override
  String? get email => _auth.currentUser?.email;

  @override
  String? get photoUrl => _auth.currentUser?.photoURL;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) return;
    await _google.initialize(
      serverClientId: webClientId.isEmpty ? null : webClientId,
    );
    _googleReady = true;
  }

  @override
  Future<String> ensureSignedIn() async {
    var uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      final credential = await _auth.signInAnonymously();
      uid = credential.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw StateError('No se pudo iniciar sesión anónima en Firebase.');
      }
      debugPrint('[CloudSync] Login anónimo OK → $uid');
    }

    await _touchMeta(uid);
    return uid;
  }

  @override
  Future<String> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    if (!_google.supportsAuthenticate()) {
      throw StateError('Google Sign-In no está disponible en esta plataforma.');
    }

    final googleUser = await _google.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google no devolvió idToken. En Firebase Console: '
        '1) habilita el proveedor Google, '
        '2) añade el SHA-1 de debug/release, '
        '3) descarga de nuevo google-services.json, '
        '4) configura GOOGLE_WEB_CLIENT_ID (client web).',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final current = _auth.currentUser;

    if (current != null && current.isAnonymous) {
      try {
        await current.linkWithCredential(credential);
        debugPrint('[CloudSync] Anónimo vinculado a Google → ${current.uid}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use' ||
            e.code == 'provider-already-linked') {
          // Esa cuenta Google ya existe: entramos con ella.
          await _auth.signInWithCredential(credential);
          debugPrint(
            '[CloudSync] Google ya existía → uid=${_auth.currentUser?.uid}',
          );
        } else {
          rethrow;
        }
      }
    } else {
      await _auth.signInWithCredential(credential);
      debugPrint('[CloudSync] Login Google → uid=${_auth.currentUser?.uid}');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('Login con Google no produjo usuario.');
    }

    await _touchMeta(uid, googleEmail: googleUser.email);
    return uid;
  }

  @override
  Future<void> pushHistoryEntry(Map<String, dynamic> entry) async {
    final uid = userId ?? await ensureSignedIn();
    final id = entry['id'] as String?;
    if (id == null || id.isEmpty) return;

    await _db.ref('users/$uid/history/$id').set(_sanitizeForFirebase(entry));
    debugPrint('[CloudSync] Subida history/$id');
  }

  @override
  Future<List<Map<String, dynamic>>> pullHistoryEntries() async {
    final uid = userId ?? await ensureSignedIn();
    final snap = await _db.ref('users/$uid/history').get();
    if (!snap.exists || snap.value == null) return const [];

    final value = snap.value;
    if (value is! Map) return const [];

    final result = <Map<String, dynamic>>[];
    for (final entry in value.entries) {
      final raw = entry.value;
      if (raw is Map) {
        result.add(Map<String, dynamic>.from(
          raw.map((k, v) => MapEntry(k.toString(), v)),
        ));
      }
    }
    debugPrint('[CloudSync] Bajadas ${result.length} entradas remotas');
    return result;
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await _google.signOut();
    } on Object catch (e) {
      debugPrint('[CloudSync] Google signOut: $e');
    }
    await _auth.signOut();
    // Nueva sesión anónima para que la app siga pudiendo subir en local→nube.
    await ensureSignedIn();
  }

  Future<void> _touchMeta(String uid, {String? googleEmail}) async {
    await _db.ref('users/$uid/meta').update({
      'lastSeenAt': DateTime.now().toIso8601String(),
      'platform': defaultTargetPlatform.name,
      if (displayName != null) 'displayName': displayName,
      if (email != null || googleEmail != null)
        'email': email ?? googleEmail,
      'isAnonymous': isAnonymous,
      'isGoogleLinked': isGoogleLinked,
    });
    debugPrint('[CloudSync] meta actualizado');
  }

  Map<String, dynamic> _sanitizeForFirebase(Map<String, dynamic> input) {
    dynamic convert(dynamic value) {
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), convert(v)));
      }
      if (value is List) {
        return value.map(convert).toList();
      }
      return value;
    }

    return Map<String, dynamic>.from(convert(input) as Map);
  }
}
