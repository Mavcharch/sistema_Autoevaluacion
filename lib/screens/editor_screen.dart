import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../models/programming_language.dart';
import '../services/code_samples.dart';
import '../widgets/language_selector.dart';

/// Pantalla del editor de código.
class EditorScreen extends StatefulWidget {
  final ProgrammingLanguage initialLanguage;
  final String? initialCode;

  const EditorScreen({
    super.key,
    this.initialLanguage = ProgrammingLanguage.python,
    this.initialCode,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late ProgrammingLanguage _language = widget.initialLanguage;
  late TextEditingController _controller;
  int _charCount = 0;
  int _lineCount = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCode ??
        CodeSamples.sampleFor(widget.initialLanguage) ??
        '';
    _controller = TextEditingController(text: initial);
    _updateCounts();
    _controller.addListener(_updateCounts);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCounts);
    _controller.dispose();
    super.dispose();
  }

  void _updateCounts() {
    final text = _controller.text;
    setState(() {
      _charCount = text.length;
      _lineCount = text.isEmpty ? 0 : text.split('\n').length;
    });
  }

  void _loadSample() {
    final sample = CodeSamples.sampleFor(_language) ?? '';
    _controller.text = sample;
  }

  void _clear() {
    _controller.clear();
  }

  void _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _controller.text = data!.text!;
    }
  }

  void _onLanguageChanged(ProgrammingLanguage lang) {
    setState(() => _language = lang);
  }

  void _analyze() {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Escribe o pega código para analizar'),
          backgroundColor: AppColors.amber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    Navigator.of(context).pushNamed(
      '/results',
      arguments: {
        'code': _controller.text,
        'language': _language,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Selector de lenguaje
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: LanguageSelector(
                selected: _language,
                onChanged: _onLanguageChanged,
              ),
            ),
            // Barra de acciones rápidas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _ActionChip(
                    icon: Icons.code,
                    label: 'Ejemplo',
                    onTap: _loadSample,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.content_paste,
                    label: 'Pegar',
                    onTap: _paste,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.delete_outline,
                    label: 'Limpiar',
                    onTap: _clear,
                  ),
                  const Spacer(),
                  Text(
                    '$_lineCount líneas · $_charCount car.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Editor
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.slate.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    hintText: 'Escribe o pega tu código aquí...',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: isDark
                          ? AppColors.gray.withValues(alpha: 0.4)
                          : AppColors.gray.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botón analizar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _analyze,
                  icon: const Icon(Icons.analytics_rounded),
                  label: const Text(
                    'Analizar código',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      visualDensity: VisualDensity.compact,
    );
  }
}
