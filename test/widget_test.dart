import 'dart:io';

import 'package:domino_score/core/theme/app_theme.dart';
import 'package:domino_score/data/repositories/game_repository.dart';
import 'package:domino_score/features/live_room/live_room_manager.dart';
import 'package:domino_score/features/vision/data/vision_settings_repository.dart';
import 'package:domino_score/features/vision/vision_settings_scope.dart';
import 'package:domino_score/presentation/bloc/game/game_bloc.dart';
import 'package:domino_score/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Carga la pantalla de configuración',
    (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final hiveDir = Directory.systemTemp.createTempSync('domino_test_hive');
      final repository = GameRepository();
      await repository.init(testHivePath: hiveDir.path);
      final liveRoomManager = LiveRoomManager();
      final visionSettings = VisionSettingsRepository();
      await visionSettings.init();

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => GameBloc(
            repository: repository,
            liveRoomManager: liveRoomManager,
          ),
          child: VisionSettingsScope(
            repository: visionSettings,
            child: MaterialApp(
              theme: AppTheme.dark,
              home: HomeScreen(
                repository: repository,
                liveRoomManager: liveRoomManager,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('DOBLE SEIS'), findsOneWidget);
      expect(find.text('Modo de juego'), findsOneWidget);
      expect(find.text('Comenzar partida'), findsOneWidget);
    },
    skip: true, // Cuelga en tests por plugins de cámara (mobile_scanner/camera)
  );
}
