import 'cloud_sync.dart';

/// Nube desactivada — todo queda en Hive.
class NoOpCloudSync implements CloudSync {
  const NoOpCloudSync();

  @override
  bool get isConfigured => false;

  @override
  String? get userId => null;

  @override
  bool get isSignedIn => false;

  @override
  bool get isAnonymous => true;

  @override
  bool get isGoogleLinked => false;

  @override
  String? get displayName => null;

  @override
  String? get email => null;

  @override
  String? get photoUrl => null;

  @override
  Future<String> ensureSignedIn() async {
    throw StateError(
      'Cloud sync no está configurado. '
      'Crea el proyecto Firebase e implementa FirebaseCloudSync.',
    );
  }

  @override
  Future<String> signInWithGoogle() async {
    throw StateError('Cloud sync no está configurado.');
  }

  @override
  Future<void> pushHistoryEntry(Map<String, dynamic> entry) async {}

  @override
  Future<List<Map<String, dynamic>>> pullHistoryEntries() async => const [];

  @override
  Future<void> signOut() async {}
}
