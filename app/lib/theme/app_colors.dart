/// app_colors.dart - Premium Color Palette for TechBrief
/// Clean, minimal startup aesthetic with Dark Navy (#0F172A) text and Electric Blue accent (#2563EB).

import 'package:flutter/material.dart';

class AppColors {
  // Brand Accents
  static const Color primaryBlue = Color(0xFF2563EB); // Royal / Electric Blue
  static const Color primaryBlueHover = Color(0xFF1D4ED8);
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color aiBadgePurple = Color(0xFF7C3AED);

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF8FAFC); // Slate-50 clean background
  static const Color lightCard = Colors.white;
  static const Color lightTextNavy = Color(0xFF0F172A); // Dark navy primary text
  static const Color lightTextSecondary = Color(0xFF475569); // Slate-600
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate-400
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate-200
  static const Color lightBlueTint = Color(0xFFEFF6FF); // Blue-50

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF0B0F17); // Deep slate background
  static const Color darkCard = Color(0xFF161F30); // Elevated slate-800 card
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate-50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate-500
  static const Color darkBorder = Color(0xFF1E293B); // Slate-700
  static const Color darkBlueTint = Color(0xFF1E2A4A);

  // Source Brand Accent Colors
  static const Color techCrunchColor = Color(0xFF00A562); // TechCrunch Green
  static const Color theVergeColor = Color(0xFFE01A4F); // The Verge Magenta/Coral
  static const Color ventureBeatColor = Color(0xFF0A66C2); // VentureBeat Blue
}
