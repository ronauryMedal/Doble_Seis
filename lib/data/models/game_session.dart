import 'score_event.dart';

/// Estado de un equipo en la partida.
class TeamScore {
  const TeamScore({
    required this.id,
    required this.name,
    this.score = 0,
  });

  final String id;
  final String name;
  final int score;

  TeamScore copyWith({String? id, String? name, int? score}) => TeamScore(
        id: id ?? this.id,
        name: name ?? this.name,
        score: score ?? this.score,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'score': score,
      };

  factory TeamScore.fromMap(Map<dynamic, dynamic> map) => TeamScore(
        id: map['id'] as String,
        name: map['name'] as String,
        score: map['score'] as int? ?? 0,
      );
}

/// Sesión completa de juego — lo que persistimos en Hive.
class GameSession {
  const GameSession({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.winScore,
    this.events = const [],
    this.createdAt,
  });

  final String id;
  final TeamScore teamA;
  final TeamScore teamB;
  final int winScore;
  final List<ScoreEvent> events;
  final DateTime? createdAt;

  bool get isGameOver =>
      teamA.score >= winScore || teamB.score >= winScore;

  TeamScore? get winner {
    if (teamA.score >= winScore) return teamA;
    if (teamB.score >= winScore) return teamB;
    return null;
  }

  GameSession copyWith({
    String? id,
    TeamScore? teamA,
    TeamScore? teamB,
    int? winScore,
    List<ScoreEvent>? events,
    DateTime? createdAt,
  }) =>
      GameSession(
        id: id ?? this.id,
        teamA: teamA ?? this.teamA,
        teamB: teamB ?? this.teamB,
        winScore: winScore ?? this.winScore,
        events: events ?? this.events,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'teamA': teamA.toMap(),
        'teamB': teamB.toMap(),
        'winScore': winScore,
        'events': events.map((e) => e.toMap()).toList(),
        'createdAt': createdAt?.toIso8601String(),
      };

  factory GameSession.fromMap(Map<dynamic, dynamic> map) => GameSession(
        id: map['id'] as String,
        teamA: TeamScore.fromMap(Map<dynamic, dynamic>.from(map['teamA'] as Map)),
        teamB: TeamScore.fromMap(Map<dynamic, dynamic>.from(map['teamB'] as Map)),
        winScore: map['winScore'] as int,
        events: (map['events'] as List? ?? [])
            .map((e) => ScoreEvent.fromMap(Map<dynamic, dynamic>.from(e as Map)))
            .toList(),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
      );

  factory GameSession.newGame({int winScore = 100}) {
    final now = DateTime.now();
    return GameSession(
      id: now.millisecondsSinceEpoch.toString(),
      teamA: const TeamScore(id: 'A', name: 'Equipo A'),
      teamB: const TeamScore(id: 'B', name: 'Equipo B'),
      winScore: winScore,
      createdAt: now,
    );
  }
}
