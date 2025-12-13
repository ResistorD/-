import 'package:flutter/material.dart';

/// Программно рисуем плюс — без внутренних отступов SVG.
/// Так иконка занимает весь заданный бокс, совпадает с макетом.
class PlusIcon extends StatelessWidget {
  const PlusIcon({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth,       // толщина линий; если null — берём size * 0.14
    this.armRatio = 0.4,   // половина длины усика = size * armRatio
  });

  final double size;
  final Color color;
  final double? strokeWidth;
  final double armRatio;

  @override
  Widget build(BuildContext context) {
    final sw = strokeWidth ?? size * 0.13; // 13% от размера — близко к фигме
    return CustomPaint(
      size: Size.square(size),
      painter: _PlusPainter(color: color, strokeWidth: sw, armRatio: armRatio),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter({required this.color, required this.strokeWidth, required this.armRatio});
  final Color color;
  final double strokeWidth;
  final double armRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final len = size.width * armRatio;

    // Полупиксель для crisp-линий при нечётной толщине
    final o = (strokeWidth % 2 == 1) ? 0.5 : 0.0;

    // Горизонтальная
    canvas.drawLine(Offset(cx - len + o, cy + o), Offset(cx + len + o, cy + o), p);
    // Вертикальная
    canvas.drawLine(Offset(cx + o, cy - len + o), Offset(cx + o, cy + len + o), p);
  }

  @override
  bool shouldRepaint(covariant _PlusPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth || old.armRatio != armRatio;
}

/// FAB с «кольцом»-ободком и сглаженным краем
class CustomFab extends StatelessWidget {
  const CustomFab({
    super.key,
    required this.onPressed,
    this.ring = 72,           // диаметр внешнего круга (ободок)
    this.inner = 56,          // диаметр самой кнопки
    this.iconSize = 22,       // размер «плюса» (квадратный бокс)
    this.plusStroke,          // толщина линий плюса; если null — 14% от iconSize
    this.plusArmRatio = 0.46, // доля половины длины «усиков»
  });

  final VoidCallback onPressed;
  final double ring;
  final double inner;
  final double iconSize;
  final double? plusStroke;
  final double plusArmRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    // Цвета FAB — из темы (мы их задали в AppTheme.*Base()).
    final fabBg  = theme.floatingActionButtonTheme.backgroundColor ?? const Color(0xFF2E5D85);
    final fabFg  = theme.floatingActionButtonTheme.foregroundColor ?? Colors.white;
    final ringBg = cs.surface; // цвет ободка — как и раньше, из surface

    return SizedBox(
      width: ring,
      height: ring,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ободок с антиалиасом и мягкой тенью
          PhysicalModel(
            color: ringBg,
            elevation: 8,
            shadowColor: const Color(0x33000000),
            clipBehavior: Clip.antiAlias,
            shape: BoxShape.circle,
            child: const SizedBox.expand(),
          ),
          // Внутренняя кнопка
          SizedBox(
            width: inner,
            height: inner,
            child: FloatingActionButton(
              onPressed: onPressed,
              elevation: 0,
              backgroundColor: fabBg,
              foregroundColor: fabFg,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: PlusIcon(
                size: iconSize,
                color: fabFg,
                strokeWidth: plusStroke,   // можно тонко подстроить при желании
                armRatio: plusArmRatio,    // и «длину усиков»
              ),
            ),
          ),
        ],
      ),
    );
  }
}
