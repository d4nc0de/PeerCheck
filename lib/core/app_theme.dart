import 'package:flutter/material.dart';

@immutable
class RolePalette extends ThemeExtension<RolePalette> {
  const RolePalette({
    required this.profesorAccent,
    required this.estudianteAccent,
    required this.profesorCard,
    required this.estudianteCard,
    required this.surfaceSoft,
  });

  final Color profesorAccent;
  final Color estudianteAccent;
  final Color profesorCard;
  final Color estudianteCard;
  final Color surfaceSoft;

  @override
  RolePalette copyWith({
    Color? profesorAccent,
    Color? estudianteAccent,
    Color? profesorCard,
    Color? estudianteCard,
    Color? surfaceSoft,
  }) {
    return RolePalette(
      profesorAccent: profesorAccent ?? this.profesorAccent,
      estudianteAccent: estudianteAccent ?? this.estudianteAccent,
      profesorCard: profesorCard ?? this.profesorCard,
      estudianteCard: estudianteCard ?? this.estudianteCard,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
    );
  }

  @override
  RolePalette lerp(ThemeExtension<RolePalette>? other, double t) {
    if (other is! RolePalette) {
      return this;
    }
    return RolePalette(
      profesorAccent: Color.lerp(profesorAccent, other.profesorAccent, t)!,
      estudianteAccent: Color.lerp(
        estudianteAccent,
        other.estudianteAccent,
        t,
      )!,
      profesorCard: Color.lerp(profesorCard, other.profesorCard, t)!,
      estudianteCard: Color.lerp(estudianteCard, other.estudianteCard, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
    );
  }
}

class AppTheme {
  static final light = ThemeData.light().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const RolePalette(
        profesorAccent: Color(0xFF026CD2), // Azul para profesor
        estudianteAccent: Color(0xFFFFD60A), // Amarillo para estudiante
        profesorCard: Color(0xFFE3F2FD), // Fondo claro azul (derivado del accent)
        estudianteCard: Color(0xFFFFF8E1), // Fondo claro amarillo
        surfaceSoft: Color(0xFFF8F9FA), // Fondo gris suave
      ),
    ],
  );

  static final dark = ThemeData.dark().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const RolePalette(
        profesorAccent: Color(0xFF026CD2), // Azul para profesor
        estudianteAccent: Color(0xFFFFD60A), // Amarillo para estudiante
        profesorCard: Color(0xFF0D47A1), // Fondo oscuro azul (derivado del accent)
        estudianteCard: Color(0xFF2D2A1D), // Fondo oscuro amarillo
        surfaceSoft: Color(0xFF1A1C1E), // Fondo oscuro gris
      ),
    ],
  );
}

