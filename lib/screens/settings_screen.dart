import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Pantalla de ajustes.
class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              title: Text(
                'Ajustes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Apariencia'),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: isDarkMode,
                            onChanged: onThemeChanged,
                            secondary: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.slate.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isDarkMode
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: isDarkMode
                                    ? AppColors.amber
                                    : AppColors.orange,
                                size: 20,
                              ),
                            ),
                            title: const Text(
                              'Modo oscuro',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              isDarkMode
                                  ? 'Tema oscuro activado'
                                  : 'Tema claro activado',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Sobre la app'),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.info_outline,
                                  color: AppColors.emerald, size: 20),
                            ),
                            title: const Text(
                              'Versión',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Text(
                              '1.0.0',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.gray,
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.code,
                                  color: AppColors.teal, size: 20),
                            ),
                            title: const Text(
                              'Tecnología',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Text(
                              'Flutter · Dart',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.gray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Criterios de evaluación'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _CriterionRow(
                              icon: Icons.psychology_outlined,
                              color: AppColors.emerald,
                              title: 'Lógica',
                              points: [
                                'Complejidad ciclomática',
                                'Profundidad de anidamiento',
                                'Manejo de casos límite',
                                'Bucles infinitos',
                              ],
                            ),
                            SizedBox(height: 16),
                            _CriterionRow(
                              icon: Icons.speed_outlined,
                              color: AppColors.amber,
                              title: 'Eficiencia',
                              points: [
                                'Complejidad Big-O',
                                'Bucles anidados',
                                'Recursión y memoización',
                                'Operaciones costosas',
                              ],
                            ),
                            SizedBox(height: 16),
                            _CriterionRow(
                              icon: Icons.palette_outlined,
                              color: AppColors.teal,
                              title: 'Estilo',
                              points: [
                                'Convenciones de nombres',
                                'Longitud de líneas y funciones',
                                'Densidad de comentarios',
                                'Números mágicos',
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.gray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CriterionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> points;

  const _CriterionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in points)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
