import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/enums/special_event_type.dart';

/// Chips para marcar Capicúa o Tranque.
class SpecialEventChips extends StatelessWidget {
  const SpecialEventChips({
    super.key,
    required this.selectedTeamId,
    required this.onEvent,
    this.enabled = true,
    this.compact = false,
  });

  final String selectedTeamId;
  final void Function(String teamId, SpecialEventType event) onEvent;
  final bool enabled;
  final bool compact;

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
              icon: Icons.auto_awesome,
              compact: compact,
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
              icon: Icons.block,
              compact: compact,
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
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(compact ? 10 : 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: compact ? 14 : 16, color: color),
              SizedBox(width: compact ? 4 : 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
