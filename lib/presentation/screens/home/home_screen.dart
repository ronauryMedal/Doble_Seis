import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/player_colors.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/participant_setup.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../domain/enums/game_mode.dart';
import '../../../domain/enums/live_room_connection_mode.dart';
import '../../../domain/enums/scoring_ui_mode.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../bloc/game/game_bloc.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_logo.dart';
import '../history/game_history_screen.dart';
import '../stats/game_stats_screen.dart';
import '../guide/guide_screen.dart';
import '../live_room/join_room_screen.dart';
import '../scoreboard/easy_scoreboard_screen.dart';
import '../scoreboard/scoreboard_screen.dart';

/// Pantalla de configuración: modo, puntaje, jugadores y nombres.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.liveRoomManager,
  });

  final GameRepository repository;
  final LiveRoomManager liveRoomManager;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScoringUiMode _scoringUiMode = ScoringUiMode.easy;
  GameMode _mode = GameMode.teamVsTeam;
  LiveRoomConnectionMode _connectionMode = LiveRoomConnectionMode.offline;
  int _playerCount = AppConstants.defaultIndividualPlayers;
  int _playersPerTeam = AppConstants.defaultPlayersPerTeam;
  int _selectedWinScore = AppConstants.defaultWinScore;
  bool _hasSavedGame = false;

  final TextEditingController _winScoreController = TextEditingController(
    text: '${AppConstants.defaultWinScore}',
  );
  final TextEditingController _teamANameController = TextEditingController(
    text: AppConstants.defaultTeamAName,
  );
  final TextEditingController _teamBNameController = TextEditingController(
    text: AppConstants.defaultTeamBName,
  );
  final List<TextEditingController> _teamAPlayerControllers = [];
  final List<TextEditingController> _teamBPlayerControllers = [];
  final List<TextEditingController> _individualControllers = [];

  @override
  void initState() {
    super.initState();
    _rebuildTeamPlayerControllers();
    _rebuildIndividualControllers();
    _checkSavedGame();
  }

  void _checkSavedGame() {
    setState(() => _hasSavedGame = widget.repository.hasSavedSession);
  }

  void _rebuildTeamPlayerControllers() {
    _syncControllerList(
      _teamAPlayerControllers,
      _playersPerTeam,
      (i) => 'Jugador A${i + 1}',
    );
    _syncControllerList(
      _teamBPlayerControllers,
      _playersPerTeam,
      (i) => 'Jugador B${i + 1}',
    );
  }

  void _rebuildIndividualControllers() {
    _syncControllerList(
      _individualControllers,
      _playerCount,
      (i) => 'Jugador ${i + 1}',
    );
  }

  void _syncControllerList(
    List<TextEditingController> list,
    int count,
    String Function(int) defaultName,
  ) {
    while (list.length < count) {
      list.add(TextEditingController(text: defaultName(list.length)));
    }
    while (list.length > count) {
      list.removeLast().dispose();
    }
  }

  void _setScoringUiMode(ScoringUiMode mode) {
    HapticUtils.selection();
    setState(() {
      _scoringUiMode = mode;
      if (mode == ScoringUiMode.easy) {
        _mode = GameMode.teamVsTeam;
        _connectionMode = LiveRoomConnectionMode.offline;
      }
    });
  }

  void _setMode(GameMode mode) {
    HapticUtils.selection();
    setState(() => _mode = mode);
  }

  void _setPlayerCount(int count) {
    HapticUtils.selection();
    setState(() {
      _playerCount = count;
      _rebuildIndividualControllers();
    });
  }

  void _setPlayersPerTeam(int count) {
    HapticUtils.selection();
    setState(() {
      _playersPerTeam = count;
      _rebuildTeamPlayerControllers();
    });
  }

  void _selectPresetScore(int score) {
    HapticUtils.selection();
    setState(() {
      _selectedWinScore = score;
      _winScoreController.text = '$score';
    });
  }

  int? _parseWinScore() {
    final value = int.tryParse(_winScoreController.text.trim());
    if (value == null) return null;
    if (value < AppConstants.minWinScore || value > AppConstants.maxWinScore) {
      return null;
    }
    return value;
  }

  List<ParticipantSetup> _buildParticipants() {
    if (_scoringUiMode == ScoringUiMode.easy ||
        _mode == GameMode.teamVsTeam) {
      // En Modo Fácil solo hay nombres de equipo (sin miembros).
      if (_scoringUiMode == ScoringUiMode.easy) {
        return [
          ParticipantSetup(name: _teamANameController.text),
          ParticipantSetup(name: _teamBNameController.text),
        ];
      }
      return [
        ParticipantSetup(
          name: _teamANameController.text,
          memberNames:
              _teamAPlayerControllers.map((c) => c.text).toList(growable: false),
        ),
        ParticipantSetup(
          name: _teamBNameController.text,
          memberNames:
              _teamBPlayerControllers.map((c) => c.text).toList(growable: false),
        ),
      ];
    }
    return _individualControllers
        .map((c) => ParticipantSetup(name: c.text))
        .toList(growable: false);
  }

  void _startGame({required bool restore}) {
    if (!restore) {
      final winScore = _parseWinScore();
      if (winScore == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ingresa un puntaje entre ${AppConstants.minWinScore} y ${AppConstants.maxWinScore}',
            ),
            backgroundColor: AppColors.neonRose,
          ),
        );
        return;
      }
      _selectedWinScore = winScore;
    }

    HapticUtils.mediumTap();
    final bloc = context.read<GameBloc>();

    if (restore) {
      final saved = widget.repository.loadCurrentSession();
      if (saved == null) {
        setState(() => _hasSavedGame = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay una partida guardada para continuar.'),
          ),
        );
        return;
      }
      bloc.add(const GameRestored());
      final scoreboard = saved.isEasyMode
          ? const EasyScoreboardScreen()
          : const ScoreboardScreen();
      Navigator.of(context)
          .push(AppPageRoute(page: scoreboard))
          .then((_) => _checkSavedGame());
      return;
    }

    bloc.add(GameConfigured(
      winScore: _selectedWinScore,
      mode: _scoringUiMode == ScoringUiMode.easy
          ? GameMode.teamVsTeam
          : _mode,
      participants: _buildParticipants(),
      connectionMode: _scoringUiMode == ScoringUiMode.easy
          ? LiveRoomConnectionMode.offline
          : _connectionMode,
      scoringUiMode: _scoringUiMode,
    ));

    Navigator.of(context)
        .push(
          AppPageRoute(
            page: _scoringUiMode == ScoringUiMode.easy
                ? const EasyScoreboardScreen()
                : const ScoreboardScreen(),
          ),
        )
        .then((_) => _checkSavedGame());
  }

  void _openSpectatorJoin() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      AppPageRoute(
        page: JoinRoomScreen(
          liveRoomManager: widget.liveRoomManager,
        ),
      ),
    );
  }

  void _openHistory() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      AppPageRoute(
        page: GameHistoryScreen(repository: widget.repository),
      ),
    );
  }

  void _openStats() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      AppPageRoute(
        page: GameStatsScreen(repository: widget.repository),
      ),
    );
  }

  void _openTutorial() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      AppPageRoute(page: const GuideScreen()),
    );
  }

  void _showAbout() {
    HapticUtils.lightTap();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.nightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(height: 72),
            const SizedBox(height: 16),
            Text(
              AppConstants.appSlogan,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Versión ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.neonCyan),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _winScoreController.dispose();
    _teamANameController.dispose();
    _teamBNameController.dispose();
    for (final c in [
      ..._teamAPlayerControllers,
      ..._teamBPlayerControllers,
      ..._individualControllers,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
        ),
      ),
      drawer: _HomeDrawer(
        onHistory: _openHistory,
        onStats: _openStats,
        onSpectator: _openSpectatorJoin,
        onTutorial: _openTutorial,
        onAbout: _showAbout,
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(showName: false, height: 104).entrance(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _scoringUiMode == ScoringUiMode.easy
                      ? 'Nueva partida'
                      : 'Modo completo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ).entrance(index: 1),
                if (_scoringUiMode == ScoringUiMode.easy) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Escribe los nombres y anota. Así de simple.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ).entrance(index: 2),
                ],
                const SizedBox(height: AppSpacing.lg),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle(title: 'Primero a'),
                      const SizedBox(height: AppSpacing.sm),
                      _WinScorePresets(
                        selected: _selectedWinScore,
                        onSelected: _selectPresetScore,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _winScoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          final parsed = _parseWinScore();
                          if (parsed != null) {
                            setState(() => _selectedWinScore = parsed);
                          }
                        },
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Puntaje manual',
                          hintText: 'Ej: 175',
                        ),
                      ),
                    ],
                  ),
                ).entrance(index: 3),
                const SizedBox(height: AppSpacing.md),
              if (_scoringUiMode == ScoringUiMode.easy) ...[
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle(title: 'Nombres de equipos'),
                      const SizedBox(height: AppSpacing.sm),
                      _NameField(
                        label: 'Equipo A',
                        color: AppColors.teamA,
                        controller: _teamANameController,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _NameField(
                        label: 'Equipo B',
                        color: AppColors.teamB,
                        controller: _teamBNameController,
                      ),
                    ],
                  ),
                ).entrance(index: 4),
              ] else ...[
                TextButton.icon(
                  onPressed: () => _setScoringUiMode(ScoringUiMode.easy),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Volver al modo fácil'),
                ),
                const SizedBox(height: AppSpacing.sm),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle(title: 'Modo de juego'),
                      const SizedBox(height: AppSpacing.sm),
                      _ModeSelector(selected: _mode, onSelected: _setMode),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_mode == GameMode.teamVsTeam) ...[
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SectionTitle(title: 'Jugadores por equipo'),
                        const SizedBox(height: AppSpacing.sm),
                        _CountSelector(
                          count: _playersPerTeam,
                          min: AppConstants.minPlayersPerTeam,
                          max: AppConstants.maxPlayersPerTeam,
                          onChanged: _setPlayersPerTeam,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TeamSetupBlock(
                    title: 'Equipo A',
                    color: AppColors.teamA,
                    teamNameController: _teamANameController,
                    playerControllers: _teamAPlayerControllers,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TeamSetupBlock(
                    title: 'Equipo B',
                    color: AppColors.teamB,
                    teamNameController: _teamBNameController,
                    playerControllers: _teamBPlayerControllers,
                  ),
                ] else ...[
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SectionTitle(title: 'Cantidad de jugadores'),
                        const SizedBox(height: AppSpacing.sm),
                        _CountSelector(
                          count: _playerCount,
                          min: AppConstants.minIndividualPlayers,
                          max: AppConstants.maxIndividualPlayers,
                          onChanged: _setPlayerCount,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const _SectionTitle(title: 'Nombres de jugadores'),
                        const SizedBox(height: AppSpacing.sm),
                        ...List.generate(_individualControllers.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _NameField(
                              label: 'Jugador ${index + 1}',
                              color: PlayerColors.forIndex(index),
                              controller: _individualControllers[index],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle(title: 'Compartir marcador'),
                      const SizedBox(height: AppSpacing.sm),
                      _ConnectionModeSelector(
                        selected: _connectionMode,
                        onSelected: (mode) {
                          if (!mode.isAvailable) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sala en la nube — próximamente.'),
                                backgroundColor: AppColors.neonRose,
                              ),
                            );
                            return;
                          }
                          HapticUtils.selection();
                          setState(() => _connectionMode = mode);
                        },
                      ),
                      if (_connectionMode == LiveRoomConnectionMode.localWifi) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tú anotas; los demás escanean tu QR en la misma WiFi.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => _startGame(restore: false),
                child: Text(
                  _scoringUiMode == ScoringUiMode.easy
                      ? 'Comenzar'
                      : 'Comenzar partida',
                ),
              ).entrance(index: 5),
              if (_hasSavedGame) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => _startGame(restore: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neonAmber,
                    side: BorderSide(
                      color: AppColors.neonAmber.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Text('Continuar partida'),
                ).entrance(index: 6),
              ],
              if (_scoringUiMode == ScoringUiMode.easy) ...[
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: () => _setScoringUiMode(ScoringUiMode.full),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Entrar en modo completo'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ).entrance(index: 7),
                Text(
                  'WiFi, capicúa, reloj, individual y más opciones.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ).entrance(index: 8),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _TeamSetupBlock extends StatelessWidget {
  const _TeamSetupBlock({
    required this.title,
    required this.color,
    required this.teamNameController,
    required this.playerControllers,
  });

  final String title;
  final Color color;
  final TextEditingController teamNameController;
  final List<TextEditingController> playerControllers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _NameField(
            label: 'Nombre del equipo',
            color: color,
            controller: teamNameController,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(playerControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _NameField(
                label: 'Jugador ${index + 1}',
                color: color,
                controller: playerControllers[index],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.label,
    required this.color,
    required this.controller,
  });

  final String label;
  final Color color;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color.withValues(alpha: 0.85)),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: color.withValues(alpha: 0.55), width: 1.5),
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.onHistory,
    required this.onStats,
    required this.onSpectator,
    required this.onTutorial,
    required this.onAbout,
  });

  final VoidCallback onHistory;
  final VoidCallback onStats;
  final VoidCallback onSpectator;
  final VoidCallback onTutorial;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(showName: false, height: 56),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appSlogan,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.emoji_events_outlined,
              color: AppColors.neonAmber,
              label: 'Partidas ganadas',
              onTap: () => _run(context, onHistory),
            ),
            _DrawerItem(
              icon: Icons.bar_chart_rounded,
              color: AppColors.neonCyan,
              label: 'Estadísticas',
              onTap: () => _run(context, onStats),
            ),
            _DrawerItem(
              icon: Icons.qr_code_scanner_rounded,
              color: AppColors.neonAmber,
              label: 'Unirme como espectador',
              onTap: () => _run(context, onSpectator),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              color: AppColors.textSecondary,
              label: 'Cómo usar la app',
              onTap: () => _run(context, onTutorial),
            ),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              color: AppColors.textSecondary,
              label: 'Acerca de',
              onTap: () => _run(context, onAbout),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _run(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
    );
  }
}

class _ConnectionModeSelector extends StatelessWidget {
  const _ConnectionModeSelector({
    required this.selected,
    required this.onSelected,
  });

  final LiveRoomConnectionMode selected;
  final ValueChanged<LiveRoomConnectionMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: LiveRoomConnectionMode.values.map((mode) {
        final isSelected = mode == selected;
        final isSoon = !mode.isAvailable;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onSelected(mode),
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonCyan
                      : AppColors.nightSurface,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      mode.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.ink
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isSoon)
                      Text(
                        'Pronto',
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? AppColors.ink.withValues(alpha: 0.55)
                              : AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selected,
    required this.onSelected,
  });

  final GameMode selected;
  final ValueChanged<GameMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: GameMode.values.map((mode) {
        final isSelected = mode == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => onSelected(mode),
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonCyan
                      : AppColors.nightSurface,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.ink
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WinScorePresets extends StatelessWidget {
  const _WinScorePresets({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.winScoreOptions.map((score) {
        final isSelected = score == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onSelected(score),
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonAmber
                      : AppColors.nightSurface,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonAmber
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.neonAmber.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '$score',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.ink
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CountSelector extends StatelessWidget {
  const _CountSelector({
    required this.count,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int count;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: count > min ? () => onChanged(count - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.neonCyan,
        ),
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.nightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                ),
          ),
        ),
        IconButton(
          onPressed: count < max ? () => onChanged(count + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.neonCyan,
        ),
      ],
    );
  }
}
