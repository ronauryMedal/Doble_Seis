import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../widgets/app_logo.dart';
import 'onboarding_screen.dart';
import '../home/home_screen.dart';

/// Splash inicial y tutorial la primera vez.
class AppLaunchScreen extends StatefulWidget {
  const AppLaunchScreen({
    super.key,
    required this.repository,
    required this.liveRoomManager,
  });

  final GameRepository repository;
  final LiveRoomManager liveRoomManager;

  @override
  State<AppLaunchScreen> createState() => _AppLaunchScreenState();
}

class _AppLaunchScreenState extends State<AppLaunchScreen> {
  @override
  void initState() {
    super.initState();
    _launch();
  }

  Future<void> _launch() async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final showTutorial = !widget.repository.isOnboardingComplete;
    final next = showTutorial
        ? OnboardingScreen(
            repository: widget.repository,
            liveRoomManager: widget.liveRoomManager,
          )
        : HomeScreen(
            repository: widget.repository,
            liveRoomManager: widget.liveRoomManager,
          );

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(showName: false, height: 160)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 28),
                Text(
                  AppConstants.appName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 5,
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appSlogan,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neonCyan,
                        height: 1.35,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 550.ms)
                    .slideY(begin: 0.15, end: 0, delay: 500.ms, duration: 550.ms),
                const SizedBox(height: 48),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neonCyan.withValues(alpha: 0.5),
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
