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
    this.connectionMode = LiveRoomConnectionMode.offline,
    this.scoringUiMode = ScoringUiMode.full,
  });

  final int winScore;
  final GameMode mode;
  final List<ParticipantSetup> participants;
  final LiveRoomConnectionMode connectionMode;
  final ScoringUiMode scoringUiMode;

  @override
  List<Object?> get props =>
      [winScore, mode, participants, connectionMode, scoringUiMode];
}

/// Espectador conectado a una sala WiFi / nube.
final class LiveRoomSpectatorStarted extends GameEvent {
  const LiveRoomSpectatorStarted({
    required this.session,
    required this.info,
  });

  final GameSession session;
  final LiveRoomConnectionInfo info;

  @override
  List<Object?> get props => [session, info];
}

/// Actualización remota recibida por el espectador.
final class LiveRoomSessionSynced extends GameEvent {
  const LiveRoomSessionSynced(this.session);

  final GameSession session;

  @override
  List<Object?> get props => [session];
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

/// Elimina una anotación de la bitácora (corrige un error) y recalcula puntaje.
final class ScoreEventRemoved extends GameEvent {
  const ScoreEventRemoved(this.eventIndex);

  /// Índice en el orden cronológico de `session.events`.
  final int eventIndex;

  @override
  List<Object?> get props => [eventIndex];
}

/// Modo Fácil: suma una ronda completa (puntos de ambos equipos).
final class RoundAdded extends GameEvent {
  const RoundAdded({
    required this.pointsByTeamId,
  });

  /// Mapa teamId → puntos de la ronda (puede incluir 0).
  final Map<String, int> pointsByTeamId;

  @override
  List<Object?> get props => [pointsByTeamId];
}

/// Modo Fácil: elimina una ronda completa por su [roundId].
final class RoundRemoved extends GameEvent {
  const RoundRemoved(this.roundId);

  final String roundId;

  @override
  List<Object?> get props => [roundId];
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

/// Revancha con los mismos jugadores — reinicia puntajes.
final class GameRematch extends GameEvent {
  const GameRematch();
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
