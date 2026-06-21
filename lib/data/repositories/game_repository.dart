import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/game_history_entry.dart';
import '../models/game_session.dart';

/// Capa de datos: abstrae Hive para que el BLoC no sepa de la BD.
///
/// Patrón Repository: la UI/BLoC pide "guarda la partida",
/// sin importarle si es Hive, SQLite o Firebase.
class GameRepository {
  Box<dynamic>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.hiveBoxName);
  }

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

  Future<void> saveHistoryEntry(GameHistoryEntry entry) async {
    await _box?.put('history_${entry.id}', entry.toMap());
    final ids = List<String>.from(
      (_box?.get(AppConstants.hiveHistoryIndexKey) as List?) ?? [],
    );
    ids.remove(entry.id);
    ids.insert(0, entry.id);
    await _box?.put(AppConstants.hiveHistoryIndexKey, ids);
  }

  List<GameHistoryEntry> loadHistory() {
    final ids = List<String>.from(
      (_box?.get(AppConstants.hiveHistoryIndexKey) as List?) ?? [],
    );
    return ids
        .map((id) {
          final data = _box?.get('history_$id');
          if (data == null) return null;
          return GameHistoryEntry.fromMap(Map<dynamic, dynamic>.from(data as Map));
        })
        .whereType<GameHistoryEntry>()
        .toList();
  }
}
