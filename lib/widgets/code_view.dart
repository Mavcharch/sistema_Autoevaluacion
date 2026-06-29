import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../models/programming_language.dart';

/// Visor de código con resaltado de sintaxis ligero y números de línea.
class CodeView extends StatelessWidget {
  final String code;
  final ProgrammingLanguage language;
  final Set<int> highlightedLines;

  const CodeView({
    super.key,
    required this.code,
    required this.language,
    this.highlightedLines = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lines = code.split('\n');
    final lineDigits = lines.length.toString().length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.slate.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < lines.length; i++)
                _buildLine(
                  lines[i],
                  i + 1,
                  lineDigits,
                  isDark,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(String line, int number, int digits, bool isDark) {
    final isHighlighted = highlightedLines.contains(number);
    return Container(
      color: isHighlighted
          ? AppColors.amber.withValues(alpha: isDark ? 0.12 : 0.16)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: digits * 9.0 + 12,
              child: Text(
                '$number',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12.5,
                  height: 1.55,
                  color: isDark
                      ? AppColors.gray.withValues(alpha: 0.5)
                      : AppColors.gray.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RichLine(
                line: line,
                language: language,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Línea de código con resaltado basado en tokens simples.
class _RichLine extends StatelessWidget {
  final String line;
  final ProgrammingLanguage language;
  final bool isDark;

  const _RichLine({
    required this.line,
    required this.language,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          height: 1.55,
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
        ),
        children: _buildSpans(line),
      ),
      softWrap: true,
    );
  }

  List<TextSpan> _buildSpans(String line) {
    final trimmed = line.trim();
    // Comentario completo de línea
    if (trimmed.startsWith('//') || trimmed.startsWith('#')) {
      return [
        TextSpan(
          text: line,
          style: GoogleFonts.jetBrainsMono(
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    final spans = <TextSpan>[];
    // Tokeniza por palabras, strings y números.
    // Usa raw string con triple comillas dobles para poder incluir " y '.
    final tokenRegex = RegExp(
      r'''"[^"]*"|'[^']*'|\b\d+\.?\d*\b|\b\w+\b|[^\w\s]|\s+''',
    );
    for (final match in tokenRegex.allMatches(line)) {
      final token = match.group(0)!;
      spans.add(TextSpan(text: token, style: _styleFor(token)));
    }
    if (spans.isEmpty) return [TextSpan(text: line)];
    return spans;
  }

  TextStyle _styleFor(String token) {
    // Strings (dobles o simples)
    if ((token.startsWith('"') && token.endsWith('"')) ||
        (token.startsWith("'") && token.endsWith("'"))) {
      return GoogleFonts.jetBrainsMono(
        color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
      );
    }
    // Números
    if (RegExp(r'^\d+\.?\d*$').hasMatch(token)) {
      return GoogleFonts.jetBrainsMono(
        color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
      );
    }
    // Palabras clave
    if (language.keywords.contains(token)) {
      return GoogleFonts.jetBrainsMono(
        color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
        fontWeight: FontWeight.w600,
      );
    }
    // Booleanos / null
    if (const {'true', 'false', 'null', 'None', 'True', 'False', 'nullptr',
            'undefined'}.contains(token)) {
      return GoogleFonts.jetBrainsMono(
        color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C),
      );
    }
    return GoogleFonts.jetBrainsMono();
  }
}
