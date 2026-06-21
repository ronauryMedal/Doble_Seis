import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

/// Teclado numérico propio — evita el teclado del sistema.
///
/// ¿Por qué custom? Mientras anotas con una mano y sostienes fichas,
/// el teclado nativo puede tapar la UI o cambiar de idioma. Este teclado
/// vive dentro de la app, con botones grandes y accesos rápidos al dominó.
class SmartKeyboard extends StatefulWidget {
  const SmartKeyboard({
    super.key,
    required this.onScoreSubmitted,
    required this.onQuickScore,
    this.enabled = true,
  });

  /// Se llama cuando el usuario confirma un número personalizado.
  final ValueChanged<int> onScoreSubmitted;

  /// Atajos +10, +25, +30.
  final ValueChanged<int> onQuickScore;

  final bool enabled;

  @override
  State<SmartKeyboard> createState() => _SmartKeyboardState();
}

class _SmartKeyboardState extends State<SmartKeyboard> {
  String _input = '';

  void _onDigit(String digit) {
    if (!widget.enabled) return;
    if (_input.length >= 3) return;
    HapticUtils.selection();
    setState(() => _input += digit);
  }

  void _onBackspace() {
    if (!widget.enabled || _input.isEmpty) return;
    HapticUtils.lightTap();
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _onConfirm() {
    if (!widget.enabled || _input.isEmpty) return;
    final value = int.tryParse(_input);
    if (value == null || value <= 0) return;
    HapticUtils.mediumTap();
    widget.onScoreSubmitted(value);
    setState(() => _input = '');
  }

  void _onQuick(int score) {
    if (!widget.enabled) return;
    HapticUtils.mediumTap();
    widget.onQuickScore(score);
    setState(() => _input = '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.nightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DisplayBar(value: _input),
            const SizedBox(height: 12),
            _QuickScoreRow(onQuick: _onQuick, enabled: widget.enabled),
            const SizedBox(height: 12),
            _NumericPad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              onConfirm: _onConfirm,
              enabled: widget.enabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayBar extends StatelessWidget {
  const _DisplayBar({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        value.isEmpty ? 'Ingresa puntos' : '+$value',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: value.isEmpty ? 20 : 36,
              color: value.isEmpty ? AppColors.textMuted : AppColors.neonCyan,
              fontWeight: FontWeight.w300,
            ),
      ),
    );
  }
}

class _QuickScoreRow extends StatelessWidget {
  const _QuickScoreRow({
    required this.onQuick,
    required this.enabled,
  });

  final ValueChanged<int> onQuick;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.quickScores.map((score) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeyboardButton(
              label: '+$score',
              onPressed: enabled ? () => onQuick(score) : null,
              accent: AppColors.neonAmber,
              isAccent: true,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NumericPad extends StatelessWidget {
  const _NumericPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onConfirm,
    required this.enabled,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: row
                  .map(
                    (d) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _KeyboardButton(
                          label: d,
                          onPressed:
                              enabled ? () => onDigit(d) : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _KeyboardButton(
                  label: '⌫',
                  onPressed: enabled ? onBackspace : null,
                  fontSize: 22,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _KeyboardButton(
                  label: '0',
                  onPressed: enabled ? () => onDigit('0') : null,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _KeyboardButton(
                  label: '✓',
                  onPressed: enabled ? onConfirm : null,
                  accent: AppColors.neonCyan,
                  isAccent: true,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({
    required this.label,
    required this.onPressed,
    this.accent,
    this.isAccent = false,
    this.fontSize = 26,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? accent;
  final bool isAccent;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.textPrimary;

    return Material(
      color: isAccent
          ? color.withValues(alpha: 0.15)
          : AppColors.nightCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAccent
                  ? color.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isAccent ? FontWeight.w600 : FontWeight.w400,
              color: onPressed == null
                  ? AppColors.textMuted
                  : (isAccent ? color : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
