// smart_number_pad.dart — кастомная цифровая клавиатура.
// Показывает цифры 1..9, 0 и «стереть». Активность каждой цифры задаётся снаружи.

import 'package:flutter/material.dart';

class SmartNumberPad extends StatelessWidget {
  final Set<int> enabledDigits;           // какие цифры разрешено нажать
  final void Function(int digit) onDigit; // коллбэк по нажатию цифры
  final VoidCallback onBackspace;         // коллбэк по удалению
  final EdgeInsetsGeometry padding;

  const SmartNumberPad({
    super.key,
    required this.enabledDigits,
    required this.onDigit,
    required this.onBackspace,
    this.padding = const EdgeInsets.all(16),
  });

  Widget _buildKey(BuildContext context, String label,
      {bool enabled = true, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final fg = enabled ? theme.colorScheme.onSurface : theme.disabledColor;
    final bg = theme.colorScheme.surfaceVariant;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(label,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // сетка 3x4: 1 2 3 / 4 5 6 / 7 8 9 / 0 ⌫
    return Padding(
      padding: padding,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            for (final d in [1, 2, 3, 4, 5, 6, 7, 8, 9])
              _buildKey(
                context,
                '$d',
                enabled: enabledDigits.contains(d),
                onTap: () => onDigit(d),
              ),
            _buildKey(
              context,
              '0',
              enabled: enabledDigits.contains(0),
              onTap: () => onDigit(0),
            ),
            // пустой заполнитель
            const SizedBox.shrink(),
            _buildKey(
              context,
              '⌫',
              enabled: true,
              onTap: onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}
