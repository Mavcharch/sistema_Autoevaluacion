import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/issue.dart';

/// Tarjeta que muestra un problema individual detectado.
class IssueTile extends StatelessWidget {
  final Issue issue;

  const IssueTile({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.severityColor(issue.severity);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SeverityIcon(severity: issue.severity, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        issue.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (issue.line != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Línea ${issue.line}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  issue.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                if (issue.suggestion != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 16, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            issue.suggestion!,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityIcon extends StatelessWidget {
  final SeverityLevel severity;
  final Color color;

  const _SeverityIcon({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    final icon = switch (severity) {
      SeverityLevel.error => Icons.error_outline,
      SeverityLevel.warning => Icons.warning_amber_rounded,
      SeverityLevel.info => Icons.info_outline,
      SeverityLevel.success => Icons.check_circle_outline,
    };
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
