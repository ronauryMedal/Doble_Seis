part of 'game_bloc.dart';

enum CelebrationType { capicua, tranque, gameWon }

class GameState extends Equatable {
  const GameState({
    required this.session,
    this.isShotClockActive = false,
    this.shotClockSeconds = AppConstants.initialGameTimerSeconds,
    this.activeCelebration,
    this.pendingPoints,
    this.pendingSpecialEvent,
    this.pendingSpecialEventTeamId,
    this.connectionMode = LiveRoomConnectionMode.offline,
    this.liveRoomInfo,
    this.liveRoomError,
  });

  final GameSession session;
  final bool isShotClockActive;
  final int shotClockSeconds;
  final CelebrationType? activeCelebration;
  final int? pendingPoints;
  final SpecialEventType? pendingSpecialEvent;
  final String? pendingSpecialEventTeamId;
  final LiveRoomConnectionMode connectionMode;
  final LiveRoomConnectionInfo? liveRoomInfo;
  final String? liveRoomError;

  bool get isSpectator => liveRoomInfo?.role == RoomRole.spectator;

  bool get isLiveHost => liveRoomInfo?.role == RoomRole.leader;

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
    SpecialEventType? pendingSpecialEvent,
    String? pendingSpecialEventTeamId,
    bool clearPendingSpecialEvent = false,
    LiveRoomConnectionMode? connectionMode,
    LiveRoomConnectionInfo? liveRoomInfo,
    bool clearLiveRoomInfo = false,
    String? liveRoomError,
    bool clearLiveRoomError = false,
  }) =>
      GameState(
        session: session ?? this.session,
        isShotClockActive: isShotClockActive ?? this.isShotClockActive,
        shotClockSeconds: shotClockSeconds ?? this.shotClockSeconds,
        activeCelebration:
            clearCelebration ? null : (activeCelebration ?? this.activeCelebration),
        pendingPoints:
            clearPendingPoints ? null : (pendingPoints ?? this.pendingPoints),
        pendingSpecialEvent: clearPendingSpecialEvent
            ? null
            : (pendingSpecialEvent ?? this.pendingSpecialEvent),
        pendingSpecialEventTeamId: clearPendingSpecialEvent
            ? null
            : (pendingSpecialEventTeamId ?? this.pendingSpecialEventTeamId),
        connectionMode: connectionMode ?? this.connectionMode,
        liveRoomInfo: clearLiveRoomInfo ? null : (liveRoomInfo ?? this.liveRoomInfo),
        liveRoomError:
            clearLiveRoomError ? null : (liveRoomError ?? this.liveRoomError),
      );

  @override
  List<Object?> get props => [
        session,
        isShotClockActive,
        shotClockSeconds,
        activeCelebration,
        pendingPoints,
        pendingSpecialEvent,
        pendingSpecialEventTeamId,
        connectionMode,
        liveRoomInfo,
        liveRoomError,
      ];
}
