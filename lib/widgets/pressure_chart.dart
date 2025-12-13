import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/entry.dart';

class PressureChart extends StatelessWidget {
  final List<Entry> entries;
  const PressureChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('Нет данных для графика'));
    }

    // 1) Стабильность: сортируем по времени и строим индексно по X
    final data = [...entries]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (var i = 0; i < data.length; i++) {
      final s = data[i].systolic.toDouble();
      final d = data[i].diastolic.toDouble();
      final x = i.toDouble();

      systolicSpots.add(FlSpot(x, s));
      diastolicSpots.add(FlSpot(x, d));

      if (s < minY) minY = s;
      if (d < minY) minY = d;
      if (s > maxY) maxY = s;
      if (d > maxY) maxY = d;
    }

    // 2) Аккуратные пределы по Y с запасом
    final span = (maxY - minY).abs();
    final padding = span == 0 ? 10.0 : (span * 0.1).clamp(5, 20);
    final chartMinY = (minY - padding).floorToDouble();
    final chartMaxY = (maxY + padding).ceilToDouble();

    // 3) Без «дрыганья»: отключаем анимации
    // 4) Корректный диапазон X даже при 1 точке
    final minX = 0.0;
    final maxX = data.length == 1 ? 1.0 : (data.length - 1).toDouble();

    // Шаг подписей снизу — примерно 6 меток максимум
    final bottomInterval = data.length <= 1 ? 1.0 : (data.length / 6).ceilToDouble();

    // Шаг по левой оси: ~ 6–8 делений
    double yInterval() {
      final rough = (chartMaxY - chartMinY) / 7.0;
      // округляем к ближайшим 5/10/20 для приятных делений
      if (rough <= 5) return 5;
      if (rough <= 10) return 10;
      if (rough <= 20) return 20;
      if (rough <= 25) return 25;
      if (rough <= 50) return 50;
      return 100;
    }

    return LineChart(
      LineChartData(
        minY: chartMinY,
        maxY: chartMaxY,
        minX: minX,
        maxX: maxX,
        gridData: FlGridData(
          show: true,
          horizontalInterval: yInterval(),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: yInterval(),
              getTitlesWidget: (v, _) =>
                  Text(v.toInt().toString(), style: const TextStyle(fontSize: 11)),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomInterval,
              getTitlesWidget: (value, _) {
                final i = value.round();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final t = data[i].timestamp;
                final hh = t.hour.toString().padLeft(2, '0');
                final mm = t.minute.toString().padLeft(2, '0');
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('$hh:$mm', style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              if (touchedSpots.isEmpty) return [];

              // Берём индекс точки из первой линии
              final firstSpot = touchedSpots.firstWhere(
                    (s) => s.barIndex == 0,
                orElse: () => touchedSpots.first,
              );
              final i = firstSpot.spotIndex;
              final e = data[i];
              final dd = e.timestamp.day.toString().padLeft(2, '0');
              final mm = e.timestamp.month.toString().padLeft(2, '0');
              final hh = e.timestamp.hour.toString().padLeft(2, '0');
              final m2 = e.timestamp.minute.toString().padLeft(2, '0');
              final title = '$dd.$mm $hh:$m2 — ${e.systolic}/${e.diastolic}';

              // Возвращаем тултип только для первой линии, для остальных — null
              return touchedSpots.map((s) {
                if (s.barIndex != 0) return null;
                return LineTooltipItem(
                  title,
                  const TextStyle(fontWeight: FontWeight.w600),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: systolicSpots,
            isCurved: true,
            barWidth: 3,
            color: Colors.red,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: diastolicSpots,
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 0),
    );
  }
}
