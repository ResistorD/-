import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/entry.dart';
import '../services/storage_service.dart';
import '../services/prefs_service.dart';

enum _Period { week, month, days90, all }

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  _Period _period = _Period.month;

  @override
  Widget build(BuildContext context) {
    backgroundColor: Theme.of(context).colorScheme.background; // или ext?.bgLight
    return Scaffold(
      appBar: AppBar(
        title: const Text('Графики'),
        actions: [
          _PeriodButton(
            value: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<Box<Entry>>(
        valueListenable: StorageService.entriesListenable,
        builder: (context, box, _) {
          final entries = _filtered(_fromBox(box), _period);
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const SizedBox(height: 8),
                TabBar(
                  isScrollable: false,
                  tabs: const [
                    Tab(text: 'Давление'),
                    Tab(text: 'Пульс'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [
                      _PressureChart(entries: entries),
                      _PulseChart(entries: entries),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Entry> _fromBox(Box<Entry> box) {
    final list = <Entry>[];
    for (final k in box.keys) {
      final e = box.get(k);
      if (e != null) list.add(e);
    }
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // по времени возрастанию
    return list;
  }

  List<Entry> _filtered(List<Entry> src, _Period p) {
    final now = DateTime.now();
    final from = switch (p) {
      _Period.week   => now.subtract(const Duration(days: 7)),
      _Period.month  => now.subtract(const Duration(days: 30)),
      _Period.days90 => now.subtract(const Duration(days: 90)),
      _Period.all    => DateTime(1900),
    };
    return src.where((e) => !e.timestamp.isBefore(from)).toList();
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({required this.value, required this.onChanged});
  final _Period value;
  final ValueChanged<_Period> onChanged;

  String _label(_Period p) => switch (p) {
    _Period.week   => 'Неделя',
    _Period.month  => 'Месяц',
    _Period.days90 => '90 дней',
    _Period.all    => 'Всё время',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Period>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: _Period.week,   child: Text('Неделя')),
        PopupMenuItem(value: _Period.month,  child: Text('Месяц')),
        PopupMenuItem(value: _Period.days90, child: Text('90 дней')),
        PopupMenuItem(value: _Period.all,    child: Text('Всё время')),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: StadiumBorder(side: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Text(_label(value)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

/// ----- График давления -----
class _PressureChart extends StatelessWidget {
  const _PressureChart({required this.entries});
  final List<Entry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    final spotsSys = <FlSpot>[];
    final spotsDia = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spotsSys.add(FlSpot(i.toDouble(), entries[i].systolic.toDouble()));
      spotsDia.add(FlSpot(i.toDouble(), entries[i].diastolic.toDouble()));
    }

    final lowerDia = PrefsService.lowerNorm.dia.toDouble();
    final upperDia = PrefsService.targetDia.toDouble();
    final lowerSys = PrefsService.lowerNorm.sys.toDouble();
    final upperSys = PrefsService.targetSys.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LineChart(
        LineChartData(
          minY: 40,
          maxY: (spotsSys.map((e) => e.y).fold<double>(0, (p, n) => n > p ? n : p) + 20).clamp(40, 260),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 36),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (entries.length / 6).clamp(1, 12).toDouble(),
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                  final d = entries[i].timestamp;
                  return Text('${d.day}.${d.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spotsSys,
              isCurved: true,
              barWidth: 2.5,
              color: Theme.of(context).colorScheme.primary,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: spotsDia,
              isCurved: true,
              barWidth: 2.5,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.55),
              dotData: const FlDotData(show: false),
            ),
          ],
          // зона нормы: ДАД и САД
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: lowerDia, y2: upperDia,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              ),
              HorizontalRangeAnnotation(
                y1: lowerSys, y2: upperSys,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
              ),
            ],
          ),
          lineTouchData: LineTouchData(enabled: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}

/// ----- График пульса -----
class _PulseChart extends StatelessWidget {
  const _PulseChart({required this.entries});
  final List<Entry> entries;

  @override
  Widget build(BuildContext context) {
    final data = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      final p = entries[i].pulse;
      if (p != null) data.add(FlSpot(i.toDouble(), p.toDouble()));
    }
    if (data.isEmpty) return const Center(child: Text('Нет данных'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (data.length / 6).clamp(1, 12).toDouble(),
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                  final d = entries[i].timestamp;
                  return Text('${d.day}.${d.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              barWidth: 2.5,
              color: Theme.of(context).colorScheme.primary,
              dotData: const FlDotData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(enabled: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}
