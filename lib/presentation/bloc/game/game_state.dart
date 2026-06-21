part of 'game_bloc.dart';

enum CelebrationType { capicua, tranque, gameWon }

class GameState extends Equatable {
  const GameState({
    required this.session,
    this.isShotClockActive = false,
    this.shotClockSeconds = AppConstants.initialGameTimerSeconds,
    this.activeCelebration,
    this.pendingPoints,
  });

  final GameSession session;
  final bool isShotClockActive;
  final int shotClockSeconds;
  final CelebrationType? activeCelebration;
  final int? pendingPoints;

  factory GameState.initial() => GameState(
        session: GameSession.newGame(
          mode: GameMode.teamVsTeam,
          winScore: AppConstants.defaultWinScore,
          participants: const [
            ParticipantSetup(name: 'Equipo A'),
            ParticipantSetup(name: 'Equipo B'),
          ],
        ),
      );

  GameState copyWith({
    GameSession? session,
    bool? isShotClockActive,
    int? shotClockSeconds,
    CelebrationType? activeCelebration,
    bool clearCelebration = false,
    int? pendingPoints,
    bool clearPendingPoints = false,
  }) =>
      GameState(
        session: session ?? this.session,
        isShotClockActive: isShotClockActive ?? this.isShotClockActive,
        shotClockSeconds: shotClockSeconds ?? this.shotClockSeconds,
        activeCelebration:
            clearCelebration ? null : (activeCelebration ?? this.activeCelebration),
        pendingPoints:
            clearPendingPoints ? null : (pendingPoints ?? this.pendingPoints),
      );

  @override
  List<Object?> get props => [
        session,
        isShotClockActive,
        shotClockSeconds,
        activeCelebration,
        pendingPoints,
      ];
}
