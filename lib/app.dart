import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/game_repository.dart';
import 'features/live_room/live_room_manager.dart';
import 'presentation/bloc/game/game_bloc.dart';
import 'presentation/screens/home/home_screen.dart';

/// Widget raíz de la aplicación.
class DominoApp extends StatelessWidget {
  const DominoApp({
    super.key,
    required this.repository,
    required this.liveRoomManager,
  });

  final GameRepository repository;
  final LiveRoomManager liveRoomManager;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(
        repository: repository,
        liveRoomManager: liveRoomManager,
      ),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: HomeScreen(
          repository: repository,
          liveRoomManager: liveRoomManager,
        ),
      ),
    );
  }
}
