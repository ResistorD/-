import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Универсальный SVG-иконкa.
/// - [name] — имя файла без `.svg` из папки `assets/`.
/// - [size] — квадратный размер (ширина=высота).
/// - [color] — если передан, перекрашиваем; если **null**, сохраняем исходные цвета из файла.
class SvgIcon extends StatelessWidget {
  final String name;
  final double? size;
  final Color? color;
  final BoxFit fit;

  const SvgIcon(
      this.name, {
        super.key,
        this.size,
        this.color,
        this.fit = BoxFit.contain,
      });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/$name.svg',
      width: size,
      height: size,
      fit: fit,
      // ВАЖНО: не передаём colorFilter, если color == null → родные цвета SVG.
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
