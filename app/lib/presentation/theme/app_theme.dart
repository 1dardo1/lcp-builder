import 'package:flutter/material.dart';

/// Punto único del look & feel de la app — antes vivía inline en `main.dart`
/// como un simple `ColorScheme.fromSeed(Colors.deepPurple)`.
///
/// La estética se inspira en COMP/CON (la herramienta oficial de Lancer que
/// consume estos `.lcp`): superficies oscuras de pizarra azulada y un acento
/// ámbar, con Material 3. Se ofrecen tema claro y oscuro reales; el oscuro es
/// el "héroe" (es lo que un máster de Lancer espera al abrir una herramienta
/// del juego) y `main.dart` arranca en oscuro. Todo se deriva de una semilla
/// para que el esquema M3 sea coherente; en oscuro se pisan las superficies
/// para conseguir la pizarra azulada en vez del gris neutro por defecto.
abstract final class AppTheme {
  /// Semilla ámbar: fija el color primario y M3 deriva el resto del esquema.
  static const _seed = Color(0xFFE0A73E);

  /// Acento secundario "tech" (cian apagado), para realces puntuales.
  static const _accent = Color(0xFF5BC8C0);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    var scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      secondary: _accent,
    );
    if (isDark) {
      // Pizarra azulada en toda la escala de superficies, no el gris neutro
      // que da M3 por defecto — es lo que le da el aire COMP/CON.
      scheme = scheme.copyWith(
        surface: const Color(0xFF11151B),
        surfaceContainerLowest: const Color(0xFF0C0F14),
        surfaceContainerLow: const Color(0xFF141A21),
        surfaceContainer: const Color(0xFF171E26),
        surfaceContainerHigh: const Color(0xFF1E2630),
        surfaceContainerHighest: const Color(0xFF26303C),
      );
    }

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = base.textTheme;

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      // Cabeceras con un pelín de tracking y peso — el toque "militar/tech"
      // sin meter una fuente propia (que arrastraría assets y CSP).
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surfaceContainer,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
    );
  }
}
