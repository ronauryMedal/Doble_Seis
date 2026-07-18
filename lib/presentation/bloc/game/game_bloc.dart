import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/game_history_entry.dart';
import '../../../data/models/game_session.dart';
import '../../../data/models/participant_setup.dart';
import '../../../data/models/score_event.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../domain/enums/game_mode.dart';
import '../../../domain/enums/live_room_connection_mode.dart';
import '../../../domain/enums/room_role.dart';
import '../../../domain/enums/scoring_ui_mode.dart';
import '../../../domain/enums/special_event_type.dart';
import '../../../data/models/live_room_connection_info.dart';
import '../../../features/live_room/live_room_manager.dart';

part 'game_event.dart';
part 'game_state.dart';

/// BLoC = Business Logic Component.
///
/// Separa la lógica de negocio de la UI. La pantalla solo "escucha" el estado
/// y "envía" eventos; no calcula puntajes ni persiste datos.
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required GameRepository repository,
    LiveRoomManager? liveRoomManager,
  })  : _repository = repository,
        _liveRoom = liveRoomManager ?? LiveRoomManager(),
        super(GameState.initial()) {
    on<GameStarted>(_onStarted);
    on<GameConfigured>(_onConfigured);
    on<GameRestored>(_onRestored);
    on<LiveRoomSpectatorStarted>(_onLiveRoomSpectatorStarted);
    on<LiveRoomSessionSynced>(_onLiveRoomSessionSynced);
    on<LiveRoomConnectionLost>(_onLiveRoomConnectionLost);
    on<ScoreAdded>(_onScoreAdded);
    on<ScoreEventRemoved>(_onScoreEventRemoved);
    on<RoundAdded>(_onRoundAdded);
    on<RoundRemoved>(_onRoundRemoved);
    on<SpecialEventMarked>(_onSpecialEventMarked);
    on<GameReset>(_onReset);
    on<GameRematch>(_onRematch);
    on<ShotClockToggled>(_onShotClockToggled);
    on<ShotClockTick>(_onShotClockTick);
    on<ShotClockReset>(_onShotClockReset);
    on<CelebrationDismissed>(_onCelebrationDismissed);
  }

  final GameRepository _repository;
  final LiveRoomManager _liveRoom;
  Timer? _shotClockTimer;
  StreamSubscription<GameSession>? _liveRoomSubscription;
  StreamSubscription<String>? _liveRoomClosedSubscription;

  /// Acceso al gestor de sala (p. ej. para que el espectador vuelva a unirse).
  LiveRoomManager get liveRoomManager => _liveRoom;

  Future<void> _onStarted(GameStarted event, Emitter<GameState> emit) async {
    final saved = _repository.loadCurrentSession();
    if (saved != null) {
      final elapsed = _elapsedFromSession(saved);
      emit(state.copyWith(
        session: saved,
        shotClockSeconds: elapsed,
        isShotClockActive: true,
      ));
      _startGameTimer();
      return;
    }
    final session = GameSession.newGame(
      mode: GameMode.teamVsTeam,
      winScore: event.winScore ?? AppConstants.defaultWinScore,
      participants: const [
        ParticipantSetup(name: 'Equipo A'),
        ParticipantSetup(name: 'Equipo B'),
      ],
    );
    await _repository.saveSession(session);
    emit(state.copyWith(session: session));
    _autoStartGameTimer(emit, elapsedSeconds: 0);
  }

  Future<void> _onConfigured(
    GameConfigured event,
    Emitter<GameState> emit,
  ) async {
    _stopGameTimer();
    await _repository.clearCurrent();

    final session = GameSession.newGame(
      mode: event.mode,
      winScore: event.winScore,
      participants: event.participants,
      scoringUiMode: event.scoringUiMode,
    );

    await _repository.saveSession(session);
    emit(GameState(session: session));
    _autoStartGameTimer(emit, elapsedSeconds: 0);

    LiveRoomConnectionInfo? roomInfo;
    String? roomError;
    if (event.connectionMode != LiveRoomConnectionMode.offline) {
      try {
        final service = _liveRoom.serviceFor(event.connectionMode);
        roomInfo = await service.createRoom(initialSession: session);
      } on Exception catch (e) {
        roomError = e.toString();
      }
    }

    emit(state.copyWith(
      connectionMode: roomInfo != null
          ? event.connectionMode
          : LiveRoomConnectionMode.offline,
      liveRoomInfo: roomInfo,
      liveRoomError: roomError,
    ));
  }

  Future<void> _onLiveRoomSpectatorStarted(
    LiveRoomSpectatorStarted event,
    Emitter<GameState> emit,
  ) async {
    _liveRoomSubscription?.cancel();
    _liveRoomClosedSubscription?.cancel();
    await _repository.saveSession(event.session);

    final elapsed = _elapsedFromSession(event.session);
    emit(GameState(
      session: event.session,
      connectionMode: event.info.mode,
      liveRoomInfo: event.info,
      shotClockSeconds: elapsed,
      isShotClockActive: true,
      liveRoomRequiresRejoin: false,
    ));
    _startGameTimer();

    final service = _liveRoom.activeService;
    _liveRoomSubscription = service?.watchSession().listen((session) {
      add(LiveRoomSessionSynced(session));
    });
    _liveRoomClosedSubscription = service?.watchRoomClosed().listen((reason) {
      add(LiveRoomConnectionLost(reason));
    });
  }

  Future<void> _onLiveRoomSessionSynced(
    LiveRoomSessionSynced event,
    Emitter<GameState> emit,
  ) async {
    if (!state.isSpectator) return;
    await _repository.saveSession(event.session);

    // Anfitrión terminó la partida → celebración.
    final justEnded = !state.session.isGameOver && event.session.isGameOver;
    if (justEnded) {
      await HapticUtils.celebration();
      emit(state.copyWith(
        session: event.session,
        activeCelebration: CelebrationType.gameWon,
      ));
      return;
    }

    // Anfitrión dio revancha → misma sala, nueva partida; quitar overlay.
    final rematchStarted = state.session.isGameOver && !event.session.isGameOver;
    final newSessionId = state.session.id != event.session.id;
    if (rematchStarted || (newSessionId && !event.session.isGameOver)) {
      emit(state.copyWith(
        session: event.session,
        clearCelebration: true,
        liveRoomRequiresRejoin: false,
        clearLiveRoomError: true,
      ));
      return;
    }

    emit(state.copyWith(session: event.session));
  }

  Future<void> _onLiveRoomConnectionLost(
    LiveRoomConnectionLost event,
    Emitter<GameState> emit,
  ) async {
    if (!state.isSpectator && !state.isLiveHost) return;

    _liveRoomSubscription?.cancel();
    _liveRoomClosedSubscription?.cancel();
    _liveRoomSubscription = null;
    _liveRoomClosedSubscription = null;

    // El cliente ya perdió el socket; limpia el manager sin reavisar.
    await _liveRoom.disconnect();

    emit(state.copyWith(
      clearLiveRoomInfo: true,
      connectionMode: LiveRoomConnectionMode.offline,
      liveRoomError: event.reason,
      liveRoomRequiresRejoin: true,
      clearCelebration: true,
    ));
  }

  Future<void> _onRestored(
    GameRestored event,
    Emitter<GameState> emit,
  ) async {
    final saved = _repository.loadCurrentSession();
    if (saved == null) return;
    final elapsed = _elapsedFromSession(saved);
    emit(GameState(
      session: saved,
      shotClockSeconds: elapsed,
      isShotClockActive: true,
    ));
    _startGameTimer();
  }

  Future<void> _onScoreAdded(ScoreAdded event, Emitter<GameState> emit) async {
    if (event.points <= 0) return;

    final session = state.session;
    final now = DateTime.now();

    var specialEvent = event.specialEvent;
    final usedPending = specialEvent == null &&
        state.pendingSpecialEvent != null &&
        state.pendingSpecialEventTeamId == event.teamId;
    if (usedPending) {
      specialEvent = state.pendingSpecialEvent;
    }

    final updated = _applyScore(session, event.teamId, event.points);
    final gameOver = updated.isGameOver;

    final scoreEvent = ScoreEvent(
      teamId: event.teamId,
      points: event.points,
      timestamp: now,
      specialEvent: specialEvent,
      isGameVictory: gameOver,
    );

    final newSession = updated.copyWith(
      events: [...session.events, scoreEvent],
    );

    if (gameOver) {
      await _saveToHistory(newSession);
    }

    await _repository.saveSession(newSession);
    await HapticUtils.mediumTap();

    CelebrationType? celebration;
    if (specialEvent == SpecialEventType.capicua) {
      celebration = CelebrationType.capicua;
      await HapticUtils.celebration();
    } else if (specialEvent == SpecialEventType.tranque) {
      celebration = CelebrationType.tranque;
      await HapticUtils.celebration();
    } else if (gameOver) {
      celebration = CelebrationType.gameWon;
      await HapticUtils.celebration();
    }

    final isLiveHost = state.isLiveHost;

    emit(state.copyWith(
      session: newSession,
      activeCelebration: celebration,
      clearCelebration: celebration == null,
      clearPendingPoints: true,
      clearPendingSpecialEvent: usedPending,
    ));

    if (isLiveHost && _liveRoom.activeService != null) {
      try {
        await _liveRoom.activeService!.pushScoreUpdate(
          session: newSession,
          role: RoomRole.leader,
        );
      } on Exception {
        // La partida local sigue; solo falla el broadcast WiFi.
      }
    }
  }

  Future<void> _onScoreEventRemoved(
    ScoreEventRemoved event,
    Emitter<GameState> emit,
  ) async {
    if (state.isSpectator) return;

    final session = state.session;
    if (event.eventIndex < 0 || event.eventIndex >= session.events.length) {
      return;
    }

    final remaining = [...session.events]..removeAt(event.eventIndex);

    final recomputed = session.participants.map((player) {
      final total = remaining
          .where((e) => e.teamId == player.id)
          .fold(0, (sum, e) => sum + e.points);
      return player.copyWith(score: total);
    }).toList();

    final newSession = session.copyWith(
      participants: recomputed,
      events: remaining,
    );

    await _repository.saveSession(newSession);
    await HapticUtils.lightTap();

    emit(state.copyWith(
      session: newSession,
      clearCelebration: true,
    ));

    if (state.isLiveHost && _liveRoom.activeService != null) {
      try {
        await _liveRoom.activeService!.pushScoreUpdate(
          session: newSession,
          role: RoomRole.leader,
        );
      } on Exception {
        // La partida local sigue; solo falla el broadcast WiFi.
      }
    }
  }

  Future<void> _onRoundAdded(
    RoundAdded event,
    Emitter<GameState> emit,
  ) async {
    if (state.isSpectator) return;
    if (event.pointsByTeamId.isEmpty) return;
    if (event.pointsByTeamId.values.every((p) => p <= 0)) return;

    final session = state.session;
    final now = DateTime.now();
    final roundId = now.microsecondsSinceEpoch.toString();

    var updated = session;
    final newEvents = <ScoreEvent>[];

    for (final entry in event.pointsByTeamId.entries) {
      final points = entry.value < 0 ? 0 : entry.value;
      if (!session.participants.any((p) => p.id == entry.key)) continue;
      if (points > 0) {
        updated = _applyScore(updated, entry.key, points);
      }
      newEvents.add(ScoreEvent(
        teamId: entry.key,
        points: points,
        timestamp: now,
        roundId: roundId,
      ));
    }

    if (newEvents.isEmpty) return;

    final gameOver = updated.isGameOver;
    if (gameOver) {
      // Marca victoria en el último evento de la ronda.
      final last = newEvents.last;
      newEvents[newEvents.length - 1] = ScoreEvent(
        teamId: last.teamId,
        points: last.points,
        timestamp: last.timestamp,
        roundId: last.roundId,
        isGameVictory: true,
      );
    }

    final newSession = updated.copyWith(
      events: [...session.events, ...newEvents],
    );

    if (gameOver) {
      await _saveToHistory(newSession);
    }

    await _repository.saveSession(newSession);
    await HapticUtils.mediumTap();

    CelebrationType? celebration;
    if (gameOver) {
      celebration = CelebrationType.gameWon;
      await HapticUtils.celebration();
    }

    emit(state.copyWith(
      session: newSession,
      activeCelebration: celebration,
      clearCelebration: celebration == null,
    ));
  }

  Future<void> _onRoundRemoved(
    RoundRemoved event,
    Emitter<GameState> emit,
  ) async {
    if (state.isSpectator) return;

    final session = state.session;
    final remaining =
        session.events.where((e) => e.roundId != event.roundId).toList();
    if (remaining.length == session.events.length) return;

    final recomputed = session.participants.map((player) {
      final total = remaining
          .where((e) => e.teamId == player.id)
          .fold(0, (sum, e) => sum + e.points);
      return player.copyWith(score: total);
    }).toList();

    final newSession = session.copyWith(
      participants: recomputed,
      events: remaining,
    );

    await _repository.saveSession(newSession);
    await HapticUtils.lightTap();

    emit(state.copyWith(
      session: newSession,
      clearCelebration: true,
    ));
  }

  Future<void> _saveToHistory(GameSession session) async {
    final winner = session.winner;
    if (winner == null) return;

    final entry = GameHistoryEntry(
      id: '${session.id}_won_${DateTime.now().millisecondsSinceEpoch}',
      finishedAt: DateTime.now(),
      winnerName: winner.name,
      winnerId: winner.id,
      winScore: session.winScore,
      mode: session.mode,
      events: session.events,
      finalScores: session.participants,
      durationSeconds: state.shotClockSeconds,
    );
    await _repository.saveHistoryEntry(entry);
  }

  Future<void> _onSpecialEventMarked(
    SpecialEventMarked event,
    Emitter<GameState> emit,
  ) async {
    await HapticUtils.selection();

    final samePending = state.pendingSpecialEvent == event.event &&
        state.pendingSpecialEventTeamId == event.teamId;

    if (samePending) {
      emit(state.copyWith(clearPendingSpecialEvent: true));
      return;
    }

    emit(state.copyWith(
      pendingSpecialEvent: event.event,
      pendingSpecialEventTeamId: event.teamId,
    ));
  }

  GameSession _applyScore(GameSession session, String playerId, int points) {
    final updated = session.participants.map((player) {
      if (player.id == playerId) {
        return player.copyWith(score: player.score + points);
      }
      return player;
    }).toList();
    return session.copyWith(participants: updated);
  }

  Future<void> _onReset(GameReset event, Emitter<GameState> emit) async {
    _stopGameTimer();
    _liveRoomSubscription?.cancel();
    _liveRoomClosedSubscription?.cancel();
    _liveRoomSubscription = null;
    _liveRoomClosedSubscription = null;
    await _liveRoom.disconnect();
    await _repository.clearCurrent();
    emit(GameState.initial());
  }

  Future<void> _onRematch(GameRematch event, Emitter<GameState> emit) async {
    _stopGameTimer();

    final rematch = GameSession.rematchFrom(state.session);
    final isLiveHost = state.isLiveHost;

    await _repository.saveSession(rematch);

    emit(state.copyWith(
      session: rematch,
      clearCelebration: true,
      clearPendingSpecialEvent: true,
      shotClockSeconds: AppConstants.initialGameTimerSeconds,
      isShotClockActive: true,
    ));
    _startGameTimer();

    if (isLiveHost && _liveRoom.activeService != null) {
      try {
        await _liveRoom.activeService!.pushScoreUpdate(
          session: rematch,
          role: RoomRole.leader,
        );
      } on Exception {
        // La revancha local sigue aunque falle el broadcast WiFi.
      }
    }
  }

  void _onShotClockToggled(
    ShotClockToggled event,
    Emitter<GameState> emit,
  ) {
    final active = !state.isShotClockActive;
    if (active) {
      _startGameTimer();
    } else {
      _stopGameTimer();
    }
    emit(state.copyWith(isShotClockActive: active));
  }

  void _onShotClockTick(ShotClockTick event, Emitter<GameState> emit) {
    emit(state.copyWith(shotClockSeconds: state.shotClockSeconds + 1));
  }

  void _onShotClockReset(ShotClockReset event, Emitter<GameState> emit) {
    emit(state.copyWith(
      shotClockSeconds: AppConstants.initialGameTimerSeconds,
    ));
  }

  void _onCelebrationDismissed(
    CelebrationDismissed event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(clearCelebration: true));
  }

  void _autoStartGameTimer(Emitter<GameState> emit, {required int elapsedSeconds}) {
    emit(state.copyWith(
      isShotClockActive: true,
      shotClockSeconds: elapsedSeconds,
    ));
    _startGameTimer();
  }

  int _elapsedFromSession(GameSession session) {
    final created = session.createdAt;
    if (created == null) return 0;
    return DateTime.now().difference(created).inSeconds;
  }

  void _startGameTimer() {
    _shotClockTimer?.cancel();
    _shotClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const ShotClockTick());
    });
  }

  void _stopGameTimer() {
    _shotClockTimer?.cancel();
    _shotClockTimer = null;
  }

  @override
  Future<void> close() {
    _stopGameTimer();
    _liveRoomSubscription?.cancel();
    _liveRoom.disconnect();
    return super.close();
  }
}
