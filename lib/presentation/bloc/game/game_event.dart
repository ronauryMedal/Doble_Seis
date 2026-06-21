part of 'game_bloc.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia o restaura una partida desde Hive.
final class GameStarted extends GameEvent {
  const GameStarted({this.winScore});
  final int? winScore;

  @override
  List<Object?> get props => [winScore];
}

/// Suma puntos a un equipo (desde swipe o teclado).
final class ScoreAdded extends GameEvent {
  const ScoreAdded({
    required this.teamId,
    required this.points,
    this.specialEvent,
  });

  final String teamId;
  final int points;
  final SpecialEventType? specialEvent;

  @override
  List<Object?> get props => [teamId, points, specialEvent];
}

/// Registra Capicúa o Chucho sin puntos extra (solo celebración).
final class SpecialEventMarked extends GameEvent {
  const SpecialEventMarked({
    required this.teamId,
    required this.event,
  });

  final String teamId;
  final SpecialEventType event;

  @override
  List<Object?> get props => [teamId, event];
}

final class GameReset extends GameEvent {
  const GameReset();
}

final class ShotClockToggled extends GameEvent {
  const ShotClockToggled();
}

final class ShotClockTick extends GameEvent {
  const ShotClockTick();
}

final class ShotClockReset extends GameEvent {
  const ShotClockReset();
}

final class CelebrationDismissed extends GameEvent {
  const CelebrationDismissed();
}
