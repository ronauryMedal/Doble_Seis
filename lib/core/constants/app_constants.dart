/// Constantes globales de la app.
///
/// Centralizar valores evita "números mágicos" repartidos por el código
/// y facilita cambiar reglas (ej. límite de puntos) en un solo sitio.
class AppConstants {
  AppConstants._();

  static const String appName = 'Doble Seis';
  static const String appSlogan = 'Anota, guarda y comparte tus partidas';
  static const String appVersion = '1.0.0';
  static const String hiveBoxName = 'domino_games';
  static const String hiveHistoryIndexKey = 'game_history_index';
  static const String hiveOnboardingCompleteKey = 'onboarding_complete';

  /// Puntaje rápido del dominó (botón destacado en el teclado).
  static const int quickScore = 30;
  static const List<int> quickScores = [quickScore];

  /// Opciones de puntaje para ganar la partida.
  static const List<int> winScoreOptions = [100, 150, 200];

  static const int minPlayersPerTeam = 1;
  static const int maxPlayersPerTeam = 2;
  static const int defaultPlayersPerTeam = 2;

  static const String defaultTeamAName = 'Equipo A';
  static const String defaultTeamBName = 'Equipo B';

  static const int minIndividualPlayers = 2;
  static const int maxIndividualPlayers = 6;
  static const int defaultIndividualPlayers = 4;

  static const int minWinScore = 50;
  static const int maxWinScore = 500;
  static const int defaultWinScore = 100;

  /// Duración inicial del cronómetro de partida (cuenta hacia arriba).
  static const int initialGameTimerSeconds = 0;

  /// Sala WiFi local.
  static const int liveRoomPort = 8765;
  static const int liveRoomCodeLength = 6;
  static const Duration liveRoomConnectTimeout = Duration(seconds: 12);

  /// Escaneo IA de fichas con cámara (desactivado hasta terminar desarrollo).
  static const bool dominoVisionScanEnabled = false;
}
