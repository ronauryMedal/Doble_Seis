import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/game_repository.dart';
import 'presentation/bloc/game/game_bloc.dart';
import 'presentation/screens/scoreboard/scoreboard_screen.dart';

/// Widget raíz de la aplicación.
///
/// Separamos [DominoApp] de [main.dart] para mantener main limpio:
/// main solo inicializa servicios; app define el árbol de widgets.
class DominoApp extends StatelessWidget {
  const DominoApp({super.key, required this.repository});

  final GameRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(repository: repository)..add(const GameStarted()),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const ScoreboardScreen(),
      ),
    );
  }
}
