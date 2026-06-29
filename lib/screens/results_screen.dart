import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/evaluation_result.dart';
import '../models/history_entry.dart';
import '../models/programming_language.dart';
import '../services/code_analyzer_service.dart';
import '../services/storage_service.dart';
import '../widgets/category_score_card.dart';
import '../widgets/code_view.dart';
import '../widgets/issue_tile.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/score_gauge.dart';
import '../widgets/severity_bar_chart.dart';

/// Pantalla de resultados de la evaluación.
class ResultsScreen extends StatefulWidget {
  final String code;
  final ProgrammingLanguage language;

  const ResultsScreen({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final CodeAnalyzerService _analyzer = CodeAnalyzerService();
  final StorageService _storage = StorageService();
  EvaluationResult? _result;
  bool _loading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    // Pequeño retardo para mostrar el estado de carga.
    await Future.delayed(const Duration(milliseconds: 400));
    final result = _analyzer.analyze(widget.code, widget.language);
    // Guardar en historial
    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      language: result.language,
      codePreview: widget.code.length > 120
          ? widget.code.substring(0, 120)
          : widget.code,
      logicScore: result.logic.score,
      efficiencyScore: result.efficiency.score,
      styleScore: result.style.score,
      overallScore: result.overallScore,
      grade: result.grade,
      evaluatedAt: result.evaluatedAt,
      totalLines: result.totalLines,
      issueCount: result.allIssues.length,
    );
    await _storage.addEntry(entry);
    if (mounted) {
      setState(() {
        _result = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: AppColors.emerald,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Analizando código...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Evaluando lógica, eficiencia y estilo',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final result = _result!;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Resultados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.language.brandColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.language.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.language.brandColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: _buildHeader(result)),
            SliverToBoxAdapter(child: _buildRadarSection(result)),
            SliverToBoxAdapter(child: _buildCategoriesSection(result)),
            SliverToBoxAdapter(child: _buildMetricsSection(result)),
            SliverToBoxAdapter(child: _buildIssuesSection(result)),
            SliverToBoxAdapter(child: _buildCodeSection(result)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(EvaluationResult result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScoreGauge(
                    score: result.overallScore,
                    label: '/ 100',
                    size: 160,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.grade,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: result.gradeColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Puntuación global',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarSection(EvaluationResult result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.radar, size: 18, color: AppColors.emerald),
                  const SizedBox(width: 8),
                  Text(
                    'Distribución de habilidades',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: RadarChartWidget(
                  logicScore: result.logic.score,
                  efficiencyScore: result.efficiency.score,
                  styleScore: result.style.score,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(EvaluationResult result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          for (final cs in result.categories) CategoryScoreCard(categoryScore: cs),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(EvaluationResult result) {
    final logicM = result.logic.metrics;
    final effM = result.efficiency.metrics;
    final styleM = result.style.metrics;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, size: 18, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Text(
                    'Métricas clave',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricPill(
                    label: 'Complejidad ciclomática',
                    value: '${logicM['cyclomaticComplexity'] ?? 0}',
                    color: AppColors.emerald,
                  ),
                  _MetricPill(
                    label: 'Anidamiento máx.',
                    value: '${logicM['maxNesting'] ?? 0}',
                    color: AppColors.teal,
                  ),
                  _MetricPill(
                    label: 'Complejidad temporal',
                    value: '${effM['bigO'] ?? '—'}',
                    color: AppColors.amber,
                  ),
                  _MetricPill(
                    label: 'Recursión',
                    value: (effM['isRecursive'] == true) ? 'Sí' : 'No',
                    color: (effM['isRecursive'] == true)
                        ? AppColors.orange
                        : AppColors.emerald,
                  ),
                  _MetricPill(
                    label: 'Líneas de código',
                    value: '${styleM['lineCount'] ?? result.totalLines}',
                    color: AppColors.teal,
                  ),
                  _MetricPill(
                    label: 'Comentarios',
                    value:
                        '${(((styleM['commentRatio'] ?? 0) as num) * 100).round()}%',
                    color: AppColors.emerald,
                  ),
                  _MetricPill(
                    label: 'Números mágicos',
                    value: '${styleM['magicNumbers'] ?? 0}',
                    color: AppColors.amber,
                  ),
                  _MetricPill(
                    label: 'Casos límite',
                    value: '${logicM['edgeCaseChecks'] ?? 0}',
                    color: AppColors.emerald,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssuesSection(EvaluationResult result) {
    final all = result.allIssues;
    final errors = all.where((i) => i.severity == SeverityLevel.error).length;
    final warnings = all.where((i) => i.severity == SeverityLevel.warning).length;
    final info = all.where((i) => i.severity == SeverityLevel.info).length;
    final success = all.where((i) => i.severity == SeverityLevel.success).length;

    final filters = ['Todos', 'Errores', 'Avisos', 'Info', 'Positivos'];
    final filtered = switch (_selectedFilter) {
      'Errores' => all.where((i) => i.severity == SeverityLevel.error).toList(),
      'Avisos' => all.where((i) => i.severity == SeverityLevel.warning).toList(),
      'Info' => all.where((i) => i.severity == SeverityLevel.info).toList(),
      'Positivos' =>
        all.where((i) => i.severity == SeverityLevel.success).toList(),
      _ => all,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.list_alt, size: 18, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Hallazgos (${all.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SeverityBarChart(
                errors: errors,
                warnings: warnings,
                info: info,
                successes: success,
              ),
              const SizedBox(height: 16),
              if (all.isNotEmpty)
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = filters[index];
                      final selected = f == _selectedFilter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.emerald
                                : AppColors.slate.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 40, color: AppColors.emerald),
                        const SizedBox(height: 8),
                        Text(
                          'No hay hallazgos en esta categoría',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Limita la altura para evitar listas infinitas con scroll anidado.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 600),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        IssueTile(issue: filtered[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeSection(EvaluationResult result) {
    final highlighted = <int>{};
    for (final issue in result.allIssues) {
      if (issue.line != null) highlighted.add(issue.line!);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.code, size: 18, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Text(
                    'Código evaluado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  if (highlighted.isNotEmpty)
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Líneas marcadas',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              CodeView(
                code: result.code,
                language: result.language,
                highlightedLines: highlighted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
