import '../core/theme/app_colors.dart';
import 'issue.dart';
import 'programming_language.dart';

/// Resultado de la evaluación de una categoría individual.
class CategoryScore {
  final AnalysisCategory category;
  final double score; // 0 - 100
  final String summary;
  final List<Issue> issues;
  final Map<String, dynamic> metrics;

  const CategoryScore({
    required this.category,
    required this.score,
    required this.summary,
    required this.issues,
    required this.metrics,
  });

  /// Devuelve el conteo de problemas por severidad.
  Map<SeverityLevel, int> get severityCounts {
    final counts = <SeverityLevel, int>{
      SeverityLevel.error: 0,
      SeverityLevel.warning: 0,
      SeverityLevel.info: 0,
      SeverityLevel.success: 0,
    };
    for (final issue in issues) {
      counts[issue.severity] = counts[issue.severity]! + 1;
    }
    return counts;
  }
}
