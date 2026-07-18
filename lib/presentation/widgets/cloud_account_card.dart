import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/game_repository.dart';
import 'app_background.dart';

/// Tarjeta de cuenta / sync (drawer o historial).
class CloudAccountCard extends StatefulWidget {
  const CloudAccountCard({
    super.key,
    required this.repository,
    this.compact = false,
    this.onSynced,
  });

  final GameRepository repository;
  final bool compact;
  final VoidCallback? onSynced;

  @override
  State<CloudAccountCard> createState() => _CloudAccountCardState();
}

class _CloudAccountCardState extends State<CloudAccountCard> {
  bool _busy = false;

  GameRepository get _repo => widget.repository;

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _repo.signInWithGoogleAndSync();
      widget.onSynced?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta conectada. Historial sincronizado.')),
      );
    } on Object catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final short = msg.contains('cancel') || msg.contains('canceled')
          ? 'Inicio de sesión cancelado'
          : 'No se pudo iniciar sesión. Revisa Google Auth y el SHA-1 en Firebase.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(short)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _repo.signOutCloud();
      widget.onSynced?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada. Tus partidas locales siguen aquí.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _syncNow() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _repo.syncHistoryFromCloud();
      for (final entry in _repo.loadHistory()) {
        await _repo.cloud.pushHistoryEntry(entry.toMap());
      }
      widget.onSynced?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial sincronizado.')),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo sincronizar (¿sin red?).')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_repo.isCloudEnabled) return const SizedBox.shrink();

    final linked = _repo.cloud.isGoogleLinked;
    final name = _repo.cloud.displayName ?? _repo.cloud.email ?? 'Cuenta Google';
    final email = _repo.cloud.email;
    final photo = _repo.cloud.photoUrl;

    return SoftCard(
      padding: EdgeInsets.all(widget.compact ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (linked && photo != null)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(photo),
                )
              else
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.neonCyan.withValues(alpha: 0.2),
                  child: Icon(
                    linked ? Icons.person_rounded : Icons.cloud_outlined,
                    color: AppColors.neonCyan,
                    size: 22,
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      linked ? name : 'Sincroniza tus partidas',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      linked
                          ? (email ?? 'Historial en la nube')
                          : 'Inicia sesión con Google para recuperarlas en otro teléfono',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (_busy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!linked)
            OutlinedButton.icon(
              onPressed: _busy ? null : _signIn,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
              label: const Text('Continuar con Google'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _syncNow,
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: const Text('Sincronizar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextButton(
                    onPressed: _busy ? null : _signOut,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                    child: const Text('Salir'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
