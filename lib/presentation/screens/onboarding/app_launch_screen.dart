import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_logo.dart';
import '../home/home_screen.dart';
import 'welcome_screen.dart';

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
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final showWelcome = !widget.repository.isOnboardingComplete;
    final next = showWelcome
        ? WelcomeScreen(
            repository: widget.repository,
            liveRoomManager: widget.liveRoomManager,
          )
        : HomeScreen(
            repository: widget.repository,
            liveRoomManager: widget.liveRoomManager,
          );

    await Navigator.of(context).pushReplacement(AppPageRoute(page: next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        includeSafeArea: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(showName: false, height: 148)
                    .animate()
                    .fadeIn(duration: AppMotion.slow)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: AppMotion.slow,
                      curve: AppMotion.emphasized,
                    ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 34,
                        letterSpacing: -0.8,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 180.ms, duration: AppMotion.slow),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppConstants.appSlogan,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.neonCyan.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w500,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 320.ms, duration: AppMotion.slow)
                    .slideY(
                      begin: 0.12,
                      end: 0,
                      delay: 320.ms,
                      duration: AppMotion.slow,
                      curve: AppMotion.easeOut,
                    ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.neonCyan.withValues(alpha: 0.55),
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: AppMotion.normal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
