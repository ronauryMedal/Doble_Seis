import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../widgets/app_logo.dart';
import '../guide/guide_screen.dart';
import '../home/home_screen.dart';

/// Bienvenida de primera vez: saluda y pregunta si quiere ver el tutorial.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.repository,
    required this.liveRoomManager,
  });

  final GameRepository repository;
  final LiveRoomManager liveRoomManager;

  Future<void> _goHome(BuildContext context) async {
    await repository.completeOnboarding();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          repository: repository,
          liveRoomManager: liveRoomManager,
        ),
      ),
      (route) => false,
    );
  }

  void _openGuide(BuildContext context) {
    HapticUtils.mediumTap();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (guideContext) => GuideScreen(
          onFinish: () => _goHome(guideContext),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const AppLogo(showName: false, height: 132)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 24),
              Text(
                '¡Te damos la bienvenida!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 26,
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                AppConstants.appSlogan,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
              ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
              const SizedBox(height: 20),
              Text(
                '¿Quieres ver un recorrido rápido de cómo usar la app?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              const Spacer(flex: 3),
              FilledButton.icon(
                onPressed: () => _openGuide(context),
                icon: const Icon(Icons.menu_book_rounded, size: 20),
                label: const Text(
                  'Ver cómo se usa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.nightBackground,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate().fadeIn(delay: 650.ms, duration: 450.ms),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _goHome(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Ahora no, ir al inicio'),
              ).animate().fadeIn(delay: 750.ms, duration: 450.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
