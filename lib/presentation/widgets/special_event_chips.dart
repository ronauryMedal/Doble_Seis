import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/enums/special_event_type.dart';

/// Chips para marcar Capicúa o Chucho (Tranque).
class SpecialEventChips extends StatelessWidget {
  const SpecialEventChips({
    super.key,
    required this.selectedTeamId,
    required this.onEvent,
    this.enabled = true,
  });

  final String selectedTeamId;
  final void Function(String teamId, SpecialEventType event) onEvent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _EventChip(
              label: SpecialEventType.capicua.label,
              color: AppColors.capicua,
              icon: Icons.auto_awesome,
              onTap: enabled
                  ? () => onEvent(selectedTeamId, SpecialEventType.capicua)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _EventChip(
              label: SpecialEventType.chucho.label,
              color: AppColors.chucho,
              icon: Icons.block,
              onTap: enabled
                  ? () => onEvent(selectedTeamId, SpecialEventType.chucho)
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
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
