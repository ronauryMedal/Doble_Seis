/// Constantes globales de la app.
///
/// Centralizar valores evita "números mágicos" repartidos por el código
/// y facilita cambiar reglas (ej. límite de puntos) en un solo sitio.
class AppConstants {
  AppConstants._();

  static const String appName = 'Doble Seis';
  static const String hiveBoxName = 'domino_games';

  /// Puntajes rápidos típicos del dominó caribeño/latino.
  static const List<int> quickScores = [10, 25, 30];

  /// Límites de partida configurables.
  static const int defaultWinScore = 100;
  static const int alternateWinScore = 200;

  /// Shot clock por defecto (segundos por turno).
  static const int defaultShotClockSeconds = 60;
  static const int shotClockWarningSeconds = 10;
}
