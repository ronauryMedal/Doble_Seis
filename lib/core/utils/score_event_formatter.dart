import '../../data/models/game_session.dart';
import '../../data/models/score_event.dart';
import '../../domain/enums/special_event_type.dart';

/// Textos para la bitácora de anotaciones.
class ScoreEventFormatter {
  ScoreEventFormatter._();

  static String playerName(GameSession session, String teamId) {
    for (final p in session.participants) {
      if (p.id == teamId) return p.name;
    }
    return 'Jugador';
  }

  static String describe(ScoreEvent event, GameSession session) {
    final name = playerName(session, event.teamId);
    final time = _formatTime(event.timestamp);

    if (event.isGameVictory) {
      return '$name ganó la partida (+${event.points}) · $time';
    }

    final tag = switch (event.specialEvent) {
      SpecialEventType.capicua => 'Capicúa',
      SpecialEventType.tranque => 'Tranque',
      null => null,
    };

    if (tag != null) {
      return '$name  +${event.points}  $tag · $time';
    }

    return '$name  +${event.points} · $time';
  }

  /// Etiqueta corta para cuadrícula (sin hora).
  static String gridLabel(ScoreEvent event, GameSession session) {
    final name = playerName(session, event.teamId);
    if (event.isGameVictory) return '$name · GANÓ';
    final tag = switch (event.specialEvent) {
      SpecialEventType.capicua => ' · Capicúa',
      SpecialEventType.tranque => ' · Tranque',
      null => '',
    };
    return name + tag;
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
