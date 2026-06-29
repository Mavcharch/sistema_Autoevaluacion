import 'package:flutter/material.dart';

import 'category_score.dart';
import 'issue.dart';
import 'programming_language.dart';

/// Resultado completo de una evaluación de código.
class EvaluationResult {
  final ProgrammingLanguage language;
  final String code;
  final CategoryScore logic;
  final CategoryScore efficiency;
  final CategoryScore style;
  final DateTime evaluatedAt;

  const EvaluationResult({
    required this.language,
    required this.code,
    required this.logic,
    required this.efficiency,
    required this.style,
    required this.evaluatedAt,
  });

  /// Lista de las tres categorías.
  List<CategoryScore> get categories => [logic, efficiency, style];

  /// Puntaje global promedio.
  double get overallScore {
    return (logic.score + efficiency.score + style.score) / 3;
  }

  /// Etiqueta cualitativa del puntaje global.
  String get grade {
    final s = overallScore;
    if (s >= 90) return 'Excelente';
    if (s >= 80) return 'Muy bueno';
    if (s >= 70) return 'Bueno';
    if (s >= 60) return 'Regular';
    if (s >= 50) return 'Insuficiente';
    return 'Crítico';
  }

  /// Color asociado al puntaje global.
  Color get gradeColor {
    final s = overallScore;
    if (s >= 85) return const Color(0xFF10B981);
    if (s >= 70) return const Color(0xFF14B8A6);
    if (s >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFF43F5E);
  }

  /// Todos los problemas combinados, ordenados por severidad.
  List<Issue> get allIssues {
    final all = <Issue>[...logic.issues, ...efficiency.issues, ...style.issues];
    all.sort((a, b) => b.severityWeight.compareTo(a.severityWeight));
    return all;
  }

  /// Total de líneas del código evaluado.
  int get totalLines => code.split('\n').length;

  /// Convierte a JSON para almacenamiento.
  Map<String, dynamic> toJson() {
    return {
      'language': language.name,
      'code': code,
      'logicScore': logic.score,
      'efficiencyScore': efficiency.score,
      'styleScore': style.score,
      'overallScore': overallScore,
      'grade': grade,
      'evaluatedAt': evaluatedAt.toIso8601String(),
      'totalLines': totalLines,
      'issueCount': allIssues.length,
    };
  }
}
