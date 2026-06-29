import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Gráfico de líneas que muestra la evolución del puntaje global.
class TrendChart extends StatelessWidget {
  final List<double> scores;
  final List<String> labels;

  const TrendChart({
    super.key,
    required this.scores,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.slate.withValues(alpha: 0.08);
    final labelColor = isDark ? AppColors.grayLight : AppColors.gray;

    if (scores.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Sin datos aún',
            style: TextStyle(color: labelColor),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < scores.length; i++) {
      spots.add(FlSpot(i.toDouble(), scores[i]));
    }

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: gridColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: labelColor,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: scores.length <= 8,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: TextStyle(fontSize: 9, color: labelColor),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.slate,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.round()} pts',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              preventCurveOverShooting: true,
              color: AppColors.emerald,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.emerald,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.emerald.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
