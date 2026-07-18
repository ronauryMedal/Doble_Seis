import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/enums/special_event_type.dart';

/// Chips Capicúa / Tranque — activar antes de ingresar puntos.
class SpecialEventChips extends StatelessWidget {
  const SpecialEventChips({
    super.key,
    required this.selectedTeamId,
    required this.onEvent,
    this.enabled = true,
    this.compact = false,
    this.pendingEvent,
    this.pendingTeamId,
  });

  final String selectedTeamId;
  final void Function(String teamId, SpecialEventType event) onEvent;
  final bool enabled;
  final bool compact;
  final SpecialEventType? pendingEvent;
  final String? pendingTeamId;

  bool _isArmed(SpecialEventType type) =>
      pendingEvent == type && pendingTeamId == selectedTeamId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
      child: Row(
        children: [
          Expanded(
            child: _EventChip(
              label: SpecialEventType.capicua.label,
              color: AppColors.capicua,
              icon: Icons.auto_awesome_rounded,
              compact: compact,
              armed: _isArmed(SpecialEventType.capicua),
              onTap: enabled
                  ? () => onEvent(selectedTeamId, SpecialEventType.capicua)
                  : null,
            ),
          ),
          SizedBox(width: compact ? 6 : 10),
          Expanded(
            child: _EventChip(
              label: SpecialEventType.tranque.label,
              color: AppColors.tranque,
              icon: Icons.block_rounded,
              compact: compact,
              armed: _isArmed(SpecialEventType.tranque),
              onTap: enabled
                  ? () => onEvent(selectedTeamId, SpecialEventType.tranque)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.compact = false,
    this.armed = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final bool compact;
  final bool armed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? AppRadii.sm : AppRadii.md);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.easeOut,
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: armed ? 0.24 : 0.1),
            borderRadius: radius,
            border: Border.all(
              color: color.withValues(alpha: armed ? 0.7 : 0.28),
              width: armed ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: compact ? 14 : 16, color: color),
              SizedBox(width: compact ? 4 : 6),
              Flexible(
                child: Text(
                  armed ? '$label ✓' : label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 13,
                    fontWeight: armed ? FontWeight.w700 : FontWeight.w600,
                    color: color,
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
