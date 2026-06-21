/// Ficha de dominó doble seis — cada lado de 0 a 6 puntos.
class DominoTile {
  const DominoTile({required this.left, required this.right});

  final int left;
  final int right;

  int get pips => left + right;

  String get label => '$left|$right';

  @override
  bool operator ==(Object other) =>
      other is DominoTile && other.left == left && other.right == right;

  @override
  int get hashCode => Object.hash(left, right);
}

/// Utilidades para conteo de puntos en fichas restantes.
class DominoPips {
  DominoPips._();

  static const maxPip = 6;

  static int sumTiles(Iterable<DominoTile> tiles) =>
      tiles.fold(0, (sum, t) => sum + t.pips);

  static bool isValidPip(int value) => value >= 0 && value <= maxPip;
}
