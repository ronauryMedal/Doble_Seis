import '../../domain/enums/game_mode.dart';
import 'participant_setup.dart';
import 'score_event.dart';

/// Jugador o equipo en la partida (comparten el mismo modelo de puntaje).
class PlayerScore {
  const PlayerScore({
    required this.id,
    required this.name,
    this.score = 0,
    this.memberNames = const [],
  });

  final String id;
  final String name;
  final int score;
  /// Jugadores del equipo (modo 2v2). Vacío en modo individual.
  final List<String> memberNames;

  PlayerScore copyWith({
    String? id,
    String? name,
    int? score,
    List<String>? memberNames,
  }) =>
      PlayerScore(
        id: id ?? this.id,
        name: name ?? this.name,
        score: score ?? this.score,
        memberNames: memberNames ?? this.memberNames,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'score': score,
        'memberNames': memberNames,
      };

  factory PlayerScore.fromMap(Map<dynamic, dynamic> map) => PlayerScore(
        id: map['id'] as String,
        name: map['name'] as String,
        score: map['score'] as int? ?? 0,
        memberNames: List<String>.from(map['memberNames'] as List? ?? []),
      );
}

/// Sesión completa de juego — lo que persistimos en Hive.
class GameSession {
  const GameSession({
    required this.id,
    required this.mode,
    required this.participants,
    required this.winScore,
    this.events = const [],
    this.createdAt,
  });

  final String id;
  final GameMode mode;
  final List<PlayerScore> participants;
  final int winScore;
  final List<ScoreEvent> events;
  final DateTime? createdAt;

  bool get isGameOver =>
      participants.any((player) => player.score >= winScore);

  PlayerScore? get winner {
    final candidates =
        participants.where((p) => p.score >= winScore).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first;
  }

  int get highestScore => participants.isEmpty
      ? 0
      : participants.map((p) => p.score).reduce((a, b) => a > b ? a : b);

  GameSession copyWith({
    String? id,
    GameMode? mode,
    List<PlayerScore>? participants,
    int? winScore,
    List<ScoreEvent>? events,
    DateTime? createdAt,
  }) =>
      GameSession(
        id: id ?? this.id,
        mode: mode ?? this.mode,
        participants: participants ?? this.participants,
        winScore: winScore ?? this.winScore,
        events: events ?? this.events,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'mode': mode.name,
        'participants': participants.map((p) => p.toMap()).toList(),
        'winScore': winScore,
        'events': events.map((e) => e.toMap()).toList(),
        'createdAt': createdAt?.toIso8601String(),
      };

  factory GameSession.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('participants')) {
      return GameSession(
        id: map['id'] as String,
        mode: GameMode.values.byName(map['mode'] as String? ?? 'teamVsTeam'),
        participants: (map['participants'] as List)
            .map((p) => PlayerScore.fromMap(Map<dynamic, dynamic>.from(p as Map)))
            .toList(),
        winScore: map['winScore'] as int,
        events: (map['events'] as List? ?? [])
            .map((e) => ScoreEvent.fromMap(Map<dynamic, dynamic>.from(e as Map)))
            .toList(),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
      );
    }

    // Compatibilidad con partidas guardadas en formato anterior.
    return GameSession(
      id: map['id'] as String,
      mode: GameMode.teamVsTeam,
      participants: [
        PlayerScore.fromMap(Map<dynamic, dynamic>.from(map['teamA'] as Map)),
        PlayerScore.fromMap(Map<dynamic, dynamic>.from(map['teamB'] as Map)),
      ],
      winScore: map['winScore'] as int,
      events: (map['events'] as List? ?? [])
          .map((e) => ScoreEvent.fromMap(Map<dynamic, dynamic>.from(e as Map)))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  factory GameSession.newGame({
    required GameMode mode,
    required int winScore,
    required List<ParticipantSetup> participants,
  }) {
    final now = DateTime.now();
    final players = participants.asMap().entries.map((entry) {
      final index = entry.key;
      final setup = entry.value;
      final name = setup.name.trim().isEmpty
          ? _defaultName(mode, index)
          : setup.name.trim();
      final members = setup.memberNames
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty)
          .toList();
      return PlayerScore(
        id: index.toString(),
        name: name,
        memberNames: members,
      );
    }).toList();

    return GameSession(
      id: now.millisecondsSinceEpoch.toString(),
      mode: mode,
      participants: players,
      winScore: winScore,
      createdAt: now,
    );
  }

  /// Revancha: mismos jugadores y reglas, puntajes en cero.
  factory GameSession.rematchFrom(GameSession previous) {
    final now = DateTime.now();
    return GameSession(
      id: now.millisecondsSinceEpoch.toString(),
      mode: previous.mode,
      winScore: previous.winScore,
      createdAt: now,
      events: const [],
      participants: previous.participants
          .map((p) => p.copyWith(score: 0))
          .toList(growable: false),
    );
  }

  static String _defaultName(GameMode mode, int index) {
    if (mode == GameMode.teamVsTeam) {
      return index == 0
          ? 'Equipo A'
          : 'Equipo B';
    }
    return 'Jugador ${index + 1}';
  }
}
