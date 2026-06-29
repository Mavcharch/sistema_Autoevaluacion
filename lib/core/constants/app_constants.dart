/// Constantes globales de CodeJudge.
class AppConstants {
  AppConstants._();

  static const String appName = 'CodeJudge';
  static const String appTagline = 'Evaluación automática de código';

  /// Puntaje mínimo aprobatorio.
  static const double passingScore = 70.0;

  /// Longitud máxima recomendada de línea.
  static const int maxLineLength = 100;

  /// Categorías de evaluación.
  static const List<String> categories = ['Lógica', 'Eficiencia', 'Estilo'];
}
