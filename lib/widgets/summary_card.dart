// FILE: lib/widgets/summary_card.dart
// Синяя карточка «последнее измерение».
// Пульс и время — В ДВЕ СТРОКИ.
// Кегли у числа пульса и «уд/мин» разные (см. HomeTokens).
// Вертикальные зазоры настраиваются токенами:
//   - HomeTokens.cardGapAfterTitle(context)
//   - HomeTokens.cardGapBetweenRows(context)

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/scale.dart';
import 'svg_icon.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.pulse,     // может быть null
    required this.timeText,  // "08:30"
    required this.avg7Text,  // "120/80" или "—"
    this.showAvg = true,     // если true — рисуем 3-ю строку внутри карточки
  });

  final int systolic;
  final int diastolic;
  final int? pulse;
  final String timeText;
  final String avg7Text;
  final bool showAvg;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: HomeTokens.cardHeight(context),
      decoration: BoxDecoration(
        color: HomeTokens.cardBg(context),
        borderRadius: BorderRadius.circular(HomeTokens.cardRadius(context)),
        boxShadow: const [
          BoxShadow(blurRadius: 22, offset: Offset(0, 10), color: Color(0x22000000)),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: HomeTokens.cardPadH(context),
        vertical:   HomeTokens.cardPadV(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Большие цифры + галка справа
          Row(
            children: [
              Expanded(
                child: Text(
                  '$systolic/$diastolic',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: HomeTokens.bigDigits(context),
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
              SvgIcon(
                'check',
                size:  HomeTokens.checkSize(context),
                color: HomeTokens.checkColor(context),
              ),
            ],
          ),

          // Зазор после заголовка (настраивается токеном)
          SizedBox(height: HomeTokens.cardGapAfterTitle(context)),

          // 2) ПУЛЬС — отдельной строкой c разными кеглями
          if (pulse != null)
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$pulse',
                    style: t.bodyMedium?.copyWith(
                      fontSize: HomeTokens.pulseNumFont(context), // число пульса
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  TextSpan(
                    text: ' уд/мин',
                    style: t.bodyMedium?.copyWith(
                      fontSize: HomeTokens.pulseUnitFont(context), // «уд/мин»
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

          // Зазор между строками пульса и времени (токен)
          if (pulse != null)
            SizedBox(height: HomeTokens.cardGapBetweenRows(context)),

          // 3) ВРЕМЯ — своей строкой
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgIcon('clock', size: dp(context, 18), color: Colors.white),
              SizedBox(width: dp(context, 4)),
              Text(
                timeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodyMedium?.copyWith(
                  fontSize: HomeTokens.timeFont(context),
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),

          // 4) (опционально) «среднее за 7д»
          if (showAvg) ...[
            SizedBox(height: HomeTokens.cardGapBetweenRows(context)),
            Text(
              'среднее за 7д: $avg7Text',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(
                fontSize: HomeTokens.hintFont(context),
                color: Colors.white.withValues(alpha: .90),
                height: 1.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
