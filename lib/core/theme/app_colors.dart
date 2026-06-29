import 'package:flutter/material.dart';

/// Paleta de colores profesional de CodeJudge.
/// Se evitan tonos índigo/azul según los estándares de diseño.
/// Estética "developer": esmeralda/teal con acentos ámbar y rosa.
class AppColors {
  AppColors._();

  // ---- Esmeralda (primario) ----
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color teal = Color(0xFF14B8A6);

  // ---- Ámbar (acento / advertencias) ----
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color orange = Color(0xFFF97316);

  // ---- Rosa / Rojo (errores) ----
  static const Color rose = Color(0xFFF43F5E);
  static const Color red = Color(0xFFEF4444);

  // ---- Neutros ----
  static const Color slate = Color(0xFF0F172A);
  static const Color slateLight = Color(0xFF1E293B);
  static const Color slateMuted = Color(0xFF334155);
  static const Color gray = Color(0xFF64748B);
  static const Color grayLight = Color(0xFF94A3B8);

  /// Devuelve un color según la severidad del problema.
  static Color severityColor(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.error:
        return red;
      case SeverityLevel.warning:
        return amber;
      case SeverityLevel.info:
        return teal;
      case SeverityLevel.success:
        return emerald;
    }
  }

  /// Devuelve un color según la puntuación (0-100).
  static Color scoreColor(double score) {
    if (score >= 85) return emerald;
    if (score >= 70) return teal;
    if (score >= 50) return amber;
    return rose;
  }
}

/// Niveles de severidad para los problemas detectados.
enum SeverityLevel {
  error,
  warning,
  info,
  success,
}
