import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/repositories/game_repository.dart';
import 'data/sync/firebase_cloud_sync.dart';
import 'features/live_room/live_room_manager.dart';
import 'features/vision/data/vision_settings_repository.dart';
import 'firebase_options.dart';

/// Punto de entrada de la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final repository = GameRepository(cloudSync: FirebaseCloudSync());
  await repository.init();

  // Login anónimo + bajada de historial (no bloquea si falla / offline).
  await repository.enableCloudSync();

  final visionSettings = VisionSettingsRepository();
  await visionSettings.init();

  final liveRoomManager = LiveRoomManager();

  runApp(DominoApp(
    repository: repository,
    liveRoomManager: liveRoomManager,
    visionSettings: visionSettings,
  ));
}
