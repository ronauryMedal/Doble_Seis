import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/domino_pips.dart';
import '../../core/utils/haptic_utils.dart';

/// Contador manual de puntos en fichas restantes (doble seis).
void showDominoCounterSheet(
  BuildContext context, {
  required String targetName,
  required ValueChanged<int> onApply,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.nightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _DominoCounterSheet(
      targetName: targetName,
      onApply: onApply,
    ),
  );
}

class _DominoCounterSheet extends StatefulWidget {
  const _DominoCounterSheet({
    required this.targetName,
    required this.onApply,
  });

  final String targetName;
  final ValueChanged<int> onApply;

  @override
  State<_DominoCounterSheet> createState() => _DominoCounterSheetState();
}

class _DominoCounterSheetState extends State<_DominoCounterSheet> {
  final List<DominoTile> _tiles = [];
  int? _left;
  int? _right;

  int get _total => DominoPips.sumTiles(_tiles);

  void _pickLeft(int v) {
    HapticUtils.selection();
    setState(() => _left = v);
  }

  void _pickRight(int v) {
    HapticUtils.selection();
    setState(() {
      _right = v;
      if (_left != null) {
        _tiles.add(DominoTile(left: _left!, right: v));
        _left = null;
        _right = null;
      }
    });
  }

  void _removeTile(int index) {
    HapticUtils.lightTap();
    setState(() => _tiles.removeAt(index));
  }

  void _clear() {
    HapticUtils.lightTap();
    setState(() {
      _tiles.clear();
      _left = null;
      _right = null;
    });
  }

  void _apply() {
    if (_total <= 0) return;
    HapticUtils.mediumTap();
    widget.onApply(_total);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Conteo de fichas',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cuenta las fichas que quedaron en mano y suma los puntos. '
                    'Se anotará a ${widget.targetName}.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _TotalBanner(total: _total, tileCount: _tiles.length),
                  const SizedBox(height: 16),
                  Text(
                    _left == null
                        ? '1. Toca el primer número de la ficha'
                        : '2. Toca el segundo número ($_left|?)',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          color: AppColors.neonCyan,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _PipRow(
                    selected: _left,
                    onPick: _pickLeft,
                  ),
                  if (_left != null) ...[
                    const SizedBox(height: 8),
                    _PipRow(
                      selected: _right,
                      onPick: _pickRight,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_tiles.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Fichas agregadas',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _clear,
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_tiles.length, (i) {
                        final tile = _tiles[i];
                        return InputChip(
                          label: Text(
                            '${tile.label}  (${tile.pips})',
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTile(i),
                          backgroundColor: AppColors.nightCard,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _total > 0 ? _apply : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: AppColors.nightBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _total > 0
                          ? 'Anotar $_total a ${widget.targetName}'
                          : 'Agrega fichas para sumar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: en tranque, cuenta las fichas de quien perdió la mano.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TotalBanner extends StatelessWidget {
  const _TotalBanner({required this.total, required this.tileCount});

  final int total;
  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w200,
                  color: AppColors.neonCyan,
                  height: 1,
                ),
              ),
              Text(
                'puntos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 24),
          Column(
            children: [
              Text(
                '$tileCount',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                tileCount == 1 ? 'ficha' : 'fichas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PipRow extends StatelessWidget {
  const _PipRow({
    required this.selected,
    required this.onPick,
  });

  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(DominoPips.maxPip + 1, (pip) {
        final isSelected = selected == pip;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Material(
              color: isSelected
                  ? AppColors.neonCyan.withValues(alpha: 0.2)
                  : AppColors.nightCard,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onPick(pip),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.neonCyan.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    '$pip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
