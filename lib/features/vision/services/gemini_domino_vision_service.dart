import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/utils/domino_pips.dart';
import '../models/domino_vision_result.dart';

/// Reconoce fichas de dominó doble seis con Gemini Vision.
class GeminiDominoVisionService {
  GeminiDominoVisionService({required this.apiKey});

  final String apiKey;

  static const _prompt = '''
Analiza esta foto de fichas de dominó doble seis (cada lado de 0 a 6 puntos).
Identifica TODAS las fichas visibles y completas.
Para cada ficha devuelve los puntos del lado izquierdo y derecho según la orientación en la foto.

Responde SOLO con un JSON válido, sin markdown ni texto extra:
{"tiles":[{"left":3,"right":5}],"confidence":0.0}

- "tiles": array de objetos con "left" y "right" enteros 0-6
- "confidence": 0.0 a 1.0 según qué tan seguro estás
- Ignora fichas cortadas o ilegibles
- Si no hay fichas: {"tiles":[],"confidence":0}
''';

  Future<DominoVisionResult> analyze(Uint8List jpegBytes) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );

    final response = await model.generateContent([
      Content.multi([
        TextPart(_prompt),
        DataPart('image/jpeg', jpegBytes),
      ]),
    ]);

    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw DominoVisionException('Gemini no devolvió respuesta.');
    }

    return _parseResponse(text);
  }

  DominoVisionResult _parseResponse(String text) {
    final jsonStr = _extractJson(text);
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final rawTiles = decoded['tiles'] as List<dynamic>? ?? [];
    final confidence =
        (decoded['confidence'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 0.8;

    final tiles = <DominoTile>[];
    for (final item in rawTiles) {
      if (item is! Map) continue;
      final left = (item['left'] as num?)?.toInt();
      final right = (item['right'] as num?)?.toInt();
      if (left == null ||
          right == null ||
          !DominoPips.isValidPip(left) ||
          !DominoPips.isValidPip(right)) {
        continue;
      }
      tiles.add(DominoTile(left: left, right: right));
    }

    return DominoVisionResult(
      tiles: tiles,
      source: VisionAnalysisSource.gemini,
      confidence: confidence,
      message: tiles.isEmpty
          ? 'No se detectaron fichas en la foto.'
          : 'Detectadas ${tiles.length} fichas con IA Gemini.',
    );
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return text.substring(start, end + 1);
    }
    throw DominoVisionException('Respuesta IA inválida.');
  }
}

class DominoVisionException implements Exception {
  DominoVisionException(this.message);
  final String message;

  @override
  String toString() => message;
}
