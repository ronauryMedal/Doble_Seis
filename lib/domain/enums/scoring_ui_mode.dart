/// Estilo de UI del marcador — independiente del modo Equipo/Individual.
enum ScoringUiMode {
  /// Solo nombres + anotar por rondas (estilo simple).
  easy('Fácil'),

  /// Marcador completo: teclado, eventos, WiFi, bitácora, etc.
  full('Completo');

  const ScoringUiMode(this.label);
  final String label;
}
