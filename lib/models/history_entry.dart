import 'programming_language.dart';

/// Entrada del historial de evaluaciones (versión ligera para persistencia).
class HistoryEntry {
  final String id;
  final ProgrammingLanguage language;
  final String codePreview;
  final double logicScore;
  final double efficiencyScore;
  final double styleScore;
  final double overallScore;
  final String grade;
  final DateTime evaluatedAt;
  final int totalLines;
  final int issueCount;

  const HistoryEntry({
    required this.id,
    required this.language,
    required this.codePreview,
    required this.logicScore,
    required this.efficiencyScore,
    required this.styleScore,
    required this.overallScore,
    required this.grade,
    required this.evaluatedAt,
    required this.totalLines,
    required this.issueCount,
  });

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as String,
      language: ProgrammingLanguage.values.byName(map['language'] as String),
      codePreview: map['codePreview'] as String,
      logicScore: (map['logicScore'] as num).toDouble(),
      efficiencyScore: (map['efficiencyScore'] as num).toDouble(),
      styleScore: (map['styleScore'] as num).toDouble(),
      overallScore: (map['overallScore'] as num).toDouble(),
      grade: map['grade'] as String,
      evaluatedAt: DateTime.parse(map['evaluatedAt'] as String),
      totalLines: map['totalLines'] as int,
      issueCount: map['issueCount'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language': language.name,
      'codePreview': codePreview,
      'logicScore': logicScore,
      'efficiencyScore': efficiencyScore,
      'styleScore': styleScore,
      'overallScore': overallScore,
      'grade': grade,
      'evaluatedAt': evaluatedAt.toIso8601String(),
      'totalLines': totalLines,
      'issueCount': issueCount,
    };
  }
}
