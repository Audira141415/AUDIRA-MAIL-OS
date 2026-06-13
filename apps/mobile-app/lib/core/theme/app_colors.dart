import 'package:flutter/material.dart';

class AppColors {
  // Industrial Palette (Dark Mode)
  
  // Base Materials
  static const Color chassis = Color(0xFF0F172A); // Level 0 (Slate 900 base background)
  static const Color panel = Color(0xFF1E293B); // Level +1 (Slate 800 raised panel)
  static const Color recessed = Color(0xFF020617); // Level -1 (Slate 950 sunken areas)
  
  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50 
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  
  // Accents (Cyber Blue)
  static const Color accent = Color(0xFF3B82F6); // Blue 500
  static const Color accentForeground = Color(0xFFFFFFFF); // Text on accent
  
  // Shadow Calculation Colors (Neumorphism DNA)
  static const Color shadowHighlight = Color(0x1FFFFFFF); // Light source
  static const Color shadowDark = Color(0x40000000); // Shadow area
  static const Color borderDark = Color(0xFF334155); // Slate 700
  
  // Legacy aliases (Mapped to industrial equivalent for backward compatibility)
  static const Color background = chassis;
  static const Color card = panel;
  static const Color primary = accent;
  static const Color primaryHover = Color(0xFF2563EB); // Blue 600
  static const Color inputBg = recessed;
  static const Color border = borderDark;
  static const Color textSecondary = textMuted;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}
