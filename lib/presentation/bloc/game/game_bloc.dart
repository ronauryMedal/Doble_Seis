import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/game_session.dart';
import '../../../data/models/participant_setup.dart';
import '../../../data/models/score_event.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../domain/enums/game_mode.dart';
import '../../../domain/enums/special_event_type.dart';

part 'game_event.dart';
part 'game_state.dart';

/// BLoC = Business Logic Component.
///
/// Separa la lógica de negocio de la UI. La pantalla solo "escucha" el estado
/// y "envía" eventos; no calcula puntajes ni persiste datos.
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({required GameRepository repository})
      : _repository = repository,
        super(GameState.initial()) {
    on<GameStarted>(_onStarted);
    on<GameConfigured>(_onConfigured);
    on<GameRestored>(_onRestored);
    on<ScoreAdded>(_onScoreAdded);
    on<SpecialEventMarked>(_onSpecialEventMarked);
    on<GameReset>(_onReset);
    on<ShotClockToggled>(_onShotClockToggled);
    on<ShotClockTick>(_onShotClockTick);
    on<ShotClockReset>(_onShotClockReset);
    on<CelebrationDismissed>(_onCelebrationDismissed);
  }

  final GameRepository _repository;
  Timer? _shotClockTimer;

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
    );

    await _repository.saveSession(session);
    emit(GameState(session: session));
    _autoStartGameTimer(emit, elapsedSeconds: 0);
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
    final session = state.session;
    final now = DateTime.now();
    final scoreEvent = ScoreEvent(
      teamId: event.teamId,
      points: event.points,
      timestamp: now,
      specialEvent: event.specialEvent,
    );

    final updated = _applyScore(session, event.teamId, event.points);
    final newSession = updated.copyWith(
      events: [...session.events, scoreEvent],
    );

    await _repository.saveSession(newSession);
    await HapticUtils.mediumTap();

    CelebrationType? celebration;
    if (event.specialEvent == SpecialEventType.capicua) {
      celebration = CelebrationType.capicua;
      await HapticUtils.celebration();
    } else if (event.specialEvent == SpecialEventType.tranque) {
      celebration = CelebrationType.tranque;
      await HapticUtils.celebration();
    } else if (newSession.isGameOver) {
      celebration = CelebrationType.gameWon;
      await HapticUtils.celebration();
    }

    emit(state.copyWith(
      session: newSession,
      activeCelebration: celebration,
      clearCelebration: celebration == null,
      clearPendingPoints: true,
    ));
  }

  Future<void> _onSpecialEventMarked(
    SpecialEventMarked event,
    Emitter<GameState> emit,
  ) async {
    add(ScoreAdded(
      teamId: event.teamId,
      points: 0,
      specialEvent: event.event,
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
    await _repository.clearCurrent();
    emit(GameState.initial());
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
    return super.close();
  }
}
