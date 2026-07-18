import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/game_history_entry.dart';
import '../models/game_session.dart';
import '../sync/cloud_sync.dart';
import '../sync/noop_cloud_sync.dart';

/// Repositorio híbrido: Hive (siempre) + nube (opcional).
///
/// - Partida en curso y onboarding → solo local.
/// - Historial / victorias → local primero; luego se intenta subir a la nube.
/// - Stats se calculan desde [loadHistory] (local ya fusionado tras un pull).
///
/// Mientras creas la cuenta Firebase, usa [NoOpCloudSync] (por defecto).
class GameRepository {
  GameRepository({CloudSync? cloudSync})
      : _cloud = cloudSync ?? const NoOpCloudSync();

  Box<dynamic>? _box;
  final CloudSync _cloud;

  CloudSync get cloud => _cloud;

  bool get isCloudEnabled => _cloud.isConfigured;

  Future<void> init({String? testHivePath}) async {
    if (testHivePath != null) {
      Hive.init(testHivePath);
    } else {
      await Hive.initFlutter();
    }
    _box = await Hive.openBox(AppConstants.hiveBoxName);
  }

  // ─── Sesión actual (solo local) ───────────────────────────────────────────

  Future<void> saveSession(GameSession session) async {
    await _box?.put(session.id, session.toMap());
    await _box?.put('current', session.id);
  }

  GameSession? loadCurrentSession() {
    final currentId = _box?.get('current') as String?;
    if (currentId == null) return null;
    final data = _box?.get(currentId);
    if (data == null) return null;
    return GameSession.fromMap(Map<dynamic, dynamic>.from(data as Map));
  }

  Future<void> clearCurrent() async {
    final currentId = _box?.get('current') as String?;
    if (currentId != null) {
      await _box?.delete(currentId);
    }
    await _box?.delete('current');
  }

  bool get hasSavedSession => loadCurrentSession() != null;

  // ─── Onboarding (solo local) ──────────────────────────────────────────────

  bool get isOnboardingComplete =>
      _box?.get(AppConstants.hiveOnboardingCompleteKey) == true;

  Future<void> completeOnboarding() async {
    await _box?.put(AppConstants.hiveOnboardingCompleteKey, true);
  }

  // ─── Historial / victorias ────────────────────────────────────────────────

  /// Guarda en Hive y, si la nube está activa, intenta subir en segundo plano.
  Future<void> saveHistoryEntry(GameHistoryEntry entry) async {
    await _saveHistoryLocal(entry);
    await _tryPushToCloud(entry);
  }

  /// Historial local (rápido, sync). Tras [syncHistoryFromCloud] ya incluye nube.
  List<GameHistoryEntry> loadHistory() {
    final ids = List<String>.from(
      (_box?.get(AppConstants.hiveHistoryIndexKey) as List?) ?? [],
    );
    return ids
        .map((id) {
          final data = _box?.get('history_$id');
          if (data == null) return null;
          return GameHistoryEntry.fromMap(
            Map<dynamic, dynamic>.from(data as Map),
          );
        })
        .whereType<GameHistoryEntry>()
        .toList();
  }

  /// Baja victorias remotas, las fusiona en Hive y devuelve el historial unificado.
  ///
  /// Llámalo al abrir Historial / Stats cuando el usuario esté logueado.
  Future<List<GameHistoryEntry>> syncHistoryFromCloud() async {
    if (!_cloud.isConfigured) return loadHistory();

    try {
      if (!_cloud.isSignedIn) {
        await _cloud.ensureSignedIn();
      }
      final remote = await _cloud.pullHistoryEntries();
      for (final raw in remote) {
        final entry = GameHistoryEntry.fromMap(raw);
        await _saveHistoryLocal(entry, prependIndex: true);
      }
    } on Object catch (e, st) {
      debugPrint('[CloudSync] pull falló: $e\n$st');
    }
    return loadHistory();
  }

  /// Intenta login en la nube, sube historial local y baja remoto.
  Future<bool> enableCloudSync() async {
    if (!_cloud.isConfigured) {
      debugPrint('[CloudSync] desactivado (NoOp)');
      return false;
    }
    try {
      await _cloud.ensureSignedIn();
      // Sube lo que ya había en el teléfono (antes de Firebase).
      for (final entry in loadHistory()) {
        await _cloud.pushHistoryEntry(entry.toMap());
      }
      await syncHistoryFromCloud();
      debugPrint('[CloudSync] sync inicial OK (uid=${_cloud.userId})');
      return true;
    } on Object catch (e, st) {
      debugPrint('[CloudSync] enable falló: $e\n$st');
      return false;
    }
  }

  /// Login con Google + subida/bajada de historial.
  Future<bool> signInWithGoogleAndSync() async {
    if (!_cloud.isConfigured) return false;
    try {
      await _cloud.signInWithGoogle();
      for (final entry in loadHistory()) {
        await _cloud.pushHistoryEntry(entry.toMap());
      }
      await syncHistoryFromCloud();
      debugPrint('[CloudSync] Google sync OK (uid=${_cloud.userId})');
      return true;
    } on Object catch (e, st) {
      debugPrint('[CloudSync] Google login falló: $e\n$st');
      rethrow;
    }
  }

  /// Cierra sesión Google y vuelve a anónimo (historial local se conserva).
  Future<void> signOutCloud() async {
    if (!_cloud.isConfigured) return;
    try {
      await _cloud.signOut();
    } on Object catch (e, st) {
      debugPrint('[CloudSync] signOut falló: $e\n$st');
    }
  }

  Future<void> _saveHistoryLocal(
    GameHistoryEntry entry, {
    bool prependIndex = true,
  }) async {
    await _box?.put('history_${entry.id}', entry.toMap());
    if (!prependIndex) return;

    final ids = List<String>.from(
      (_box?.get(AppConstants.hiveHistoryIndexKey) as List?) ?? [],
    );
    if (ids.contains(entry.id)) return;
    ids.insert(0, entry.id);
    await _box?.put(AppConstants.hiveHistoryIndexKey, ids);
  }

  Future<void> _tryPushToCloud(GameHistoryEntry entry) async {
    if (!_cloud.isConfigured) return;
    try {
      if (!_cloud.isSignedIn) {
        await _cloud.ensureSignedIn();
      }
      await _cloud.pushHistoryEntry(entry.toMap());
    } on Object catch (e, st) {
      debugPrint('[CloudSync] push falló: $e\n$st');
    }
  }
}

