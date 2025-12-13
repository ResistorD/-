import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/prefs_service.dart';
import '../figma/figma_guidelines.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const EntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
  });

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Color _statusColor(BuildContext context) {
    final up  = PrefsService.targetSys;
    final low = PrefsService.targetDia;
    final s = entry.systolic, d = entry.diastolic;

    if (s < up - 15 || d < low - 10) return Colors.blueAccent;
    final deltaUp = (s - up).clamp(0, 100) + (d - low).clamp(0, 100);
    if (deltaUp >= 30 || s >= 160 || d >= 100) return Colors.redAccent;
    if (s > up || d > low) return Colors.orangeAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dotColor = _statusColor(context);

    final commentParts = <String>[];
    if ((entry.pulse ?? 0) > 0) commentParts.add('Пульс: ${entry.pulse}');
    if ((entry.comment ?? '').isNotEmpty) commentParts.add(entry.comment!);
    final comment = commentParts.join(' • ');

    return FigmaContainer.card(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12), // Используем стандартный отступ Figma
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Сохраняем прежние отступы
      borderRadius: FigmaDesignSystem.borderRadius['large'], // Используем Figma-радиус скругления
      child: InkWell(
        borderRadius: FigmaDesignSystem.borderRadius['large'],
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 12, height: 12,
              margin: EdgeInsets.only(right: 12, left: 2),
              decoration: BoxDecoration(
                color: dotColor, shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: 0.35),
                    blurRadius: 6, spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.systolic}/${entry.diastolic} мм рт.ст.',
                    style: FigmaDesignSystem.typography['titleMedium']?.copyWith(
                      fontWeight: FontWeight.w600, 
                      color: cs.onSurface,
                    ),
                  ),
                  FigmaSizedBox.unit(heightFactor: 0.5), // 4dp отступа по Figma-системе
                  if (comment.isNotEmpty)
                    Text(
                      comment,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: FigmaDesignSystem.typography['bodyMedium']?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  else if ((entry.pulse ?? 0) > 0)
                    Text(
                      'Пульс: ${entry.pulse}',
                      style: FigmaDesignSystem.typography['bodyMedium']?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            FigmaSizedBox.unit(widthFactor: 1.5), // 12dp отступа по Figma-системе
            Text(
              _hhmm(entry.timestamp),
              style: FigmaDesignSystem.typography['bodySmall']?.copyWith(
                color: cs.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
