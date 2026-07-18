import 'cloud_sync.dart';

/// Nube desactivada — todo queda en Hive. Úsalo mientras creas la cuenta Firebase.
class NoOpCloudSync implements CloudSync {
  const NoOpCloudSync();

  @override
  bool get isConfigured => false;

  @override
  String? get userId => null;

  @override
  bool get isSignedIn => userId != null;

  @override
  Future<String> ensureSignedIn() async {
    throw StateError(
      'Cloud sync no está configurado. '
      'Crea el proyecto Firebase e implementa FirebaseCloudSync.',
    );
  }

  @override
  Future<void> pushHistoryEntry(Map<String, dynamic> entry) async {}

  @override
  Future<List<Map<String, dynamic>>> pullHistoryEntries() async => const [];

  @override
  Future<void> signOut() async {}
}
