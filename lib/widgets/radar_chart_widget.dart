import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Gráfico radar que muestra las tres dimensiones de evaluación.
class RadarChartWidget extends StatelessWidget {
  final double logicScore;
  final double efficiencyScore;
  final double styleScore;

  const RadarChartWidget({
    super.key,
    required this.logicScore,
    required this.efficiencyScore,
    required this.styleScore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.slate.withValues(alpha: 0.1);
    final labelColor = isDark ? AppColors.grayLight : AppColors.gray;

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: [
              RadarEntry(value: logicScore),
              RadarEntry(value: efficiencyScore),
              RadarEntry(value: styleScore),
            ],
            fillColor: AppColors.emerald.withValues(alpha: 0.25),
            borderColor: AppColors.emerald,
            borderWidth: 2.5,
            entryRadius: 4,
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        radarBorderData: BorderSide(color: gridColor, width: 1),
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        tickBorderData: BorderSide(color: gridColor, width: 0.8),
        gridBorderData: BorderSide(color: gridColor, width: 0.8),
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, angle) {
          const labels = ['Lógica', 'Eficiencia', 'Estilo'];
          return RadarChartTitle(
            text: labels[index],
            angle: 0,
          );
        },
        titleTextStyle: TextStyle(
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
