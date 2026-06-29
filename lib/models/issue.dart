import '../core/theme/app_colors.dart';
import 'programming_language.dart';

/// Un problema o hallazgo detectado durante el análisis de código.
class Issue {
  final String title;
  final String description;
  final SeverityLevel severity;
  final AnalysisCategory category;
  final int? line;
  final String? suggestion;

  const Issue({
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    this.line,
    this.suggestion,
  });

  /// Severidad numérica para ordenar (mayor = más crítico).
  int get severityWeight {
    switch (severity) {
      case SeverityLevel.error:
        return 3;
      case SeverityLevel.warning:
        return 2;
      case SeverityLevel.info:
        return 1;
      case SeverityLevel.success:
        return 0;
    }
  }
}
