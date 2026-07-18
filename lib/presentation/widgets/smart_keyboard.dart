import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
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
    this.compact = false,
  });

  /// Se llama cuando el usuario confirma un número personalizado.
  final ValueChanged<int> onScoreSubmitted;

  /// Atajo +30.
  final ValueChanged<int> onQuickScore;

  final bool enabled;
  final bool compact;

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
    final pad = widget.compact ? 6.0 : 16.0;
    final gap = widget.compact ? 4.0 : 12.0;

    return Container(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, widget.compact ? 6 : 24),
      decoration: BoxDecoration(
        color: AppColors.nightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
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
            if (widget.compact)
              Row(
                children: [
                  Expanded(
                    child: _DisplayBar(
                      value: _input,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: _KeyboardButton(
                      label: '+${AppConstants.quickScore}',
                      onPressed: widget.enabled
                          ? () => _onQuick(AppConstants.quickScore)
                          : null,
                      accent: AppColors.neonAmber,
                      isAccent: true,
                      compact: true,
                    ),
                  ),
                ],
              )
            else ...[
              _DisplayBar(value: _input, compact: false),
              SizedBox(height: gap),
              _QuickScoreRow(
                onQuick: _onQuick,
                enabled: widget.enabled,
                compact: false,
              ),
            ],
            SizedBox(height: gap),
            _NumericPad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              onConfirm: _onConfirm,
              enabled: widget.enabled,
              compact: widget.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayBar extends StatelessWidget {
  const _DisplayBar({required this.value, this.compact = false});

  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: compact ? 6 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        value.isEmpty ? 'Ingresa puntos' : '+$value',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: value.isEmpty
                  ? (compact ? 14 : 20)
                  : (compact ? 26 : 36),
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
    this.compact = false,
  });

  final ValueChanged<int> onQuick;
  final bool enabled;
  final bool compact;

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
              compact: compact,
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
    this.compact = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final bool enabled;
  final bool compact;

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
            padding: EdgeInsets.only(bottom: compact ? 4 : 8),
            child: Row(
              children: row
                  .map(
                    (d) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _KeyboardButton(
                          label: d,
                          onPressed: enabled ? () => onDigit(d) : null,
                          compact: compact,
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
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _KeyboardButton(
                  label: '⌫',
                  onPressed: enabled ? onBackspace : null,
                  fontSize: compact ? 18 : 22,
                  compact: compact,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _KeyboardButton(
                  label: '0',
                  onPressed: enabled ? () => onDigit('0') : null,
                  compact: compact,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _KeyboardButton(
                  label: '✓',
                  onPressed: enabled ? onConfirm : null,
                  accent: AppColors.neonCyan,
                  isAccent: true,
                  fontSize: compact ? 18 : 22,
                  compact: compact,
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
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? accent;
  final bool isAccent;
  final double fontSize;
  final bool compact;

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
          height: compact ? 38 : 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
            border: Border.all(
              color: isAccent
                  ? color.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? (fontSize * 0.85) : fontSize,
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
