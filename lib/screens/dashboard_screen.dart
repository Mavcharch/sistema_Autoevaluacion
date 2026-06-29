import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/history_entry.dart';
import '../models/programming_language.dart';
import '../services/storage_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_chart.dart';

/// Pantalla de dashboard con análisis estadístico del progreso.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = StorageService();
  List<HistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _storage.getHistory();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.emerald)),
      );
    }

    if (_entries.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dashboard_outlined,
                      size: 64, color: AppColors.gray.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'Dashboard vacío',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Realiza tu primera evaluación para ver estadísticas aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final avgOverall = _avg(_entries.map((e) => e.overallScore));
    final avgLogic = _avg(_entries.map((e) => e.logicScore));
    final avgEff = _avg(_entries.map((e) => e.efficiencyScore));
    final avgStyle = _avg(_entries.map((e) => e.styleScore));
    final totalLines = _entries.fold<int>(0, (a, e) => a + e.totalLines);
    final totalIssues = _entries.fold<int>(0, (a, e) => a + e.issueCount);

    // Datos de tendencia (últimas 10 en orden cronológico)
    final recent = _entries.reversed.take(10).toList();
    final scores = recent.map((e) => e.overallScore).toList();
    final labels = recent
        .map((e) =>
            '${e.evaluatedAt.day}/${e.evaluatedAt.month}')
        .toList();

    // Distribución por lenguaje
    final langCounts = <ProgrammingLanguage, int>{};
    for (final e in _entries) {
      langCounts[e.language] = (langCounts[e.language] ?? 0) + 1;
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.emerald,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                title: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      // Tarjetas de KPI
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Promedio global',
                              value: avgOverall.round().toString(),
                              icon: Icons.trending_up,
                              color: AppColors.emerald,
                              subtitle: '${_entries.length} evaluaciones',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              title: 'Líneas analizadas',
                              value: _formatNumber(totalLines),
                              icon: Icons.code,
                              color: AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Problemas detectados',
                              value: _formatNumber(totalIssues),
                              icon: Icons.bug_report_outlined,
                              color: AppColors.amber,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              title: 'Lenguajes usados',
                              value: '${langCounts.length}',
                              icon: Icons.translate,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tendencia
                      _SectionCard(
                        icon: Icons.show_chart,
                        title: 'Evolución del puntaje',
                        child: TrendChart(scores: scores, labels: labels),
                      ),
                      const SizedBox(height: 12),
                      // Promedio por categoría
                      _SectionCard(
                        icon: Icons.bar_chart,
                        title: 'Promedio por categoría',
                        child: _CategoryBars(
                          logic: avgLogic,
                          efficiency: avgEff,
                          style: avgStyle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Distribución por lenguaje
                      _SectionCard(
                        icon: Icons.pie_chart_outline,
                        title: 'Distribución por lenguaje',
                        child: _LanguageDistribution(counts: langCounts),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _avg(Iterable<double> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return list.reduce((a, b) => a + b) / list.length;
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.emerald),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  final double logic;
  final double efficiency;
  final double style;

  const _CategoryBars({
    required this.logic,
    required this.efficiency,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BarRow(label: 'Lógica', value: logic, color: AppColors.emerald),
        const SizedBox(height: 12),
        _BarRow(label: 'Eficiencia', value: efficiency, color: AppColors.amber),
        const SizedBox(height: 12),
        _BarRow(label: 'Estilo', value: style, color: AppColors.teal),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value.round().toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _LanguageDistribution extends StatelessWidget {
  final Map<ProgrammingLanguage, int> counts;

  const _LanguageDistribution({required this.counts});

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: [
        for (final entry in sorted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: entry.key.brandColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: entry.value / total,
                      minHeight: 8,
                      backgroundColor: entry.key.brandColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key.brandColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 32,
                  child: Text(
                    entry.value.toString(),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
