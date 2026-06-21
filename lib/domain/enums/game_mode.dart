/// Modo de juego configurado en la pantalla inicial.
enum GameMode {
  teamVsTeam('Equipo vs Equipo'),
  individual('Individual');

  const GameMode(this.label);
  final String label;
}
