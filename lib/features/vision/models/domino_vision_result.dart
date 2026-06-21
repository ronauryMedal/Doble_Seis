import '../../../core/utils/domino_pips.dart';

enum VisionAnalysisSource { gemini, local }

/// Resultado del análisis de una foto de fichas.
class DominoVisionResult {
  const DominoVisionResult({
    required this.tiles,
    required this.source,
    this.message,
    this.confidence = 1.0,
  });

  final List<DominoTile> tiles;
  final VisionAnalysisSource source;
  final String? message;
  final double confidence;

  int get total => DominoPips.sumTiles(tiles);

  bool get isEmpty => tiles.isEmpty;

  DominoVisionResult copyWith({
    List<DominoTile>? tiles,
    VisionAnalysisSource? source,
    String? message,
    double? confidence,
  }) {
    return DominoVisionResult(
      tiles: tiles ?? this.tiles,
      source: source ?? this.source,
      message: message ?? this.message,
      confidence: confidence ?? this.confidence,
    );
  }
}
