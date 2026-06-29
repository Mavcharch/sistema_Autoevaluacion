import '../models/evaluation_result.dart';
import '../models/programming_language.dart';
import 'efficiency_analyzer.dart';
import 'logic_analyzer.dart';
import 'style_analyzer.dart';

/// Servicio orquestador que ejecuta los tres analizadores
/// (lógica, eficiencia, estilo) y produce un resultado unificado.
class CodeAnalyzerService {
  final LogicAnalyzer _logicAnalyzer = LogicAnalyzer();
  final EfficiencyAnalyzer _efficiencyAnalyzer = EfficiencyAnalyzer();
  final StyleAnalyzer _styleAnalyzer = StyleAnalyzer();

  /// Analiza el código y devuelve un [EvaluationResult] completo.
  EvaluationResult analyze(String code, ProgrammingLanguage language) {
    final logic = _logicAnalyzer.analyze(code, language);
    final efficiency = _efficiencyAnalyzer.analyze(code, language);
    final style = _styleAnalyzer.analyze(code, language);

    return EvaluationResult(
      language: language,
      code: code,
      logic: logic,
      efficiency: efficiency,
      style: style,
      evaluatedAt: DateTime.now(),
    );
  }
}
