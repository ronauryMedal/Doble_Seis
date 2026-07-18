/// Contrato de sincronización en la nube (Firebase / Supabase).
///
/// La app funciona sin nube: [NoOpCloudSync] no hace nada.
abstract class CloudSync {
  /// `true` si hay backend configurado y listo.
  bool get isConfigured;

  /// UID del usuario autenticado, o `null` si es solo local.
  String? get userId;

  /// ¿Hay sesión Firebase (anónima o Google)?
  bool get isSignedIn;

  /// Sesión anónima (aún no vinculó Google).
  bool get isAnonymous;

  /// ¿Tiene cuenta Google vinculada?
  bool get isGoogleLinked;

  String? get displayName;
  String? get email;
  String? get photoUrl;

  /// Login anónimo (o reutiliza sesión). Devuelve el uid.
  Future<String> ensureSignedIn();

  /// Continuar con Google. Vincula la sesión anónima si existe.
  /// Devuelve el uid. Lanza si el usuario cancela o falla la config OAuth.
  Future<String> signInWithGoogle();

  /// Sube una victoria al historial remoto del usuario.
  Future<void> pushHistoryEntry(Map<String, dynamic> entry);

  /// Descarga el historial remoto (mapas crudos, mismo formato que Hive).
  Future<List<Map<String, dynamic>>> pullHistoryEntries();

  /// Cierra Google + Firebase y vuelve a sesión anónima.
  Future<void> signOut();
}
