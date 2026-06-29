import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/category_score.dart';
import '../models/programming_language.dart';

/// Tarjeta que resume una categoría de evaluación con barra animada.
class CategoryScoreCard extends StatefulWidget {
  final CategoryScore categoryScore;
  final bool animate;

  const CategoryScoreCard({
    super.key,
    required this.categoryScore,
    this.animate = true,
  });

  @override
  State<CategoryScoreCard> createState() => _CategoryScoreCardState();
}

class _CategoryScoreCardState extends State<CategoryScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progress = Tween<double>(begin: 0, end: widget.categoryScore.score / 100)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.categoryScore;
    final color = AppColors.scoreColor(cs.score);
    final counts = cs.severityCounts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_categoryIcon(cs.category), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cs.category.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        cs.category.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  cs.score.round().toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    value: _progress.value,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cs.summary,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (counts[SeverityLevel.error]! > 0)
                  _CountChip(
                    label: '${counts[SeverityLevel.error]} errores',
                    color: AppColors.red,
                    icon: Icons.error_outline,
                  ),
                if (counts[SeverityLevel.warning]! > 0)
                  _CountChip(
                    label: '${counts[SeverityLevel.warning]} avisos',
                    color: AppColors.amber,
                    icon: Icons.warning_amber_rounded,
                  ),
                if (counts[SeverityLevel.info]! > 0)
                  _CountChip(
                    label: '${counts[SeverityLevel.info]} info',
                    color: AppColors.teal,
                    icon: Icons.info_outline,
                  ),
                if (counts[SeverityLevel.success]! > 0)
                  _CountChip(
                    label: '${counts[SeverityLevel.success]} positivos',
                    color: AppColors.emerald,
                    icon: Icons.check_circle_outline,
                  ),
                if (cs.issues.isEmpty)
                  _CountChip(
                    label: 'Sin hallazgos',
                    color: AppColors.emerald,
                    icon: Icons.check_circle,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.logic:
        return Icons.psychology_outlined;
      case AnalysisCategory.efficiency:
        return Icons.speed_outlined;
      case AnalysisCategory.style:
        return Icons.palette_outlined;
    }
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CountChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
