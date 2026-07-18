/// Contrato de sincronización en la nube (Firebase / Supabase).
///
/// La app funciona sin nube: [NoOpCloudSync] no hace nada.
/// Cuando configures Firebase, implementa [FirebaseCloudSync].
abstract class CloudSync {
  /// `true` si hay backend configurado y listo (aunque el usuario aún no inicie sesión).
  bool get isConfigured;

  /// UID del usuario autenticado, o `null` si es solo local.
  String? get userId;

  /// ¿Hay sesión de usuario para subir/bajar historial?
  bool get isSignedIn;

  /// Login anónimo (o el que elijas). Devuelve el uid.
  Future<String> ensureSignedIn();

  /// Sube una victoria al historial remoto del usuario.
  Future<void> pushHistoryEntry(Map<String, dynamic> entry);

  /// Descarga el historial remoto (mapas crudos, mismo formato que Hive).
  Future<List<Map<String, dynamic>>> pullHistoryEntries();

  /// Cierra sesión en la nube (opcional).
  Future<void> signOut();
}
