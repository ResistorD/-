import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'svg_icon.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.index,
    required this.onSelect,
    required this.fabRing,    // диаметр кольца FAB (окно по центру)
    required this.barHeight,  // высота бара
    required this.notchMargin,
    required this.iconSize,   // размер иконок
  });

  final int index;
  final ValueChanged<int> onSelect;
  final double fabRing;
  final double barHeight;
  final double notchMargin;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    // Все иконки = цвет FAB (darkBlue)
    final Color iconColor =
        theme.floatingActionButtonTheme.backgroundColor ?? const Color(0xFF2E5D85);
    final Color selectedBg = iconColor.withOpacity(.12);
    final Color divider    = cs.outlineVariant.withOpacity(.35);

    return Material(
      color: cs.surface,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: divider, width: 0.6)),
        ),
        child: BottomAppBar(
          height: barHeight, // ← управляем высотой здесь
          color: cs.surface,
          elevation: 8,
          shape: const CircularNotchedRectangle(),
          notchMargin: notchMargin,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: double.infinity,
              child: Row(
                children: [
                  _item(context, asset: 'house',    i: 0, selected: index == 0, iconColor: iconColor, selectedBg: selectedBg),
                  _item(context, asset: 'Vector',   i: 1, selected: index == 1, iconColor: iconColor, selectedBg: selectedBg),
                  SizedBox(width: fabRing), // окно под FAB-кольцо
                  _item(context, asset: 'settings', i: 2, selected: index == 2, iconColor: iconColor, selectedBg: selectedBg),
                  _item(context, asset: 'user-pen', i: 3, selected: index == 3, iconColor: iconColor, selectedBg: selectedBg),
                ].map((w) => Expanded(child: Center(child: w))).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
      BuildContext context, {
        required String asset,
        required int i,
        required bool selected,
        required Color iconColor,
        required Color selectedBg,
      }) {
    final bubble = iconSize + 6;
    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: () { HapticFeedback.selectionClick(); onSelect(i); },
        radius: 28,
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: Container(
              width: bubble,
              height: bubble,
              decoration: BoxDecoration(
                color: selected ? selectedBg : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgIcon(asset, size: iconSize, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
