import 'package:flutter/material.dart';
import 'app_colors.dart';

class IndustrialTheme {
  // Border Radii
  static final BorderRadius radiusSm = BorderRadius.circular(4);
  static final BorderRadius radiusMd = BorderRadius.circular(8);
  static final BorderRadius radiusLg = BorderRadius.circular(16);
  static final BorderRadius radiusXl = BorderRadius.circular(24);
  static final BorderRadius radiusFull = BorderRadius.circular(9999);

  // Neumorphic Shadows (Light from Top-Left)

  /// Card (Base Lift)
  /// Standard elevation for panels and cards. Dark shadow bottom-right, light highlight top-left.
  static final List<BoxShadow> shadowCard = [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: const Offset(8, 8),
      blurRadius: 16,
    ),
    BoxShadow(
      color: AppColors.shadowHighlight,
      offset: const Offset(-8, -8),
      blurRadius: 16,
    ),
  ];

  /// Floating (High Elevation)
  /// Enhanced lift for interactive elements
  static final List<BoxShadow> shadowFloating = [
    BoxShadow(
      color: AppColors.shadowDark.withOpacity(0.8),
      offset: const Offset(12, 12),
      blurRadius: 24,
    ),
    BoxShadow(
      color: AppColors.shadowHighlight,
      offset: const Offset(-12, -12),
      blurRadius: 24,
    ),
  ];

  /// Sharp (Mechanical Edge)
  /// Harder-edged shadow for specific components
  static final List<BoxShadow> shadowSharp = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      offset: const Offset(4, 4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      offset: const Offset(-1, -1),
      blurRadius: 1,
    ),
  ];

  /// Glow (LED/Status Indicator)
  static List<BoxShadow> glowShadow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.6),
        offset: Offset.zero,
        blurRadius: 10,
        spreadRadius: 2,
      )
    ];
  }

  // Inner shadows (Pressed / Recessed) requires custom painting or containers in Flutter.
  // We'll simulate this using a dedicated widget component later if needed.
}
