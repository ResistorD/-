import 'package:flutter/material.dart';
import '../theme/scale.dart';

class EntryKeypad extends StatelessWidget {
  final void Function(String key) onKey;
  final Set<String> enabledDigits;

  final TextStyle? textStyle;
  final double? borderRadius;
  final double? cellWidth;
  final double? cellHeight;
  final double? gap;
  final double? hPad;

  const EntryKeypad({
    super.key,
    required this.onKey,
    required this.enabledDigits,
    this.cellWidth,
    required this.cellHeight,
    required this.gap,
    required this.hPad,
    this.textStyle,
    this.borderRadius,
  });

  double _snap(BuildContext c, double v) {
    final dpr = MediaQuery.of(c).devicePixelRatio;
    return (v * dpr).floorToDouble() / dpr;
  }

  @override
  Widget build(BuildContext context) {
    final hp  = hPad ?? dp(context, 20);
    final g   = gap  ?? dp(context, 20);
    final W   = cellWidth  ??
        _snap(context, (MediaQuery.of(context).size.width - 2 * hp - 2 * g) / 3);
    final H   = cellHeight ?? dp(context, 48);
    final br  = BorderRadius.circular(borderRadius ?? dp(context, 10));
    final txt = textStyle ??
        TextStyle(
          fontSize: dp(context, 18),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2E5D85), // наш цвет цифр
        );

    Widget digit(String t, {bool enabled = true}) {
      final cs = Theme.of(context).colorScheme;
      return SizedBox(
        width: W, height: H,
        child: ElevatedButton(
          onPressed: enabled ? () => onKey(t) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: enabled ? cs.onSurface : cs.onSurface.withValues(alpha: .65),
            elevation: enabled ? 3 : 0,
            shadowColor: Colors.black.withValues(alpha: .15),
            shape: RoundedRectangleBorder(borderRadius: br),
          ),
          child: Text(t, style: txt),
        ),
      );
    }

    Widget backspace() {
      return SizedBox(
        width: W, height: H,
        child: ElevatedButton(
          onPressed: () => onKey('⌫'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: .15),
            shape: RoundedRectangleBorder(borderRadius: br),
          ),
          child: const Icon(Icons.backspace_outlined, color: Color(0xFF2E5D85)),
        ),
      );
    }

    SizedBox hGap() => SizedBox(width: g);
    SizedBox vGap() => SizedBox(height: g);

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, dp(context, 12)),
      child: Column(
        children: [
          Row(children: [digit('1', enabled: enabledDigits.contains('1')), hGap(), digit('2', enabled: enabledDigits.contains('2')), hGap(), digit('3', enabled: enabledDigits.contains('3'))]),
          vGap(),
          Row(children: [digit('4', enabled: enabledDigits.contains('4')), hGap(), digit('5', enabled: enabledDigits.contains('5')), hGap(), digit('6', enabled: enabledDigits.contains('6'))]),
          vGap(),
          Row(children: [digit('7', enabled: enabledDigits.contains('7')), hGap(), digit('8', enabled: enabledDigits.contains('8')), hGap(), digit('9', enabled: enabledDigits.contains('9'))]),
          vGap(),
          Row(children: [
            digit('0', enabled: enabledDigits.contains('0')),
            hGap(),
            SizedBox(width: W, height: H), // пустая ячейка
            hGap(),
            backspace(),
          ]),
        ],
      ),
    );
  }
}
