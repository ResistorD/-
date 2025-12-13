// FILE: lib/screens/journal_tab.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/entry_screen.dart';
import '../models/entry.dart';
import '../services/storage_service.dart';
import '../services/prefs_service.dart';
import '../widgets/entry_row.dart';
import '../theme/tokens.dart';
import '../theme/scale.dart';
import '../widgets/custom_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/svg_icon.dart';

enum Range { today, week, month, all }

class JournalTab extends StatefulWidget {
  const JournalTab({super.key});
  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab>
    with AutomaticKeepAliveClientMixin {
  Range _range = Range.today;

  @override
  void initState() {
    super.initState();
    final i = PrefsService.journalRange;
    if (i >= 0 && i < Range.values.length) _range = Range.values[i];
  }

  @override
  bool get wantKeepAlive => true;

  String _periodLabel(Range r) => switch (r) {
    Range.today => 'Сегодня',
    Range.week => 'Неделя',
    Range.month => 'Месяц',
    Range.all => 'Всё время',
  };

  bool _inRange(Entry e) {
    final now = DateTime.now();
    final from = switch (_range) {
      Range.today => DateTime(now.year, now.month, now.day),
      Range.week => now.subtract(const Duration(days: 7)),
      Range.month => now.subtract(const Duration(days: 30)),
      Range.all => DateTime(1900),
    };
    return !e.timestamp.isBefore(from);
  }

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _avg7(List<Entry> list) {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final w = list.where((e) => e.timestamp.isAfter(from)).toList();
    if (w.isEmpty) return '—';
    final s = w.fold<int>(0, (p, e) => p + e.systolic);
    final d = w.fold<int>(0, (p, e) => p + e.diastolic);
    return '${(s / w.length).round()}/${(d / w.length).round()}';
  }

  String _recordsLabel(int n) {
    final r10 = n % 10, r100 = n % 100;
    final word = (r10 == 1 && r100 != 11)
        ? 'запись'
        : (r10 >= 2 && r10 <= 4 && (r100 < 12 || r100 > 14))
        ? 'записи'
        : 'записей';
    return '$n $word';
  }

  Color _dot(Entry e) {
    if (e.systolic >= 140 || e.diastolic >= 90) return const Color(0xFFE11D48);
    if (e.systolic <= 100 || e.diastolic <= 60) return const Color(0xFF60A5FA);
    return const Color(0xFF22C55E);
  }

  // Группировка записей по датам
  DateTime _dateKey(DateTime t) => DateTime(t.year, t.month, t.day);
  String _dateRu(DateTime d) {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    const weekdays = [
      'понедельник',
      'вторник',
      'среда',
      'четверг',
      'пятница',
      'суббота',
      'воскресенье'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}, ${weekdays[d.weekday - 1]}';
  }

  List<MapEntry<DateTime, List<Entry>>> _groupByDate(List<Entry> list) {
    final map = <DateTime, List<Entry>>{};
    for (final e in list) {
      final k = _dateKey(e.timestamp);
      (map[k] ??= []).add(e);
    }
    final out = map.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    for (final e in out) {
      e.value.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final blueH = HomeTokens.blueH(context);
    final lightH = HomeTokens.lightH(context);
    final side = HomeTokens.side(context);
    final titleTop = HomeTokens.titleTop(context);
    final cardH = HomeTokens.cardHeight(context);
    final overlap = HomeTokens.overlap(context);
    final safeTop = MediaQuery.of(context).padding.top;

    return ValueListenableBuilder<Box<Entry>>(
      valueListenable: StorageService.entriesListenable,
      builder: (_, box, __) {
        final all = box.values.toList().cast<Entry>()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final filtered = all.where(_inRange).toList();

        final last = all.isNotEmpty ? all.first : null;
        final avg7Text = _avg7(all);
        final recLabel = _recordsLabel(filtered.length);
        final period = _periodLabel(_range);
        final groups = _groupByDate(filtered);

        // ---------- СТАТИЧНАЯ ШАПКА + ПОЛКА ----------
        final header = SizedBox(
          height: blueH + lightH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Синий фон
              Positioned.fill(child: ColoredBox(color: C.headerBlue)),

              // Светлая полка
              Positioned(
                left: 0,
                right: 0,
                top: blueH,
                height: lightH,
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: ColoredBox(color: HomeTokens.shelfColor(context))),
                    if (HomeTokens.shelfDividerEnabled(context))
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: HomeTokens.shelfDividerHeight(context),
                        child: ColoredBox(
                            color: HomeTokens.shelfDividerColor(context)),
                      ),
                    if (HomeTokens.shelfShadowEnabled(context))
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: HomeTokens.shelfShadowHeight(context),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                HomeTokens.shelfShadowColor(context),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Заголовок + период
              Positioned(
                left: side,
                right: side,
                top: safeTop + titleTop,
                child: CustomHeader(
                  title: 'Мой дневник',
                  periodLabel: period,
                  onPick: (v) {
                    setState(() {
                      _range = switch (v) {
                        'Сегодня' => Range.today,
                        'Неделя' => Range.week,
                        'Месяц' => Range.month,
                        _ => Range.all,
                      };
                      PrefsService.setJournalRange(_range.index);
                    });
                  },
                ),
              ),

              // «N записей»
              Positioned(
                left: side,
                right: side,
                top: (blueH - overlap) - HomeTokens.recordsTop(context),
                child: Text(
                  recLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: HomeTokens.recordsFont(context),
                    color: HomeTokens.recordsColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Синяя карточка
              Positioned(
                left: side,
                right: side,
                top: blueH - overlap,
                child: SizedBox(
                  height: cardH,
                  child: SummaryCard(
                    systolic: last?.systolic ?? 0,
                    diastolic: last?.diastolic ?? 0,
                    pulse: last?.pulse,
                    timeText: last != null ? _hhmm(last.timestamp) : '--:--',
                    avg7Text: avg7Text,
                    showAvg: false,
                  ),
                ),
              ),

              // «среднее за 7д» — на полке (оставила как было у тебя)
              //Positioned(
                //left: HomeTokens.avgPadLeft(context),
                //right: HomeTokens.avgPadRight(context),
                //top: blueH + HomeTokens.avgPadTop(context),
                //child: Text(
                  //'среднее за 7д: $avg7Text',
                  //style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    //fontSize: HomeTokens.avgLabelFont(context),
                    //color: HomeTokens.avgLabelColor(context),
                    //fontWeight: FontWeight.w600,
                  //),
                //),
              //),
            ],
          ),
        );

        // ---------- ЛЕНТА ЖУРНАЛА ----------
        final list = CustomScrollView(
          slivers: [
            if (groups.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    side,
                    dp(context, 16),
                    side,
                    0,
                  ),
                  child: Text(
                    'Нет записей за выбранный период',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .7),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: dp(context, 24))),
            ] else ...[
              for (final g in groups) ...[
                // Заголовок даты — выравнивание вправо + правый отступ
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: side,
                        top: dp(context, 4),
                        bottom: dp(context, 4),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _dateRu(g.key),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: HomeTokens.sectionFont(context),
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.80),
                        ),
                      ),
                    ),
                  ),
                ),

                // Элементы этой даты
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final e = g.value[i];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(side, dp(context, 4), side, 0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(dp(context, 10)),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EntryScreen(initialEntry: e),
                              ),
                            );
                            // Перерисовка не нужна: список слушает Hive (ValueListenableBuilder)
                          },
                          child: EntryRow(entry: e),
                        ),
                      );

                        },
                    childCount: g.value.length,
                  ),
                ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: dp(context, 24))),
            ],
          ],
        );

        // Итоговая раскладка: статичный header + прокручиваемая лента
        return ColoredBox(
          color: HomeTokens.pageBg(context),
          child: Column(
            children: [
              header, // не скроллится
              Expanded(child: list), // скроллится
            ],
          ),
        );
      },
    );
  }
}
