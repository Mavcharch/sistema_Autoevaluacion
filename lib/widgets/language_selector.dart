import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/programming_language.dart';

/// Selector horizontal de lenguaje de programación.
class LanguageSelector extends StatelessWidget {
  final ProgrammingLanguage selected;
  final ValueChanged<ProgrammingLanguage> onChanged;

  const LanguageSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ProgrammingLanguage.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final lang = ProgrammingLanguage.values[index];
          final isSelected = lang == selected;
          return GestureDetector(
            onTap: () => onChanged(lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? lang.brandColor
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? lang.brandColor
                      : AppColors.slate.withValues(alpha: 0.12),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                lang.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
