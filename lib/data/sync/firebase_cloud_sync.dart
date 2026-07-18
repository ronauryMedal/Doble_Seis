import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'cloud_sync.dart';

/// Sincronización de historial/victorias con Firebase Realtime Database.
///
/// Rutas:
/// `users/{uid}/history/{entryId}` ← [GameHistoryEntry.toMap]
class FirebaseCloudSync implements CloudSync {
  FirebaseCloudSync({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = database ?? FirebaseDatabase.instance;

  final FirebaseAuth _auth;
  final FirebaseDatabase _db;

  @override
  bool get isConfigured => Firebase.apps.isNotEmpty;

  @override
  String? get userId => _auth.currentUser?.uid;

  @override
  bool get isSignedIn => userId != null;

  @override
  Future<String> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing.uid;

    final credential = await _auth.signInAnonymously();
    final uid = credential.user?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('No se pudo iniciar sesión anónima en Firebase.');
    }
    return uid;
  }

  @override
  Future<void> pushHistoryEntry(Map<String, dynamic> entry) async {
    final uid = userId ?? await ensureSignedIn();
    final id = entry['id'] as String?;
    if (id == null || id.isEmpty) return;

    await _db.ref('users/$uid/history/$id').set(_sanitizeForFirebase(entry));
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
    return result;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Firebase no acepta algunos tipos Dart crudos en mapas anidados.
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
