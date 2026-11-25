import 'package:material_ui/material_ui.dart';

/// Paleta "Corporate Blue" del panel (misma que las variables de Figma).
/// El panel usa siempre esta paleta; el color propio del distribuidor
/// (`config_tema`) se aplica en la app de sus clientes.
abstract final class ColoresPanel {
  static const Color primario900 = Color(0xFF0B2A5B);
  static const Color primario700 = Color(0xFF123E84);
  static const Color primario500 = Color(0xFF1F6FEB);
  static const Color primario100 = Color(0xFFE6EFFD);
  static const Color primario50 = Color(0xFFF3F7FE);

  static const Color acento500 = Color(0xFF14B8A6);
  static const Color acento100 = Color(0xFFDDF7F3);

  static const Color neutro900 = Color(0xFF0F172A);
  static const Color neutro700 = Color(0xFF334155);
  static const Color neutro500 = Color(0xFF64748B);
  static const Color neutro300 = Color(0xFFCBD5E1);
  static const Color neutro200 = Color(0xFFE2E8F0);
  static const Color neutro100 = Color(0xFFF1F5F9);
  static const Color neutro50 = Color(0xFFF8FAFC);
  static const Color blanco = Color(0xFFFFFFFF);

  static const Color exito500 = Color(0xFF16A34A);
  static const Color exito100 = Color(0xFFDCFCE7);
  static const Color aviso500 = Color(0xFFD97706);
  static const Color aviso100 = Color(0xFFFEF3C7);
  static const Color peligro500 = Color(0xFFDC2626);
  static const Color peligro100 = Color(0xFFFEE2E2);
}

/// Tema del panel web.
ThemeData temaPanel() {
  final esquema =
      ColorScheme.fromSeed(
        seedColor: ColoresPanel.primario500,
        brightness: Brightness.light,
      ).copyWith(
        primary: ColoresPanel.primario500,
        onPrimary: ColoresPanel.blanco,
        secondary: ColoresPanel.acento500,
        onSecondary: ColoresPanel.blanco,
        surface: ColoresPanel.blanco,
        // Sin el tinte lila de Material 3 en diálogos, menús y chips.
        surfaceContainerLowest: ColoresPanel.blanco,
        surfaceContainerLow: ColoresPanel.blanco,
        surfaceContainer: ColoresPanel.blanco,
        surfaceContainerHigh: ColoresPanel.blanco,
        surfaceContainerHighest: ColoresPanel.neutro100,
        surfaceTint: Colors.transparent,
        secondaryContainer: ColoresPanel.primario100,
        onSecondaryContainer: ColoresPanel.primario700,
        onSurface: ColoresPanel.neutro900,
        onSurfaceVariant: ColoresPanel.neutro500,
        outline: ColoresPanel.neutro300,
        outlineVariant: ColoresPanel.neutro200,
        error: ColoresPanel.peligro500,
      );

  final base = ThemeData(useMaterial3: true, colorScheme: esquema);
  final borde = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: ColoresPanel.neutro300),
  );

  return base.copyWith(
    scaffoldBackgroundColor: ColoresPanel.neutro50,
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        color: ColoresPanel.neutro900,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: ColoresPanel.neutro900,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: ColoresPanel.neutro700,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColoresPanel.blanco,
      foregroundColor: ColoresPanel.neutro900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: ColoresPanel.blanco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde.copyWith(
        borderSide: const BorderSide(color: ColoresPanel.primario500, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        side: const BorderSide(color: ColoresPanel.primario500, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    // Aviso flotante y angosto: a todo lo ancho tapaba el menú lateral.
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      width: 420,
      backgroundColor: ColoresPanel.neutro900,
    ),
    dividerTheme: const DividerThemeData(
      color: ColoresPanel.neutro200,
      thickness: 1,
      space: 1,
    ),
  );
}
