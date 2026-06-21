import 'dart:io';

import 'package:domino_score/data/repositories/game_repository.dart';
import 'package:domino_score/features/vision/data/vision_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hive init en tests no cuelga', () async {
    final hiveDir = Directory.systemTemp.createTempSync('domino_hive_unit');
    final repository = GameRepository();
    await repository.init(testHivePath: hiveDir.path);

    final visionSettings = VisionSettingsRepository();
    await visionSettings.init();

    expect(visionSettings.hasGeminiApiKey, isTrue);
  });
}
