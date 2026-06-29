import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/programming_language.dart';

/// Pantalla de inicio con acceso rápido al editor y resumen.
class HomeScreen extends StatelessWidget {
  final VoidCallback? onStartEvaluation;
  final VoidCallback? onOpenSettings;

  const HomeScreen({
    super.key,
    this.onStartEvaluation,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.emerald, AppColors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.code_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CodeJudge',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Evaluación automática de código',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onOpenSettings,
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    tooltip: 'Ajustes',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Hero
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.emerald,
                      AppColors.emeraldDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mejora tu código con IA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analiza la lógica, eficiencia y estilo de tus '
                      'programas y recibe retroalimentación detallada al instante.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: onStartEvaluation,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.emeraldDark,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text(
                          'Empezar evaluación',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Capacidades
              Text(
                '¿Qué evalúa CodeJudge?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              const _FeatureCard(
                icon: Icons.psychology_outlined,
                color: AppColors.emerald,
                title: 'Lógica',
                description:
                    'Complejidad ciclomática, anidamiento, casos límite y '
                    'control de flujo.',
              ),
              const _FeatureCard(
                icon: Icons.speed_outlined,
                color: AppColors.amber,
                title: 'Eficiencia',
                description:
                    'Estimación de complejidad Big-O, recursión y uso de '
                    'estructuras de datos.',
              ),
              const _FeatureCard(
                icon: Icons.palette_outlined,
                color: AppColors.teal,
                title: 'Estilo',
                description:
                    'Convenciones de nombres, formato, comentarios y '
                    'legibilidad general.',
              ),
              const SizedBox(height: 24),
              // Lenguajes soportados
              Text(
                'Lenguajes soportados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final lang in ProgrammingLanguage.values)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: lang.brandColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: lang.brandColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: lang.brandColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lang.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: lang.brandColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Cómo funciona
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.slate.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline,
                            size: 18, color: AppColors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'Cómo funciona',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StepRow(
                      number: 1,
                      text: 'Elige tu lenguaje de programación',
                    ),
                    _StepRow(
                      number: 2,
                      text: 'Escribe o pega tu código',
                    ),
                    _StepRow(
                      number: 3,
                      text: 'Recibe análisis detallado al instante',
                    ),
                    _StepRow(
                      number: 4,
                      text: 'Revisa las sugerencias y mejora',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.emerald,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
