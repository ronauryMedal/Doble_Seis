import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/config/gemini_api_key.dart';

/// Guarda la clave de Gemini para escaneo IA (opcional).
class VisionSettingsRepository {
  static const _boxName = 'vision_settings';
  static const _geminiKey = 'gemini_api_key';

  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    _box = Hive.box(_boxName);

    final embedded = embeddedGeminiApiKey;
    if (embedded.isNotEmpty) {
      await _box?.put(_geminiKey, embedded);
    }
  }

  /// Clave desde `--dart-define`, archivo local o Hive.
  String get geminiApiKey {
    const fromEnv = String.fromEnvironment('GEMINI_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;

    final stored = (_box?.get(_geminiKey) as String?)?.trim() ?? '';
    if (stored.isNotEmpty) return stored;

    return embeddedGeminiApiKey;
  }

  bool get hasGeminiApiKey => geminiApiKey.isNotEmpty;

  Future<void> saveGeminiApiKey(String key) async {
    await _box?.put(_geminiKey, key.trim());
  }

  Future<void> clearGeminiApiKey() async {
    await _box?.delete(_geminiKey);
  }
}
