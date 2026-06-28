import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../home/home_screen.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

/// Tutorial de bienvenida — solo la primera vez.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.liveRoomManager,
    this.onFinish,
  });

  final GameRepository repository;
  final LiveRoomManager liveRoomManager;

  /// Si se provee, se ejecuta al terminar en vez de navegar al Home.
  /// Útil al reabrir el tutorial desde el menú lateral.
  final VoidCallback? onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.edit_note_rounded,
      color: AppColors.neonCyan,
      title: 'Tu marcador de confianza',
      body:
          'Anota, guarda y comparte tus partidas de dominó sin papel ni calculadora.',
    ),
    _OnboardingPage(
      icon: Icons.groups_rounded,
      color: AppColors.neonAmber,
      title: 'Crea la partida',
      body:
          'Elige equipos o individual, meta de puntos y nombres. '
          'Toca Comenzar partida cuando estés listo.',
    ),
    _OnboardingPage(
      icon: Icons.scoreboard_rounded,
      color: AppColors.neonCyan,
      title: 'Anota en segundos',
      body:
          'Teclado rápido, capicúa, tranque, conteo de fichas y bitácora '
          'de cada mano.',
    ),
    _OnboardingPage(
      icon: Icons.qr_code_scanner_rounded,
      color: AppColors.neonAmber,
      title: 'Comparte en vivo',
      body:
          'Quien lleva el marcador muestra un QR. Los demás se unen como '
          'espectadores en la misma WiFi.',
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_outlined,
      color: AppColors.neonAmber,
      title: 'Historial y estadísticas',
      body:
          'Revisa partidas ganadas, dominadas y ranking de equipos o jugadores.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    HapticUtils.mediumTap();
    await widget.repository.completeOnboarding();
    if (!mounted) return;
    if (widget.onFinish != null) {
      widget.onFinish!();
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          repository: widget.repository,
          liveRoomManager: widget.liveRoomManager,
        ),
      ),
    );
  }

  void _next() {
    HapticUtils.selection();
    if (_page >= _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.nightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: isLast
                  ? const SizedBox(height: 48)
                  : TextButton(
                      onPressed: _finish,
                      child: const Text(
                        'Omitir',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: page.color.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Icon(page.icon, size: 44, color: page.color),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: 26,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                        ),
                        if (index == 0) ...[
                          const SizedBox(height: 20),
                          Text(
                            AppConstants.appSlogan,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.neonCyan,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.neonCyan
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: AppColors.nightBackground,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isLast ? '¡Empezar!' : 'Siguiente',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
