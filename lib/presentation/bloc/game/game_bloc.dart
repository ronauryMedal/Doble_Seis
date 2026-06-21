import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/game_session.dart';
import '../../../data/models/score_event.dart';
import '../../../data/repositories/game_repository.dart';
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
      emit(state.copyWith(session: saved));
      return;
    }
    final session = GameSession.newGame(
      winScore: event.winScore ?? AppConstants.defaultWinScore,
    );
    await _repository.saveSession(session);
    emit(state.copyWith(session: session));
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
    } else if (event.specialEvent == SpecialEventType.chucho) {
      celebration = CelebrationType.chucho;
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

    if (state.isShotClockActive) {
      add(const ShotClockReset());
    }
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

  GameSession _applyScore(GameSession session, String teamId, int points) {
    if (teamId == 'A') {
      return session.copyWith(
        teamA: session.teamA.copyWith(score: session.teamA.score + points),
      );
    }
    return session.copyWith(
      teamB: session.teamB.copyWith(score: session.teamB.score + points),
    );
  }

  Future<void> _onReset(GameReset event, Emitter<GameState> emit) async {
    _shotClockTimer?.cancel();
    await _repository.clearCurrent();
    final session = GameSession.newGame(winScore: state.session.winScore);
    await _repository.saveSession(session);
    emit(GameState(
      session: session,
      shotClockSeconds: AppConstants.defaultShotClockSeconds,
    ));
  }

  void _onShotClockToggled(
    ShotClockToggled event,
    Emitter<GameState> emit,
  ) {
    final active = !state.isShotClockActive;
    if (active) {
      _startShotClock(emit);
    } else {
      _shotClockTimer?.cancel();
    }
    emit(state.copyWith(
      isShotClockActive: active,
      shotClockSeconds: AppConstants.defaultShotClockSeconds,
    ));
  }

  void _onShotClockTick(ShotClockTick event, Emitter<GameState> emit) {
    final remaining = state.shotClockSeconds - 1;
    if (remaining <= 0) {
      HapticUtils.warning();
      emit(state.copyWith(shotClockSeconds: 0));
      return;
    }
    if (remaining <= AppConstants.shotClockWarningSeconds) {
      HapticUtils.lightTap();
    }
    emit(state.copyWith(shotClockSeconds: remaining));
  }

  void _onShotClockReset(ShotClockReset event, Emitter<GameState> emit) {
    emit(state.copyWith(
      shotClockSeconds: AppConstants.defaultShotClockSeconds,
    ));
  }

  void _onCelebrationDismissed(
    CelebrationDismissed event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(clearCelebration: true));
  }

  void _startShotClock(Emitter<GameState> emit) {
    _shotClockTimer?.cancel();
    _shotClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const ShotClockTick());
    });
  }

  @override
  Future<void> close() {
    _shotClockTimer?.cancel();
    return super.close();
  }
}
