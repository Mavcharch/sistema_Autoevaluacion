import '../core/theme/app_colors.dart';
import '../models/category_score.dart';
import '../models/issue.dart';
import '../models/programming_language.dart';

/// Analizador de lógica de código.
///
/// Evalúa complejidad ciclomática, profundidad de anidamiento,
/// manejo de casos límite, cobertura de retornos y estructura
/// general del control de flujo.
class LogicAnalyzer {
  CategoryScore analyze(String code, ProgrammingLanguage language) {
    final issues = <Issue>[];
    final lines = code.split('\n');
    final codeLines = lines.where((l) => l.trim().isNotEmpty).toList();

    if (codeLines.isEmpty) {
      return CategoryScore(
        category: AnalysisCategory.logic,
        score: 0,
        summary: 'No se encontró código para analizar.',
        issues: const [],
        metrics: const {},
      );
    }

    // 1. Complejidad ciclomática
    final cyclomatic = _computeCyclomaticComplexity(code, language);

    // 2. Profundidad máxima de anidamiento
    final maxNesting = _computeMaxNesting(code, language);

    // 3. Detección de casos límite
    final edgeCaseCount = _checkEdgeCases(code, language, issues);

    // 4. TODO / FIXME
    _checkTodoFixme(lines, issues);

    // 5. Funciones sin retorno / retorno inconsistente
    _checkReturnPaths(code, language, issues);

    // 6. Complejidad ciclomática alta
    if (cyclomatic > 15) {
      issues.add(Issue(
        title: 'Complejidad ciclomática alta',
        description: 'La complejidad ciclomática es $cyclomatic. Valores por '
            'encima de 10 indican código difícil de probar y mantener.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.logic,
        suggestion: 'Descompón las funciones complejas en unidades más '
            'pequeñas con responsabilidad única.',
      ));
    } else if (cyclomatic > 10) {
      issues.add(Issue(
        title: 'Complejidad moderada',
        description: 'La complejidad ciclomática es $cyclomatic. Considera '
            'simplificar la lógica condicional.',
        severity: SeverityLevel.info,
        category: AnalysisCategory.logic,
      ));
    }

    // 7. Anidamiento profundo
    if (maxNesting > 4) {
      issues.add(Issue(
        title: 'Anidamiento excesivo',
        description: 'Se detectó un nivel de anidamiento de $maxNesting. La '
            'lógica profundamente anidada es difícil de seguir.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.logic,
        suggestion: 'Usa "cláusulas de guardia" (early return) para reducir '
            'el anidamiento o extrae bloques a funciones.',
      ));
    }

    // 8. Buenas prácticas detectadas (positivos)
    if (edgeCaseCount >= 2) {
      issues.add(Issue(
        title: 'Buen manejo de casos límite',
        description: 'Se detectaron $edgeCaseCount validaciones de casos '
            'límite (vacíos, nulos, límites).',
        severity: SeverityLevel.success,
        category: AnalysisCategory.logic,
      ));
    }

    // 9. Ausencia total de control de flujo
    final hasControlFlow = _hasControlFlow(code, language);
    if (!hasControlFlow && codeLines.length > 8) {
      issues.add(Issue(
        title: 'Sin control de flujo',
        description: 'No se detectaron estructuras condicionales ni bucles. '
            'Verifica que la lógica sea completa.',
        severity: SeverityLevel.info,
        category: AnalysisCategory.logic,
      ));
    }

    // 10. Bucles potencialmente infinitos
    _checkInfiniteLoops(code, language, issues);

    // Cálculo del puntaje
    var score = 100.0;
    for (final issue in issues) {
      switch (issue.severity) {
        case SeverityLevel.error:
          score -= 15;
        case SeverityLevel.warning:
          score -= 7;
        case SeverityLevel.info:
          score -= 2;
        case SeverityLevel.success:
          score += 1;
      }
    }
    // Penalización por complejidad
    if (cyclomatic > 10) {
      score -= (cyclomatic - 10) * 1.5;
    }
    if (maxNesting > 4) {
      score -= (maxNesting - 4) * 4;
    }
    score = score.clamp(0, 100);

    final summary = _buildSummary(score, cyclomatic, maxNesting, edgeCaseCount);

    return CategoryScore(
      category: AnalysisCategory.logic,
      score: score,
      summary: summary,
      issues: issues,
      metrics: {
        'cyclomaticComplexity': cyclomatic,
        'maxNesting': maxNesting,
        'edgeCaseChecks': edgeCaseCount,
        'hasControlFlow': hasControlFlow,
      },
    );
  }

  /// Complejidad ciclomática = puntos de decisión + 1.
  int _computeCyclomaticComplexity(String code, ProgrammingLanguage language) {
    var complexity = 1;
    final decisionKeywords = <String>[
      'if', 'elif', 'else if', 'for', 'while', 'case', 'catch', 'except',
      '&&', '||', 'and ', 'or ',
    ];
    for (final kw in decisionKeywords) {
      complexity += _countOccurrences(code, kw);
    }
    // Ternarios
    complexity += '?'.allMatches(code).length;
    return complexity;
  }

  int _countOccurrences(String haystack, String needle) {
    var count = 0;
    var idx = 0;
    while ((idx = haystack.indexOf(needle, idx)) != -1) {
      // Verifica límites de palabra para palabras clave
      if (_isWordBoundary(needle)) {
        final before = idx == 0 ? ' ' : haystack[idx - 1];
        final after = idx + needle.length >= haystack.length
            ? ' '
            : haystack[idx + needle.length];
        if (_isWordChar(before) || _isWordChar(after)) {
          idx += needle.length;
          continue;
        }
      }
      count++;
      idx += needle.length;
    }
    return count;
  }

  bool _isWordBoundary(String s) =>
      RegExp(r'^[A-Za-z]').hasMatch(s) || RegExp(r'^[A-Za-z]$').hasMatch(s);

  bool _isWordChar(String c) =>
      RegExp(r'[A-Za-z0-9_]').hasMatch(c);

  /// Calcula la profundidad máxima de anidamiento.
  int _computeMaxNesting(String code, ProgrammingLanguage language) {
    if (language == ProgrammingLanguage.python) {
      return _computeMaxNestingPython(code);
    }
    var depth = 0;
    var max = 0;
    for (var i = 0; i < code.length; i++) {
      final ch = code[i];
      if (ch == '{') {
        depth++;
        if (depth > max) max = depth;
      } else if (ch == '}') {
        depth--;
      }
    }
    return max;
  }

  int _computeMaxNestingPython(String code) {
    final lines = code.split('\n');
    var maxNesting = 0;
    final indentStack = <int>[0];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final indent = line.length - line.trimLeft().length;
      while (indentStack.isNotEmpty && indent <= indentStack.last) {
        indentStack.removeLast();
      }
      final blockKeywords = RegExp(
        r'\b(if|elif|else|for|while|def|class|with|try|except|finally)\b',
      );
      if (blockKeywords.hasMatch(line.trim())) {
        indentStack.add(indent);
        final nesting = indentStack.length - 1;
        if (nesting > maxNesting) maxNesting = nesting;
      }
    }
    return maxNesting;
  }

  /// Cuenta validaciones de casos límite (vacío, nulo, longitud, índice).
  int _checkEdgeCases(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    var count = 0;
    final patterns = <RegExp>[
      RegExp(r'\.length\s*[<>=!]==?\s*0'),
      RegExp(r'\blen\([^)]*\)\s*[<>=!]==?\s*0'),
      RegExp(r'\bisEmpty\b'),
      RegExp(r'\bnot\s+\w+\b'),
      RegExp(r'==\s*None|==\s*null|!=\s*None|!=\s*null'),
      RegExp(r'\bis\s+None\b'),
      RegExp(r'!\s*\w'),
      RegExp(r'\bif\s+!\s*\w'),
      RegExp(r'\blength\s*>\s*0'),
      RegExp(r'\blen\([^)]*\)\s*>\s*0'),
    ];
    for (final p in patterns) {
      count += p.allMatches(code).length;
    }

    if (count == 0 && code.split('\n').where((l) => l.trim().isNotEmpty).length > 10) {
      issues.add(Issue(
        title: 'Faltan validaciones de casos límite',
        description: 'No se detectaron comprobaciones de entradas vacías, '
            'nulas o de longitud. Esto puede causar errores en tiempo de '
            'ejecución.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.logic,
        suggestion: 'Valida las entradas (lista vacía, valor nulo, índices '
            'fuera de rango) antes de procesarlas.',
      ));
    }
    return count;
  }

  void _checkTodoFixme(List<String> lines, List<Issue> issues) {
    final todoRegex = RegExp(r'\b(TODO|FIXME|HACK|XXX)\b', caseSensitive: false);
    var count = 0;
    for (var i = 0; i < lines.length; i++) {
      if (todoRegex.hasMatch(lines[i])) {
        count++;
        if (count <= 3) {
          issues.add(Issue(
            title: 'Marca pendiente encontrada',
            description: 'Línea ${i + 1}: contiene una marca TODO/FIXME. '
                'Recuerda resolverla antes de finalizar.',
            severity: SeverityLevel.info,
            category: AnalysisCategory.logic,
            line: i + 1,
          ));
        }
      }
    }
  }

  void _checkReturnPaths(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    // Detecta funciones con múltiples returns inconsistentes (heurística).
    final returnCount = RegExp(r'\breturn\b').allMatches(code).length;
    final ifCount = RegExp(r'\bif\b').allMatches(code).length;
    if (ifCount > 3 && returnCount == 0) {
      issues.add(Issue(
        title: 'Posible ruta sin retorno',
        description: 'Hay varias condiciones pero ninguna instrucción return. '
            'Algunas rutas podrían no devolver un valor esperado.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.logic,
      ));
    }
  }

  bool _hasControlFlow(String code, ProgrammingLanguage language) {
    return RegExp(r'\b(if|else|for|while|switch|case)\b').hasMatch(code);
  }

  void _checkInfiniteLoops(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    // while(True) o while(1) sin break visible
    final whileTrue = RegExp(r'while\s*\(\s*(true|1|True)\s*\)');
    for (final m in whileTrue.allMatches(code)) {
      final lineNo = _lineOf(code, m.start);
      final hasBreak = RegExp(r'\bbreak\b').hasMatch(code);
      if (!hasBreak) {
        issues.add(Issue(
          title: 'Posible bucle infinito',
          description: 'Bucle while(true) en la línea $lineNo sin break '
              'detectado.',
          severity: SeverityLevel.error,
          category: AnalysisCategory.logic,
          line: lineNo,
          suggestion: 'Asegúrate de incluir una condición de salida (break) '
              'dentro del bucle.',
        ));
      } else {
        issues.add(Issue(
          title: 'Bucle while(true) controlado',
          description: 'Bucle while(true) en la línea $lineNo con break. '
              'Funcional pero considera una condición explícita.',
          severity: SeverityLevel.info,
          category: AnalysisCategory.logic,
          line: lineNo,
        ));
      }
    }
  }

  int _lineOf(String code, int offset) {
    return '\n'.allMatches(code.substring(0, offset)).length + 1;
  }

  String _buildSummary(
    double score,
    int cyclomatic,
    int maxNesting,
    int edgeCases,
  ) {
    if (score >= 85) {
      return 'La lógica es sólida: complejidad ciclomática $cyclomatic, '
          'anidamiento máximo $maxNesting y buen manejo de casos límite.';
    }
    if (score >= 70) {
      return 'La lógica es razonable pero presenta oportunidades de '
          'simplificación (complejidad $cyclomatic, anidamiento $maxNesting).';
    }
    if (score >= 50) {
      return 'La lógica requiere mejoras: la complejidad ($cyclomatic) y el '
          'anidamiento ($maxNesting) son elevados.';
    }
    return 'La lógica presenta problemas significativos que comprometen la '
        'correctitud o el mantenimiento. Revisa la complejidad y los casos '
        'límite.';
  }
}
