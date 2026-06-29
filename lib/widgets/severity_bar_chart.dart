import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Gráfico de barras que muestra la distribución de problemas por severidad.
class SeverityBarChart extends StatelessWidget {
  final int errors;
  final int warnings;
  final int info;
  final int successes;

  const SeverityBarChart({
    super.key,
    required this.errors,
    required this.warnings,
    required this.info,
    required this.successes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.grayLight : AppColors.gray;
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.slate.withValues(alpha: 0.08);

    final data = <_BarData>[
      _BarData('Error', errors.toDouble(), AppColors.red),
      _BarData('Aviso', warnings.toDouble(), AppColors.amber),
      _BarData('Info', info.toDouble(), AppColors.teal),
      _BarData('OK', successes.toDouble(), AppColors.emerald),
    ];
    final maxVal = data.fold<double>(
      0,
      (a, e) => a > e.value ? a : e.value,
    );

    return SizedBox(
      height: 170,
      child: BarChart(
        BarChartData(
          maxY: (maxVal + 1).clamp(1, double.infinity),
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[i].label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value,
                    color: data[i].color,
                    width: 28,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal + 1,
                      color: data[i].color.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.slate,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, _, rod, __) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BarData {
  final String label;
  final double value;
  final Color color;
  const _BarData(this.label, this.value, this.color);
}
