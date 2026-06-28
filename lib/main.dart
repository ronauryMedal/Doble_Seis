import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/repositories/game_repository.dart';
import 'features/live_room/live_room_manager.dart';
import 'features/vision/data/vision_settings_repository.dart';

/// Punto de entrada de la app.
///
/// [WidgetsFlutterBinding.ensureInitialized] es obligatorio antes de
/// plugins nativos (Hive, cámara futura, etc.).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Modo inmersivo: más espacio útil para el marcador.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final repository = GameRepository();
  await repository.init();

  final visionSettings = VisionSettingsRepository();
  await visionSettings.init();

  final liveRoomManager = LiveRoomManager();

  runApp(DominoApp(
    repository: repository,
    liveRoomManager: liveRoomManager,
    visionSettings: visionSettings,
  ));
}
