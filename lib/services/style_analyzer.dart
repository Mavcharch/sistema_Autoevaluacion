import '../core/theme/app_colors.dart';
import '../models/category_score.dart';
import '../models/issue.dart';
import '../models/programming_language.dart';

/// Analizador de estilo de código.
///
/// Evalúa convenciones de nombres, formato, comentarios,
/// longitud de líneas y funciones, y legibilidad general.
class StyleAnalyzer {
  CategoryScore analyze(String code, ProgrammingLanguage language) {
    final lines = code.split('\n');
    final issues = <Issue>[];
    final nonEmptyLines = lines.where((l) => l.trim().isNotEmpty).toList();
    final codeLines = nonEmptyLines.where(_isCodeLine).toList();

    if (codeLines.isEmpty) {
      return CategoryScore(
        category: AnalysisCategory.style,
        score: 0,
        summary: 'No se encontró código para analizar.',
        issues: const [],
        metrics: const {},
      );
    }

    // 1. Longitud de líneas
    _checkLineLength(lines, issues);

    // 2. Convenciones de nombres
    _checkNamingConventions(code, language, issues);

    // 3. Densidad de comentarios
    final commentStats = _checkComments(lines, codeLines, issues);

    // 4. Espacios en blanco al final / líneas vacías consecutivas
    _checkWhitespace(lines, issues);

    // 5. Números mágicos
    final magicCount = _checkMagicNumbers(codeLines, language, issues);

    // 6. Longitud de funciones
    _checkFunctionLength(code, language, issues);

    // 7. Indentación consistente
    _checkIndentation(lines, issues);

    // 8. Longitud de identificadores
    _checkIdentifierLength(code, language, issues);

    // Cálculo del puntaje
    var score = 100.0;
    for (final issue in issues) {
      switch (issue.severity) {
        case SeverityLevel.error:
          score -= 8;
        case SeverityLevel.warning:
          score -= 4;
        case SeverityLevel.info:
          score -= 1.5;
        case SeverityLevel.success:
          break;
      }
    }
    score = score.clamp(0, 100);

    final summary = _buildSummary(score, issues, commentStats);

    return CategoryScore(
      category: AnalysisCategory.style,
      score: score,
      summary: summary,
      issues: issues,
      metrics: {
        'lineCount': lines.length,
        'codeLineCount': codeLines.length,
        'commentRatio': commentStats['ratio'],
        'magicNumbers': magicCount,
        'avgLineLength': _averageLineLength(codeLines),
      },
    );
  }

  bool _isCodeLine(String line) {
    final t = line.trim();
    if (t.isEmpty) return false;
    if (t.startsWith('//') || t.startsWith('#') || t.startsWith('/*') ||
        t.startsWith('*') || t.startsWith('*/')) {
      return false;
    }
    return true;
  }

  void _checkLineLength(List<String> lines, List<Issue> issues) {
    for (var i = 0; i < lines.length; i++) {
      final len = lines[i].length;
      if (len > 120) {
        issues.add(Issue(
          title: 'Línea demasiado larga',
          description: 'La línea tiene $len caracteres (límite recomendado: '
              '100). Las líneas largas dificultan la lectura.',
          severity: SeverityLevel.warning,
          category: AnalysisCategory.style,
          line: i + 1,
          suggestion: 'Divide la línea en varias más cortas o extrae '
              'expresiones complejas a variables con nombre descriptivo.',
        ));
      } else if (len > 100) {
        issues.add(Issue(
          title: 'Línea larga',
          description: 'La línea tiene $len caracteres. Considera acortarla.',
          severity: SeverityLevel.info,
          category: AnalysisCategory.style,
          line: i + 1,
        ));
      }
    }
  }

  void _checkNamingConventions(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    final convention = language.namingConvention;
    // Patrones para detectar declaraciones de variables/funciones.
    final patterns = <_DeclPattern>[
      _DeclPattern(
        regex: RegExp(r'\b(?:var|let|const)\s+([A-Za-z_]\w*)'),
        kind: _DeclKind.variable,
      ),
      _DeclPattern(
        regex: RegExp(r'\b(?:int|double|float|long|short|char|bool|boolean|'
            r'String|string|void|auto)\s+([A-Za-z_]\w*)'),
        kind: _DeclKind.variable,
      ),
      _DeclPattern(
        regex: RegExp(r'\bdef\s+([A-Za-z_]\w*)\s*\('),
        kind: _DeclKind.function,
      ),
      _DeclPattern(
        regex: RegExp(r'\bfunction\s+([A-Za-z_]\w*)\s*\('),
        kind: _DeclKind.function,
      ),
      _DeclPattern(
        regex: RegExp(r'\b([A-Za-z_]\w*)\s+([A-Za-z_]\w*)\s*\([^)]*\)\s*\{'),
        kind: _DeclKind.function,
      ),
    ];

    final seen = <String>{};
    for (final p in patterns) {
      for (final match in p.regex.allMatches(code)) {
        final name = match.group(1)!;
        if (name.length < 2) continue;
        if (seen.contains(name)) continue;
        seen.add(name);

        final violation = _checkName(name, convention, p.kind);
        if (violation != null) {
          final lineNo = _lineOf(code, match.start);
          issues.add(Issue(
            title: violation.title,
            description: violation.description,
            severity: SeverityLevel.info,
            category: AnalysisCategory.style,
            line: lineNo,
            suggestion: violation.suggestion,
          ));
        }
      }
    }
  }

  _NameViolation? _checkName(
    String name,
    NamingConvention convention,
    _DeclKind kind,
  ) {
    final hasUnderscore = name.contains('_');
    final hasDoubleUnderscore = name.contains('__');

    if (convention == NamingConvention.camelCase) {
      // snake_case no es idóneo (excepto CONSTANTES)
      if (hasUnderscore && name == name.toUpperCase()) return null;
      if (hasUnderscore && !hasDoubleUnderscore) {
        return _NameViolation(
          title: 'Nombre en snake_case',
          description: '"$name" usa guiones bajos. En ${convention.label} '
              'se recomienda camelCase.',
          suggestion: 'Usa ${_camelCase(name)} en su lugar.',
        );
      }
    } else {
      // snake_case esperado (Python)
      if (!hasUnderscore && name.contains(RegExp(r'[a-z]')) &&
          name.contains(RegExp(r'[A-Z]'))) {
        return _NameViolation(
          title: 'Nombre en camelCase',
          description: '"$name" mezcla mayúsculas y minúsculas. En Python se '
              'recomienda snake_case.',
          suggestion: 'Usa ${_toSnake(name)} en su lugar.',
        );
      }
    }

    // Nombres demasiado cortos de una sola letra (excepto i, j, k en bucles)
    if (name.length == 1 && !'ijknxy'.contains(name) && kind != _DeclKind.function) {
      return _NameViolation(
        title: 'Nombre poco descriptivo',
        description: '"$name" es muy corto para transmitir significado.',
        suggestion: 'Usa un nombre que describa el propósito de la variable.',
      );
    }
    return null;
  }

  String _camelCase(String snake) {
    final parts = snake.split('_').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return snake;
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  String _toSnake(String camel) {
    final buf = StringBuffer();
    for (var i = 0; i < camel.length; i++) {
      final ch = camel[i];
      if (ch.toUpperCase() == ch && ch.toLowerCase() != ch && i > 0) {
        buf.write('_');
      }
      buf.write(ch.toLowerCase());
    }
    return buf.toString();
  }

  Map<String, dynamic> _checkComments(
    List<String> lines,
    List<String> codeLines,
    List<Issue> issues,
  ) {
    final commentLines = lines.where((l) {
      final t = l.trim();
      return t.startsWith('//') ||
          t.startsWith('#') ||
          t.startsWith('/*') ||
          t.startsWith('*') ||
          t.startsWith('*/');
    }).length;

    final ratio = codeLines.isEmpty
        ? 0.0
        : commentLines / codeLines.length;

    if (ratio < 0.05 && codeLines.length > 10) {
      issues.add(Issue(
        title: 'Pocos comentarios',
        description: 'Solo el ${(ratio * 100).toStringAsFixed(0)}% del código '
            'está comentado. Los comentarios ayudan a mantener el código.',
        severity: SeverityLevel.info,
        category: AnalysisCategory.style,
        suggestion: 'Añade comentarios explicando la lógica compleja y la '
            'intención de las funciones.',
      ));
    }
    return {'count': commentLines, 'ratio': ratio};
  }

  void _checkWhitespace(List<String> lines, List<Issue> issues) {
    var trailingCount = 0;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line != line.trimRight() && line.trim().isNotEmpty) {
        trailingCount++;
        if (trailingCount <= 3) {
          issues.add(Issue(
            title: 'Espacios al final',
            description: 'La línea ${i + 1} tiene espacios en blanco al final.',
            severity: SeverityLevel.info,
            category: AnalysisCategory.style,
            line: i + 1,
          ));
        }
      }
    }

    // Líneas vacías consecutivas (>2)
    var blankStreak = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) {
        blankStreak++;
        if (blankStreak == 3) {
          issues.add(Issue(
            title: 'Líneas vacías consecutivas',
            description: 'Más de dos líneas vacías seguidas en la línea ${i + 1}.',
            severity: SeverityLevel.info,
            category: AnalysisCategory.style,
            line: i + 1,
          ));
        }
      } else {
        blankStreak = 0;
      }
    }
  }

  int _checkMagicNumbers(
    List<String> codeLines,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    var count = 0;
    // Números que no son 0, 1, 2 y no forman parte de una definición de constante
    final magicRegex = RegExp(r'\b([3-9]\d*|[1-9]\d{2,})\b');
    final constDecl = RegExp(
      r'\b(?:const|static\s+final|FINAL|final)\b',
    );

    for (var i = 0; i < codeLines.length; i++) {
      if (constDecl.hasMatch(codeLines[i])) continue;
      count += magicRegex.allMatches(codeLines[i]).length;
    }
    if (count > 5) {
      issues.add(Issue(
        title: 'Números mágicos',
        description: 'Se detectaron $count literales numéricos sin nombre. Los '
            '"números mágicos" reducen la legibilidad.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.style,
        suggestion: 'Extrae los valores constantes a variables con nombre '
            'descriptivo (p. ej. MAX_RETRIES = 5).',
      ));
    }
    return count;
  }

  void _checkFunctionLength(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    // Detecta bloques de función y mide su longitud por indentación/llaves.
    final funcStart = RegExp(
      r'(def\s+\w+|function\s+\w+|void\s+\w+|[A-Za-z_]\w*\s+\w+\s*\([^)]*\))\s*[{:]',
    );
    final matches = funcStart.allMatches(code).toList();
    for (final m in matches) {
      final startLine = _lineOf(code, m.start);
      final length = _estimateFunctionLength(code, m.start, language);
      if (length > 50) {
        issues.add(Issue(
          title: 'Función demasiado larga',
          description: 'La función que comienza en la línea $startLine tiene '
              '~$length líneas. Las funciones largas son difíciles de mantener.',
          severity: SeverityLevel.warning,
          category: AnalysisCategory.style,
          line: startLine,
          suggestion: 'Divide la función en funciones más pequeñas con '
              'responsabilidad única.',
        ));
      } else if (length > 30) {
        issues.add(Issue(
          title: 'Función larga',
          description: 'La función (~$length líneas) podría dividirse.',
          severity: SeverityLevel.info,
          category: AnalysisCategory.style,
          line: startLine,
        ));
      }
    }
  }

  int _estimateFunctionLength(
    String code,
    int start,
    ProgrammingLanguage language,
  ) {
    if (language == ProgrammingLanguage.python) {
      // Basado en indentación
      final afterStart = code.substring(start);
      final lines = afterStart.split('\n');
      if (lines.length < 2) return 0;
      final firstBodyLine = lines.skip(1).firstWhere(
        (l) => l.trim().isNotEmpty,
        orElse: () => '',
      );
      if (firstBodyLine.isEmpty) return 0;
      final indent = firstBodyLine.length - firstBodyLine.trimLeft().length;
      var length = 0;
      for (final l in lines.skip(1)) {
        if (l.trim().isEmpty) continue;
        final curIndent = l.length - l.trimLeft().length;
        if (curIndent < indent && l.trim().isNotEmpty) break;
        length++;
      }
      return length;
    } else {
      // Basado en llaves
      final afterStart = code.substring(start);
      var depth = 0;
      var started = false;
      var length = 0;
      for (var i = 0; i < afterStart.length; i++) {
        final ch = afterStart[i];
        if (ch == '{') {
          depth++;
          started = true;
        } else if (ch == '}') {
          depth--;
          if (started && depth == 0) break;
        } else if (ch == '\n' && started) {
          length++;
        }
      }
      return length;
    }
  }

  void _checkIndentation(List<String> lines, List<Issue> issues) {
    var tabCount = 0;
    var spaceCount = 0;
    for (final line in lines) {
      if (line.isEmpty) continue;
      if (line.startsWith('\t')) {
        tabCount++;
      } else if (line.startsWith('  ')) {
        spaceCount++;
      }
    }
    if (tabCount > 0 && spaceCount > 0) {
      issues.add(Issue(
        title: 'Indentación mixta',
        description: 'Se mezclan tabs y espacios para indentar. Esto puede '
            'causar errores en lenguajes como Python.',
        severity: SeverityLevel.warning,
        category: AnalysisCategory.style,
        suggestion: 'Elige un estilo (se recomiendan 4 espacios) y sé '
            'consistente.',
      ));
    }
  }

  void _checkIdentifierLength(
    String code,
    ProgrammingLanguage language,
    List<Issue> issues,
  ) {
    final identRegex = RegExp(r'\b([A-Za-z_]\w{25,})\b');
    final matches = identRegex.allMatches(code).toList();
    if (matches.length > 2) {
      issues.add(Issue(
        title: 'Identificadores muy largos',
        description: 'Se encontraron ${matches.length} identificadores con más '
            'de 25 caracteres. Pueden dificultar la lectura.',
        severity: SeverityLevel.info,
        category: AnalysisCategory.style,
        suggestion: 'Busca nombres más concisos sin perder claridad.',
      ));
    }
  }

  int _lineOf(String code, int offset) {
    return '\n'.allMatches(code.substring(0, offset)).length + 1;
  }

  double _averageLineLength(List<String> lines) {
    if (lines.isEmpty) return 0;
    return lines.fold<int>(0, (a, l) => a + l.length) / lines.length;
  }

  String _buildSummary(
    double score,
    List<Issue> issues,
    Map<String, dynamic> commentStats,
  ) {
    if (score >= 85) {
      return 'El estilo del código es excelente. Sigue buenas convenciones '
          'de formato y nomenclatura.';
    }
    if (score >= 70) {
      return 'El estilo es bueno en general, con algunos detalles menores que '
          'podrían mejorarse.';
    }
    if (score >= 50) {
      return 'El estilo presenta varios problemas de formato y convenciones '
          'que deberían corregirse.';
    }
    return 'El estilo del código necesita atención urgente. Revisa las '
        'convenciones de nombres, formato y comentarios.';
  }
}

class _DeclPattern {
  final RegExp regex;
  final _DeclKind kind;
  const _DeclPattern({required this.regex, required this.kind});
}

enum _DeclKind { variable, function }

class _NameViolation {
  final String title;
  final String description;
  final String suggestion;
  const _NameViolation({
    required this.title,
    required this.description,
    required this.suggestion,
  });
}

extension on NamingConvention {
  String get label {
    switch (this) {
      case NamingConvention.camelCase:
        return 'este lenguaje';
      case NamingConvention.snakeCase:
        return 'Python';
    }
  }
}
