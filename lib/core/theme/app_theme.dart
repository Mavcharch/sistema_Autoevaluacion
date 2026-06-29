import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema de la aplicación CodeJudge (claro y oscuro).
class AppTheme {
  AppTheme._();

  static const Color _lightBg = Color(0xFFF8FAFC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _darkBg = Color(0xFF0B1120);
  static const Color _darkSurface = Color(0xFF111827);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return _buildTheme(base, Brightness.light);
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return _buildTheme(base, Brightness.dark);
  }

  static ThemeData _buildTheme(ThemeData base, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final seed = AppColors.emerald;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: AppColors.emerald,
      secondary: AppColors.amber,
      tertiary: AppColors.teal,
      error: AppColors.red,
      surface: isDark ? _darkSurface : _lightSurface,
    );

    final mono = GoogleFonts.jetBrainsMono();
    final sans = GoogleFonts.inter();

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? _darkBg : _lightBg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        titleLarge: sans.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: sans.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        labelLarge: sans.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? _darkBg : _lightBg,
        foregroundColor: isDark ? Colors.white : AppColors.slate,
        titleTextStyle: sans.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.slate,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? _darkSurface : _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.slate.withValues(alpha: 0.08),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: sans.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.emeraldDark,
          side: const BorderSide(color: AppColors.emerald),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.slate.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.slate.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.slate.withValues(alpha: 0.06),
        labelStyle: sans.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.slate,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? _darkSurface : _lightSurface,
        indicatorColor: AppColors.emerald.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          sans.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.emerald);
          }
          return IconThemeData(
            color: isDark ? AppColors.grayLight : AppColors.gray,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.slate.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
      extensions: [
        AppMonospaceTheme(mono: mono),
      ],
    );
  }
}

/// Extensión de tema para tipografía monoespaciada (código).
class AppMonospaceTheme extends ThemeExtension<AppMonospaceTheme> {
  final TextStyle mono;

  const AppMonospaceTheme({required this.mono});

  @override
  AppMonospaceTheme copyWith({TextStyle? mono}) {
    return AppMonospaceTheme(mono: mono ?? this.mono);
  }

  @override
  AppMonospaceTheme lerp(AppMonospaceTheme? other, double t) {
    if (other is! AppMonospaceTheme) return this;
    return AppMonospaceTheme(
      mono: TextStyle.lerp(mono, other.mono, t) ?? mono,
    );
  }
}

/// Helper para acceder al tema monoespaciado.
extension MonospaceX on BuildContext {
  TextStyle get mono => Theme.of(this).extension<AppMonospaceTheme>()!.mono;
}
