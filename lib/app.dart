import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/game_repository.dart';
import 'features/live_room/live_room_manager.dart';
import 'features/vision/data/vision_settings_repository.dart';
import 'features/vision/vision_settings_scope.dart';
import 'presentation/bloc/game/game_bloc.dart';
import 'presentation/screens/onboarding/app_launch_screen.dart';

/// Widget raíz de la aplicación.
class DominoApp extends StatelessWidget {
  const DominoApp({
    super.key,
    required this.repository,
    required this.liveRoomManager,
    required this.visionSettings,
  });

  final GameRepository repository;
  final LiveRoomManager liveRoomManager;
  final VisionSettingsRepository visionSettings;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(
        repository: repository,
        liveRoomManager: liveRoomManager,
      ),
      child: VisionSettingsScope(
        repository: visionSettings,
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: AppLaunchScreen(
            repository: repository,
            liveRoomManager: liveRoomManager,
          ),
        ),
      ),
    );
  }
}
