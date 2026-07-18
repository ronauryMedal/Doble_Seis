import '../../domain/enums/special_event_type.dart';

/// Registro de cada suma de puntos — útil para historial y sync futuro.
class ScoreEvent {
  const ScoreEvent({
    required this.teamId,
    required this.points,
    required this.timestamp,
    this.specialEvent,
    this.note,
    this.isGameVictory = false,
    this.roundId,
  });

  final String teamId;
  final int points;
  final DateTime timestamp;
  final SpecialEventType? specialEvent;
  final String? note;
  final bool isGameVictory;

  /// En Modo Fácil: agrupa los dos puntos (equipo A y B) de una misma ronda.
  final String? roundId;

  Map<String, dynamic> toMap() => {
        'teamId': teamId,
        'points': points,
        'timestamp': timestamp.toIso8601String(),
        'specialEvent': specialEvent?.name,
        'note': note,
        'isGameVictory': isGameVictory,
        if (roundId != null) 'roundId': roundId,
      };

  factory ScoreEvent.fromMap(Map<dynamic, dynamic> map) => ScoreEvent(
        teamId: map['teamId'] as String,
        points: map['points'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        specialEvent: map['specialEvent'] != null
            ? _parseSpecialEvent(map['specialEvent'] as String)
            : null,
        note: map['note'] as String?,
        isGameVictory: map['isGameVictory'] as bool? ?? false,
        roundId: map['roundId'] as String?,
      );
}

SpecialEventType _parseSpecialEvent(String name) {
  if (name == 'chucho') return SpecialEventType.tranque;
  return SpecialEventType.values.byName(name);
}
