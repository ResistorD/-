import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/prefs_service.dart';
import '../theme/scale.dart'; // dp()
import 'svg_icon.dart';      // SvgIcon('asset-name', size: ..., color: ...)

class EntryRow extends StatelessWidget {
  final Entry entry;
  const EntryRow({super.key, required this.entry});

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Color _dotColor() {
    final up  = PrefsService.upperNorm;
    final low = PrefsService.lowerNorm;
    if (entry.systolic > up.sys || entry.diastolic > up.dia) return const Color(0xFFE11D48); // красный
    if (entry.systolic < low.sys || entry.diastolic < low.dia) return const Color(0xFF60A5FA); // синий
    return const Color(0xFF22C55E); // зелёный
  }

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // размеры
    final rowH  = dp(context, 59); //общая высота строки журнала (включая «пилюлю», время и точку-индикатор)
    final timeW = dp(context, 56); //ширина колонки времени слева (09:00), чтобы часы/минуты влезали в одну строку
    final dotD  = dp(context, 15); //диаметр цветной точки-индикатора (зелёная/красная/синяя) после времени

    final pillR = dp(context, 6);  //радиус скругления углов «пилюли» (белого контейнера с 120/80 и пульсом)
    final padH  = dp(context, 20); //горизонтальные внутренние отступы «пилюли» (слева/справа внутри белого контейнера)
    final padV  = dp(context, 10); //вертикальные внутренние отступы «пилюли» (сверху/снизу внутри белого контейнера)

    final gapL  = dp(context, 8); //промежуток между текстом давления (120/80) и иконкой тренда (стрелочки ↕)
    final gapS  = dp(context, 8); //малый промежуток между числом пульса и иконкой пульса (85 · 📈)

    // иконки (единый размер/цвет)
    final iconSZ  = dp(context, 24);
    final iconClr = cs.onSurface.withValues(alpha: 0.70); // нейтральный

    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final pillBg  = isDark ? cs.surface : Colors.white;

    return SizedBox(
      height: rowH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // время
          SizedBox(
            width: timeW,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _hhmm(entry.timestamp),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.left,
                style: (t.labelLarge ?? const TextStyle()).copyWith(
                  color: const Color(0xFF325674),
                  height: 1.0,
                ),
              ),
            ),
          ),

          // точка-индикатор
          Container(
            width: dotD,
            height: dotD,
            margin: EdgeInsets.only(right: dp(context, 10)),
            decoration: BoxDecoration(color: _dotColor(), shape: BoxShape.circle),
          ),

          // «таблетка»
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(pillR),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '${entry.systolic}/${entry.diastolic}',
                    maxLines: 1,
                    style: t.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                  SizedBox(width: gapL),

                  // стрелочки ↕ — SVG ассет
                  SvgIcon('arrow-up-down', size: iconSZ, color: iconClr),

                  const Spacer(),

                  if ((entry.pulse ?? 0) > 0) ...[
                    Text(
                      '${entry.pulse}',
                      maxLines: 1,
                      style: t.titleMedium?.copyWith(color: cs.onSurface),
                    ),
                    SizedBox(width: gapS),
                    // пульс — SVG ассет
                    SvgIcon('activity', size: iconSZ, color: iconClr),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
