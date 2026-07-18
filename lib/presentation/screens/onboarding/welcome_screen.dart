import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../widgets/app_background.dart';
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
      AppPageRoute(
        page: HomeScreen(
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
      AppPageRoute(
        page: GuideScreen(
          onFinish: () => _goHome(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        includeSafeArea: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    const AppLogo(showName: false, height: 112)
                        .animate()
                        .fadeIn(duration: AppMotion.slow)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1, 1),
                          duration: AppMotion.slow,
                          curve: AppMotion.emphasized,
                        ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '¡Bienvenido a ${AppConstants.appName}!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ).animate().fadeIn(delay: 160.ms, duration: AppMotion.slow),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConstants.appSlogan,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w500,
                          ),
                    ).animate().fadeIn(delay: 280.ms, duration: AppMotion.slow),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '¿Quieres un recorrido rápido de cómo se usa?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 400.ms, duration: AppMotion.slow),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              FilledButton.icon(
                onPressed: () => _openGuide(context),
                icon: const Icon(Icons.menu_book_rounded, size: 20),
                label: const Text('Ver cómo se usa'),
              ).animate().fadeIn(delay: 520.ms, duration: AppMotion.normal),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => _goHome(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Ahora no, ir al inicio'),
              ).animate().fadeIn(delay: 620.ms, duration: AppMotion.normal),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
