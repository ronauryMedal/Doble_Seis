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
import '../../bloc/game/game_bloc.dart';
import '../scoreboard/scoreboard_screen.dart';

/// Pantalla de configuración: modo, puntaje, jugadores y nombres.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final GameRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameMode _mode = GameMode.teamVsTeam;
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppConstants.appName.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 4,
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nueva partida',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
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
