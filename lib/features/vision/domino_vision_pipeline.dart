import 'dart:typed_data';

import 'data/vision_settings_repository.dart';
import 'models/domino_vision_result.dart';
import 'services/gemini_domino_vision_service.dart';
import 'services/local_domino_vision_analyzer.dart';

/// Orquesta Gemini (preferido) y análisis local (respaldo).
class DominoVisionPipeline {
  DominoVisionPipeline(this._settings);

  final VisionSettingsRepository _settings;
  final LocalDominoVisionAnalyzer _local = LocalDominoVisionAnalyzer();

  bool get hasCloudAi => _settings.hasGeminiApiKey;

  Future<DominoVisionResult> analyze(Uint8List jpegBytes) async {
    if (_settings.hasGeminiApiKey) {
      try {
        final gemini = GeminiDominoVisionService(
          apiKey: _settings.geminiApiKey,
        );
        return await gemini.analyze(jpegBytes);
      } on DominoVisionException {
        rethrow;
      } catch (e) {
        throw DominoVisionException(
          'Error con Gemini IA: $e',
        );
      }
    }

    return _local.analyze(jpegBytes);
  }
}
