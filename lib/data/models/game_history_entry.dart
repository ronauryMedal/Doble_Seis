import '../../domain/enums/game_mode.dart';
import 'game_session.dart';
import 'score_event.dart';

/// Partida terminada guardada en el historial.
class GameHistoryEntry {
  const GameHistoryEntry({
    required this.id,
    required this.finishedAt,
    required this.winnerName,
    required this.winnerId,
    required this.winScore,
    required this.mode,
    required this.events,
    required this.finalScores,
    required this.durationSeconds,
  });

  final String id;
  final DateTime finishedAt;
  final String winnerName;
  final String winnerId;
  final int winScore;
  final GameMode mode;
  final List<ScoreEvent> events;
  final List<PlayerScore> finalScores;
  final int durationSeconds;

  Map<String, dynamic> toMap() => {
        'id': id,
        'finishedAt': finishedAt.toIso8601String(),
        'winnerName': winnerName,
        'winnerId': winnerId,
        'winScore': winScore,
        'mode': mode.name,
        'events': events.map((e) => e.toMap()).toList(),
        'finalScores': finalScores.map((p) => p.toMap()).toList(),
        'durationSeconds': durationSeconds,
      };

  factory GameHistoryEntry.fromMap(Map<dynamic, dynamic> map) =>
      GameHistoryEntry(
        id: map['id'] as String,
        finishedAt: DateTime.parse(map['finishedAt'] as String),
        winnerName: map['winnerName'] as String,
        winnerId: map['winnerId'] as String,
        winScore: map['winScore'] as int,
        mode: GameMode.values.byName(map['mode'] as String? ?? 'teamVsTeam'),
        events: (map['events'] as List? ?? [])
            .map((e) => ScoreEvent.fromMap(Map<dynamic, dynamic>.from(e as Map)))
            .toList(),
        finalScores: (map['finalScores'] as List? ?? [])
            .map((p) => PlayerScore.fromMap(Map<dynamic, dynamic>.from(p as Map)))
            .toList(),
        durationSeconds: map['durationSeconds'] as int? ?? 0,
      );
}
