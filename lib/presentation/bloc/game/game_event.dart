part of 'game_bloc.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia o restaura una partida desde Hive (legacy — usar GameRestored).
final class GameStarted extends GameEvent {
  const GameStarted({this.winScore});
  final int? winScore;

  @override
  List<Object?> get props => [winScore];
}

/// Nueva partida con configuración elegida en la pantalla Home.
final class GameConfigured extends GameEvent {
  const GameConfigured({
    required this.winScore,
    required this.mode,
    required this.participants,
  });

  final int winScore;
  final GameMode mode;
  final List<ParticipantSetup> participants;

  @override
  List<Object?> get props => [winScore, mode, participants];
}

/// Continúa la partida guardada en Hive.
final class GameRestored extends GameEvent {
  const GameRestored();
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

/// Registra Capicúa o Tranque sin puntos extra (solo celebración).
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
