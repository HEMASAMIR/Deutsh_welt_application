import 'package:flutter/material.dart';

class AppColors {
  // Primary palette (Calm & Elegant - Not dark mode, just professional)
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Navy Blue (Calm, not piercing)
  static const Color primaryBlueDark = Color(0xFF172554); // Darker Navy
  static const Color primaryBlueLight = Color(0xFF60A5FA); // Soft Light Blue
  static const Color accentGold = Color(0xFF60A5FA); // Bright Blue Accent
  static const Color accentGoldLight = Color(0xFF93C5FD);

  // Background - White/Light Theme
  static const Color backgroundLight = Color(0xFFF8FAFC); // Very soft clean white/gray
  static const Color backgroundCard = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundSurface = Color(0xFFFFFFFF);
  static const Color backgroundGlass = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);

  // Text
  static const Color textPrimary = Color(0xFF1F2937); // Dark gray, not pure black (softer on eyes)
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;

  // Status
  static const Color success = Color(0xFF059669); // Soft Green
  static const Color error = Color(0xFFDC2626); // Soft Red
  static const Color warning = Color(0xFF2563EB); // Vivid Blue instead of orange/gold

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF172554)], // Navy gradient
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)], // Very clean light background
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)], // Blue gradient
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
  );

  // Dividers
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF1E3A8A); // Focus with Navy Blue
}
