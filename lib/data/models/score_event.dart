import '../../domain/enums/special_event_type.dart';

/// Registro de cada suma de puntos — útil para historial y sync futuro.
class ScoreEvent {
  const ScoreEvent({
    required this.teamId,
    required this.points,
    required this.timestamp,
    this.specialEvent,
    this.note,
  });

  final String teamId;
  final int points;
  final DateTime timestamp;
  final SpecialEventType? specialEvent;
  final String? note;

  Map<String, dynamic> toMap() => {
        'teamId': teamId,
        'points': points,
        'timestamp': timestamp.toIso8601String(),
        'specialEvent': specialEvent?.name,
        'note': note,
      };

  factory ScoreEvent.fromMap(Map<dynamic, dynamic> map) => ScoreEvent(
        teamId: map['teamId'] as String,
        points: map['points'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        specialEvent: map['specialEvent'] != null
            ? SpecialEventType.values.byName(map['specialEvent'] as String)
            : null,
        note: map['note'] as String?,
      );
}
