import 'package:flutter/material.dart';

/// Lenguajes de programación soportados por CodeJudge.
enum ProgrammingLanguage {
  python,
  javascript,
  java,
  cpp,
  dart;

  /// Nombre legible.
  String get label {
    switch (this) {
      case ProgrammingLanguage.python:
        return 'Python';
      case ProgrammingLanguage.javascript:
        return 'JavaScript';
      case ProgrammingLanguage.java:
        return 'Java';
      case ProgrammingLanguage.cpp:
        return 'C++';
      case ProgrammingLanguage.dart:
        return 'Dart';
    }
  }

  /// Extensión de archivo típica.
  String get extension {
    switch (this) {
      case ProgrammingLanguage.python:
        return '.py';
      case ProgrammingLanguage.javascript:
        return '.js';
      case ProgrammingLanguage.java:
        return '.java';
      case ProgrammingLanguage.cpp:
        return '.cpp';
      case ProgrammingLanguage.dart:
        return '.dart';
    }
  }

  /// Estilo de nombres recomendado para identificadores.
  NamingConvention get namingConvention {
    switch (this) {
      case ProgrammingLanguage.python:
        return NamingConvention.snakeCase;
      case ProgrammingLanguage.javascript:
      case ProgrammingLanguage.java:
      case ProgrammingLanguage.cpp:
      case ProgrammingLanguage.dart:
        return NamingConvention.camelCase;
    }
  }

  /// Color de marca por lenguaje (sin usar azul/índigo).
  Color get brandColor {
    switch (this) {
      case ProgrammingLanguage.python:
        return const Color(0xFF14B8A6); // teal
      case ProgrammingLanguage.javascript:
        return const Color(0xFFF59E0B); // amber
      case ProgrammingLanguage.java:
        return const Color(0xFFF97316); // orange
      case ProgrammingLanguage.cpp:
        return const Color(0xFF10B981); // emerald
      case ProgrammingLanguage.dart:
        return const Color(0xFF34D399); // emerald light
    }
  }

  /// Palabras clave del lenguaje para resaltado.
  Set<String> get keywords {
    switch (this) {
      case ProgrammingLanguage.python:
        return const {
          'def', 'return', 'if', 'elif', 'else', 'for', 'while', 'in', 'not',
          'and', 'or', 'import', 'from', 'as', 'class', 'try', 'except',
          'finally', 'with', 'lambda', 'pass', 'break', 'continue', 'global',
          'nonlocal', 'yield', 'raise', 'assert', 'del', 'is', 'None', 'True',
          'False', 'self',
        };
      case ProgrammingLanguage.javascript:
        return const {
          'function', 'return', 'if', 'else', 'for', 'while', 'const', 'let',
          'var', 'class', 'extends', 'new', 'this', 'super', 'import', 'export',
          'from', 'default', 'async', 'await', 'try', 'catch', 'finally',
          'throw', 'typeof', 'instanceof', 'break', 'continue', 'switch',
          'case', 'do', 'in', 'of', 'null', 'undefined', 'true', 'false',
        };
      case ProgrammingLanguage.java:
        return const {
          'public', 'private', 'protected', 'class', 'interface', 'extends',
          'implements', 'new', 'return', 'if', 'else', 'for', 'while', 'do',
          'switch', 'case', 'break', 'continue', 'static', 'final', 'void',
          'int', 'double', 'float', 'long', 'short', 'byte', 'char', 'boolean',
          'String', 'try', 'catch', 'finally', 'throw', 'throws', 'import',
          'package', 'this', 'super', 'null', 'true', 'false', 'instanceof',
        };
      case ProgrammingLanguage.cpp:
        return const {
          'int', 'double', 'float', 'char', 'bool', 'void', 'long', 'short',
          'unsigned', 'const', 'static', 'return', 'if', 'else', 'for',
          'while', 'do', 'switch', 'case', 'break', 'continue', 'class',
          'struct', 'public', 'private', 'protected', 'new', 'delete', 'this',
          'virtual', 'override', 'namespace', 'using', 'include', 'template',
          'typename', 'true', 'false', 'nullptr', 'try', 'catch', 'throw',
          'auto', 'vector', 'string',
        };
      case ProgrammingLanguage.dart:
        return const {
          'void', 'var', 'final', 'const', 'late', 'int', 'double', 'String',
          'bool', 'List', 'Map', 'Set', 'dynamic', 'return', 'if', 'else',
          'for', 'while', 'do', 'switch', 'case', 'break', 'continue', 'class',
          'extends', 'implements', 'with', 'mixin', 'abstract', 'interface',
          'new', 'this', 'super', 'static', 'async', 'await', 'Future', 'try',
          'catch', 'finally', 'throw', 'rethrow', 'import', 'export', 'library',
          'part', 'true', 'false', 'null', 'is', 'as', 'in',
        };
    }
  }
}

/// Convenciones de nombres.
enum NamingConvention {
  camelCase,
  snakeCase,
}

/// Categoría de análisis.
enum AnalysisCategory {
  logic,
  efficiency,
  style;

  String get label {
    switch (this) {
      case AnalysisCategory.logic:
        return 'Lógica';
      case AnalysisCategory.efficiency:
        return 'Eficiencia';
      case AnalysisCategory.style:
        return 'Estilo';
    }
  }

  String get description {
    switch (this) {
      case AnalysisCategory.logic:
        return 'Correctitud, control de flujo y manejo de casos límite';
      case AnalysisCategory.efficiency:
        return 'Complejidad temporal y espacial, estructuras de datos';
      case AnalysisCategory.style:
        return 'Convenciones de nombres, formato y legibilidad';
    }
  }
}
