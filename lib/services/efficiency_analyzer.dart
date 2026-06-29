import '../core/theme/app_colors.dart';
import '../models/category_score.dart';
import '../models/issue.dart';
import '../models/programming_language.dart';

/// Analizador de eficiencia de código.
///
/// Estima la complejidad temporal (Big-O) detectando bucles anidados,
/// recursión, y operaciones costosas. Evalúa también el uso de memoria
/// y la elección de estructuras de datos.
class EfficiencyAnalyzer {
  CategoryScore analyze(String code, ProgrammingLanguage language) {
    final issues = <Issue>[];

    // 1. Bucles anidados y estimación de Big-O
    final bigO = _estimateTimeComplexity(code, language, issues);

    // 2. Recursión
    final isRecursive = _detectRecursion(code, language);

    // 3. Operaciones costosas dentro de bucles
    _checkExpensiveOpsInLoops(code, language, issues);

    // 4. Búsqueda/ordenación manual vs. funciones nativas
    _checkManualSearchSort(code, language, issues);

    // 5. Uso de estructuras de datos
    _checkDataStructureUsage(code, language, issues);

    // 6. Recursión sin memoización
    if (isRecursive) {
      _checkRecursionEfficiency(code, language, issues);
    }

    // 7. Concatenación de strings en bucles
    _checkStringConcatInLoops(code, language, issues);

    // 8. Recomendación positiva
    if (bigO.order <= 2 && !isRecursive) {
      issues.add(Issue(
        title: 'Complejidad temporal eficiente',
        description: 'El algoritmo se estima en ${bigO.label}, lo cual es '
            'aceptable para la mayoría de casos.',
        severity: SeverityLevel.success,
        category: AnalysisCategory.efficiency,
      ));
    }

    // Cálculo del puntaje
    var score = 100.0;
    for (final issue in issues) {
      switch (issue.severity) {
        case SeverityLevel.error:
          score -= 18;
        case SeverityLevel.warning:
          score -= 8;
        case SeverityLevel.info:
          score -= 2;
        case SeverityLevel.success:
          score += 1;
      }
    }
    // Penalización por complejidad exponencial o peor
    if (bigO.order >= 4) {
      score -= (bigO.order - 3) * 12;
    } else if (bigO.order >= 3) {
      score -= (bigO.order - 2) * 8;
    }
    score = score.clamp(0, 100);

    final summary = _buildSummary(bigO, isRecursive);

    return CategoryScore(
      category: AnalysisCategory.efficiency,
      score: score,
      summary: summary,
      issues: issues,
      metrics: {
        'bigO': bigO.label,
        'bigOrder': bigO.order,
        'isRecursive': isRecursive,
        'maxLoopDepth': bigO.loopDepth,
      },
    );
  }

  /// Estima la complejidad temporal basándose en la profundidad de bucles.
  _BigO _estimateTimeComplexity(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    final loopDepth = _computeMaxLoopDepth(code, language);
    final hasRecursion = _detectRecursion(code, language);

    String label;
    int order;
    if (hasRecursion && _isExponentialRecursion(code, language)) {
      label = 'O(2ⁿ)';
      order = 5;
      issues.add(Issue(
        title: 'Posible complejidad exponencial',
        description: 'Se detectó recursión con múltiples llamadas que puede '
            'llevar a O(2ⁿ). Esto no escala bien.',
        severity: SeverityLevel.error,
        category: AnalysisCategory.efficiency,
        suggestion: 'Considera usar memoización o convertir la recursión en '
            'una solución iterativa con programación dinámica.',
      ));
    } else if (hasRecursion && loopDepth == 0) {
      label = 'O(n) recursivo';
      order = 1;
    } else if (loopDepth >= 3) {
      label = 'O(n³)';
      order = 3;
      issues.add(Issue(
        title: 'Triple bucle anidado',
        description: 'Se detectaron $loopDepth niveles de bucles anidados, lo '
            'que sugiere O(n³). El rendimiento caerá con entradas grandes.',
        severity: SeverityLevel.error,
        category: AnalysisCategory.efficiency,
        suggestion: 'Revisa si puedes reducir un nivel de anidamiento usando '
            'un hashmap o un enfoque de dos punteros.',
      ));
    } else if (loopDepth == 2) {
      label = 'O(n²)';
      order = 2;
      issues.add(Issue(
        title: 'Bucles anidados',
        description: 'Se detectaron 2 niveles de bucles anidados (O(n²)). '
            'Aceptable para entradas pequeñas, pero costoso para grandes.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.efficiency,
        suggestion: 'Si manejas entradas grandes, considera optimizar con un '
            'hashmap (O(n)) u ordenar primero.',
      ));
    } else if (loopDepth == 1) {
      label = 'O(n)';
      order = 1;
    } else {
      label = 'O(1)';
      order = 0;
    }

    return _BigO(label: label, order: order, loopDepth: loopDepth);
  }

  /// Calcula la máxima profundidad de bucles anidados.
  int _computeMaxLoopDepth(String code, ProgrammingLanguage language) {
    final lines = code.split('\n');
    if (language == ProgrammingLanguage.python) {
      return _computeMaxLoopDepthPython(lines);
    }

    var depth = 0;
    var max = 0;
    final loopRegex = RegExp(r'\b(for|while)\b');
    for (final line in lines) {
      final t = line.trim();
      if (t.startsWith('//') || t.startsWith('#')) continue;
      // Cuenta bucles que abren en esta línea
      final opens = loopRegex.allMatches(t).length;
      for (var i = 0; i < opens; i++) {
        depth++;
        if (depth > max) max = depth;
      }
      // Reduce profundidad por cada '}' que cierre
      final closes = '}'.allMatches(t).length;
      depth -= closes;
      if (depth < 0) depth = 0;
    }
    return max;
  }

  int _computeMaxLoopDepthPython(List<String> lines) {
    var maxNesting = 0;
    final indentStack = <int>[];
    final loopRegex = RegExp(r'\b(for|while)\b');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final indent = line.length - line.trimLeft().length;
      while (indentStack.isNotEmpty && indent <= indentStack.last) {
        indentStack.removeLast();
      }
      if (loopRegex.hasMatch(line.trim())) {
        indentStack.add(indent);
        if (indentStack.length > maxNesting) maxNesting = indentStack.length;
      }
    }
    return maxNesting;
  }

  bool _detectRecursion(String code, ProgrammingLanguage language) {
    // Detecta si una función se llama a sí misma.
    final funcRegex = RegExp(r'\b(?:def|function)\s+(\w+)');
    for (final m in funcRegex.allMatches(code)) {
      final name = m.group(1)!;
      final callRegex = RegExp('\\b$name\\s*\\(');
      final after = code.substring(m.end);
      if (callRegex.hasMatch(after)) return true;
    }
    // Java/C++/Dart: métodos con tipo de retorno
    final methodRegex = RegExp(r'\b\w+\s+(\w+)\s*\([^)]*\)\s*(?:\{|$)');
    for (final m in methodRegex.allMatches(code)) {
      final name = m.group(1)!;
      if ({'if', 'for', 'while', 'switch', 'return', 'catch'}.contains(name)) {
        continue;
      }
      final callRegex = RegExp('\\b$name\\s*\\(');
      final after = code.substring(m.end);
      if (callRegex.hasMatch(after)) return true;
    }
    return false;
  }

  /// Heurística: recursión con 2+ llamadas a sí misma en el mismo bloque.
  bool _isExponentialRecursion(String code, ProgrammingLanguage language) {
    final funcRegex = RegExp(r'\b(?:def|function)\s+(\w+)');
    for (final m in funcRegex.allMatches(code)) {
      final name = m.group(1)!;
      final bodyStart = m.end;
      final bodyEnd = _findFunctionEnd(code, bodyStart, language);
      final body = code.substring(bodyStart, bodyEnd);
      final callRegex = RegExp('\\b$name\\s*\\(');
      final count = callRegex.allMatches(body).length;
      if (count >= 2) return true;
    }
    return false;
  }

  int _findFunctionEnd(String code, int start, ProgrammingLanguage language) {
    if (language == ProgrammingLanguage.python) {
      final lines = code.substring(start).split('\n');
      if (lines.length < 2) return code.length;
      final firstBody = lines.skip(1).firstWhere(
        (l) => l.trim().isNotEmpty,
        orElse: () => '',
      );
      if (firstBody.isEmpty) return code.length;
      final indent = firstBody.length - firstBody.trimLeft().length;
      var end = start;
      for (final l in lines.skip(1)) {
        if (l.trim().isEmpty) {
          end += l.length + 1;
          continue;
        }
        final curIndent = l.length - l.trimLeft().length;
        if (curIndent < indent) break;
        end += l.length + 1;
      }
      return end;
    } else {
      var depth = 0;
      var started = false;
      for (var i = start; i < code.length; i++) {
        final ch = code[i];
        if (ch == '{') {
          depth++;
          started = true;
        } else if (ch == '}') {
          depth--;
          if (started && depth == 0) return i;
        }
      }
      return code.length;
    }
  }

  void _checkExpensiveOpsInLoops(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    // Operaciones costosas: .sort(), list.append en bucles pesados, etc.
    final lines = code.split('\n');
    final loopRegex = RegExp(r'\b(for|while)\b');
    var inLoop = false;
    var loopLine = 0;
    for (var i = 0; i < lines.length; i++) {
      final t = lines[i].trim();
      if (loopRegex.hasMatch(t)) {
        inLoop = true;
        loopLine = i + 1;
      }
      if (inLoop) {
        // .sort() dentro de bucle
        if (RegExp(r'\.sort\(\)').hasMatch(t)) {
          issues.add(Issue(
            title: 'Ordenación dentro de bucle',
            description: 'Se llama .sort() dentro de un bucle (línea $loopLine). '
                'Esto puede elevar la complejidad a O(n²·log n) o peor.',
            severity: SeverityLevel.warning,
            category: AnalysisCategory.efficiency,
            line: i + 1,
            suggestion: 'Ordena los datos una sola vez antes del bucle.',
          ));
        }
        // búsqueda lineal .index() en bucle
        if (RegExp(r'\.index\(|\.indexOf\(').hasMatch(t)) {
          issues.add(Issue(
            title: 'Búsqueda lineal en bucle',
            description: 'Se usa .index()/.indexOf() dentro de un bucle. Cada '
                'búsqueda es O(n), elevando el total a O(n²).',
            severity: SeverityLevel.info,
            category: AnalysisCategory.efficiency,
            line: i + 1,
            suggestion: 'Convierte la lista en un Set o Map para búsquedas O(1).',
          ));
        }
      }
      if (inLoop && language != ProgrammingLanguage.python && t.contains('}')) {
        inLoop = false;
      }
    }
  }

  void _checkManualSearchSort(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    // Detecta patrones de ordenamiento manual (bubble sort)
    final bubbleRegex = RegExp(
      r'for\s*\([^)]*\)\s*\{?\s*for\s*\([^)]*\)\s*\{?\s*if\s*\([^)]*<[^)]*\)\s*(swap|temp)',
      multiLine: true,
    );
    if (bubbleRegex.hasMatch(code)) {
      issues.add(Issue(
        title: 'Ordenamiento burbuja detectado',
        description: 'El patrón sugiere un bubble sort manual (O(n²)). Existen '
            'algoritmos más eficientes.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.efficiency,
        suggestion: 'Usa sort() nativo del lenguaje (O(n·log n)) o quicksort/'
            'mergesort.',
      ));
    }
  }

  void _checkDataStructureUsage(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    // Búsqueda repetida en lista → sugerir Set
    final indexCalls = RegExp(r'\.index\(|\.indexOf\(').allMatches(code).length;
    if (indexCalls >= 3) {
      issues.add(Issue(
        title: 'Búsquedas repetidas en lista',
        description: 'Se detectaron $indexCalls búsquedas en lista. Cada una es '
            'O(n).',
        severity: SeverityLevel.info,
        category: AnalysisCategory.efficiency,
        suggestion: 'Si buscas membresía repetidamente, usa un Set/HashSet '
            'para búsquedas O(1).',
      ));
    }
  }

  void _checkRecursionEfficiency(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    // Recursión sin memoización (heurística: no hay cache/dict/memo)
    final hasMemo = RegExp(r'memo|cache|dp\b|@lru_cache|Map<').hasMatch(code);
    if (!hasMemo) {
      issues.add(Issue(
        title: 'Recursión sin memoización',
        description: 'Se detectó recursión pero no se observa memoización. La '
            'recursión pura puede recalcular subproblemas.',
        severity: SeverityLevel.info,
        category: AnalysisCategory.efficiency,
        suggestion: 'Añade memoización (caché de resultados) o conviértelo a '
            'programación dinámica iterativa.',
      ));
    } else {
      issues.add(Issue(
        title: 'Recursión optimizada',
        description: 'Se detectó recursión con memoización. Buen uso de '
            'técnicas de optimización.',
        severity: SeverityLevel.success,
        category: AnalysisCategory.efficiency,
      ));
    }
  }

  void _checkStringConcatInLoops(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    final lines = code.split('\n');
    final loopRegex = RegExp(r'\b(for|while)\b');
    var inLoop = false;
    for (var i = 0; i < lines.length; i++) {
      final t = lines[i].trim();
      if (loopRegex.hasMatch(t)) inLoop = true;
      if (inLoop) {
        // str += ... o str = str + ... (Python/JS)
        // Raw string triple-quoted para incluir " y '.
        if (RegExp(r'''^\w+\s*\+=\s*["']''').hasMatch(t) ||
            RegExp(r'''^\w+\s*=\s*\w+\s*\+\s*["']''').hasMatch(t)) {
          issues.add(Issue(
            title: 'Concatenación de strings en bucle',
            description: 'Concatenar strings con += en un bucle puede ser O(n²) '
                'en algunos lenguajes por inmutabilidad.',
            severity: SeverityLevel.info,
            category: AnalysisCategory.efficiency,
            line: i + 1,
            suggestion: 'Usa una lista y join() (Python) o StringBuilder '
                '(Java) / array.join() (JS) para mejor rendimiento.',
          ));
          break;
        }
      }
      if (inLoop && language != ProgrammingLanguage.python && t.contains('}')) {
        inLoop = false;
      }
    }
  }

  String _buildSummary(_BigO bigO, bool isRecursive) {
    final parts = <String>[];
    parts.add('Complejidad temporal estimada: ${bigO.label}');
    if (isRecursive) parts.add('usa recursión');
    return parts.join(' · ');
  }
}

class _BigO {
  final String label;
  final int order; // 0=O(1), 1=O(n), 2=O(n²), 3=O(n³), 5=O(2ⁿ)
  final int loopDepth;
  const _BigO({
    required this.label,
    required this.order,
    required this.loopDepth,
  });
}
