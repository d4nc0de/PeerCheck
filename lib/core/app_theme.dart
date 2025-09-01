import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Paleta de colores específica para el Home (Profesor / Estudiante)
@immutable
class RolePalette extends ThemeExtension<RolePalette> {
  final Color profesorAccent;   // Azul botón/acentos
  final Color profesorCard;     // Azul suave tarjetas
  final Color estudianteAccent; // Amarillo botón/acentos
  final Color estudianteCard;   // Amarillo suave tarjetas
  final Color surfaceSoft;      // Fondo gris suave de la zona de lista

  const RolePalette({
    required this.profesorAccent,
    required this.profesorCard,
    required this.estudianteAccent,
    required this.estudianteCard,
    required this.surfaceSoft,
  });

  @override
  RolePalette copyWith({
    Color? profesorAccent,
    Color? profesorCard,
    Color? estudianteAccent,
    Color? estudianteCard,
    Color? surfaceSoft,
  }) {
    return RolePalette(
      profesorAccent: profesorAccent ?? this.profesorAccent,
      profesorCard: profesorCard ?? this.profesorCard,
      estudianteAccent: estudianteAccent ?? this.estudianteAccent,
      estudianteCard: estudianteCard ?? this.estudianteCard,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
    );
  }

  @override
  RolePalette lerp(ThemeExtension<RolePalette>? other, double t) {
    if (other is! RolePalette) return this;
    return RolePalette(
      profesorAccent: Color.lerp(profesorAccent, other.profesorAccent, t)!,
      profesorCard: Color.lerp(profesorCard, other.profesorCard, t)!,
      estudianteAccent: Color.lerp(estudianteAccent, other.estudianteAccent, t)!,
      estudianteCard: Color.lerp(estudianteCard, other.estudianteCard, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
    );
  }
}

/// The [AppTheme] defines light and dark themes for the app.
abstract final class AppTheme {
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.yellowM3,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),

    // 👇 Aquí colgamos nuestra extensión
    extensions: const <ThemeExtension<dynamic>>[
      RolePalette(
        profesorAccent: Color(0xFF157BD9),
        profesorCard: Color(0xFFD6E9FF),
        estudianteAccent: Color(0xFFF6D74B),
        estudianteCard: Color(0xFFF7EBA7),
        surfaceSoft: Color(0xFFF1F2F4),
      ),
    ],
  );

  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.yellowM3,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),

    // 👇 Misma extensión (puedes ajustar tonos para dark si quieres)
    extensions: const <ThemeExtension<dynamic>>[
      RolePalette(
        profesorAccent: Color(0xFF6CB3FF),
        profesorCard: Color(0xFF2A3E55),
        estudianteAccent: Color(0xFFFFEA79),
        estudianteCard: Color(0xFF544D2E),
        surfaceSoft: Color(0xFF121418),
      ),
    ],
  );
}
