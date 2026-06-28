import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/player_colors.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/participant_setup.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../domain/enums/game_mode.dart';
import '../../../domain/enums/live_room_connection_mode.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../bloc/game/game_bloc.dart';
import '../../widgets/app_logo.dart';
import '../history/game_history_screen.dart';
import '../stats/game_stats_screen.dart';
import '../guide/guide_screen.dart';
import '../live_room/join_room_screen.dart';
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
    if (_mode == GameMode.teamVsTeam) {
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
      bloc.add(const GameRestored());
    } else {
      bloc.add(GameConfigured(
        winScore: _selectedWinScore,
        mode: _mode,
        participants: _buildParticipants(),
        connectionMode: _connectionMode,
      ));
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => const ScoreboardScreen(),
          ),
        )
        .then((_) => _checkSavedGame());
  }

  void _openSpectatorJoin() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JoinRoomScreen(
          liveRoomManager: widget.liveRoomManager,
        ),
      ),
    );
  }

  void _openHistory() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameHistoryScreen(repository: widget.repository),
      ),
    );
  }

  void _openStats() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameStatsScreen(repository: widget.repository),
      ),
    );
  }

  void _openTutorial() {
    HapticUtils.lightTap();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GuideScreen(),
      ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: 2,
                color: AppColors.textSecondary,
              ),
        ),
        iconTheme: const IconThemeData(color: AppColors.neonCyan),
      ),
      drawer: _HomeDrawer(
        onHistory: _openHistory,
        onStats: _openStats,
        onSpectator: _openSpectatorJoin,
        onTutorial: _openTutorial,
        onAbout: _showAbout,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(showName: false, height: 120),
              const SizedBox(height: 8),
              Text(
                'Nueva partida',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              _SpectatorJoinCard(onTap: _openSpectatorJoin),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o crea una partida',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionTitle(title: 'Modo de juego'),
              const SizedBox(height: 12),
              _ModeSelector(selected: _mode, onSelected: _setMode),
              const SizedBox(height: 28),
              const _SectionTitle(title: 'Primero a'),
              const SizedBox(height: 12),
              _WinScorePresets(
                selected: _selectedWinScore,
                onSelected: _selectPresetScore,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _winScoreController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  final parsed = _parseWinScore();
                  if (parsed != null) {
                    setState(() => _selectedWinScore = parsed);
                  }
                },
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Puntaje manual',
                  hintText: 'Ej: 175',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.nightCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (_mode == GameMode.teamVsTeam) ...[
                const _SectionTitle(title: 'Jugadores por equipo'),
                const SizedBox(height: 12),
                _CountSelector(
                  count: _playersPerTeam,
                  min: AppConstants.minPlayersPerTeam,
                  max: AppConstants.maxPlayersPerTeam,
                  onChanged: _setPlayersPerTeam,
                ),
                const SizedBox(height: 28),
                _TeamSetupBlock(
                  title: 'Equipo A',
                  color: AppColors.teamA,
                  teamNameController: _teamANameController,
                  playerControllers: _teamAPlayerControllers,
                ),
                const SizedBox(height: 16),
                _TeamSetupBlock(
                  title: 'Equipo B',
                  color: AppColors.teamB,
                  teamNameController: _teamBNameController,
                  playerControllers: _teamBPlayerControllers,
                ),
              ] else ...[
                const _SectionTitle(title: 'Cantidad de jugadores'),
                const SizedBox(height: 12),
                _CountSelector(
                  count: _playerCount,
                  min: AppConstants.minIndividualPlayers,
                  max: AppConstants.maxIndividualPlayers,
                  onChanged: _setPlayerCount,
                ),
                const SizedBox(height: 28),
                const _SectionTitle(title: 'Nombres de jugadores'),
                const SizedBox(height: 12),
                ...List.generate(_individualControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NameField(
                      label: 'Jugador ${index + 1}',
                      color: PlayerColors.forIndex(index),
                      controller: _individualControllers[index],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 28),
              const _SectionTitle(title: 'Compartir marcador'),
              const SizedBox(height: 12),
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
                const SizedBox(height: 10),
                Text(
                  'Tú anotas; los demás escanean tu QR en la misma WiFi.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => _startGame(restore: false),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.nightBackground,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Comenzar partida',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (_hasSavedGame) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _startGame(restore: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neonAmber,
                    side: BorderSide(
                      color: AppColors.neonAmber.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Continuar partida'),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openSpectatorJoin,
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('Unirme como espectador'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neonAmber,
                  side: BorderSide(
                    color: AppColors.neonAmber.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _NameField(
            label: 'Nombre del equipo',
            color: color,
            controller: teamNameController,
          ),
          const SizedBox(height: 12),
          ...List.generate(playerControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
        labelStyle: TextStyle(color: color.withValues(alpha: 0.8)),
        filled: true,
        fillColor: AppColors.nightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

class _SpectatorJoinCard extends StatelessWidget {
  const _SpectatorJoinCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neonAmber.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonAmber.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.neonAmber,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unirme como espectador',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            color: AppColors.neonAmber,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Escanea el QR de quien lleva el marcador',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.neonAmber.withValues(alpha: 0.7),
              ),
            ],
          ),
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
      backgroundColor: AppColors.nightBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(showName: false, height: 64),
                  const SizedBox(height: 14),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appSlogan,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
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
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
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
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonCyan.withValues(alpha: 0.15)
                      : AppColors.nightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      mode.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.neonCyan
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isSoon)
                      Text(
                        'Pronto',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
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
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonCyan.withValues(alpha: 0.15)
                      : AppColors.nightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonCyan.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.neonCyan
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
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonAmber.withValues(alpha: 0.15)
                      : AppColors.nightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.neonAmber.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  '$score',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.neonAmber
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
