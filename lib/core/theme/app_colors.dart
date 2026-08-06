import 'package:flutter/material.dart';

abstract class AppColors {
  // Background & Surfaces
  static const Color background = Color(0xFF0B141B);
  static const Color surfaceContainerLow = Color(0xFF141D24);
  static const Color surfaceContainer = Color(0xFF182128);
  static const Color surfaceContainerHigh = Color(0xFF222B33);
  static const Color surfaceContainerHighest = Color(0xFF2D363E);

  // Brand Accents
  static const Color primary = Color(0xFF25D366); // Emerald Green
  static const Color primaryContainer = Color(0xFF005523);
  static const Color secondary = Color(0xFF34B7F1); // Sky Blue
  static const Color secondaryContainer = Color(0xFF00354A);
  static const Color tertiary = Color(0xFFFFD700); // Amber Gold
  static const Color tertiaryContainer = Color(0xFF574800);

  // Text & Content
  static const Color onSurface = Color(0xFFDAE3EE);
  static const Color onSurfaceVariant = Color(0xFFBBCBB9);
  static const Color outline = Color(0xFF869584);
  static const Color outlineVariant = Color(0xFF3C4A3D);

  // Status
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
}
