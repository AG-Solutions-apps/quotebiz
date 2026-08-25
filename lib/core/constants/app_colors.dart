import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette (Navy #0F172A + Blue #2563EB + Cyan #06B6D4)
  static const Color navy = Color(0xFF0F172A);
  static const Color navyLight = Color(0xFF1E293B);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueDark = Color(0xFF1D4ED8);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanDark = Color(0xFF0891B2);
  static const Color cyanLight = Color(0xFFECFEFF);

  // Primary aliases
  static const Color primary = blue;
  static const Color primaryDark = blueDark;
  static const Color primaryLight = blueLight;
  static const Color accent = cyan;

  // Backgrounds & Surfaces
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF93C5FD);
  static const Color divider = Color(0xFFEEF2F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status & Badges
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF06B6D4);
  static const Color infoBg = Color(0xFFECFEFF);

  // Backward compatibility aliases
  static const Color successGreen = success;
  static const Color warningYellow = warning;
  static const Color blueIcon = blue;
  static const Color blueBg = blueLight;
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color purpleBg = Color(0xFFF5F3FF);

  // Chart Specific Colors
  static const Color chartPink = Color(0xFFFF5376);
  static const Color chartGreen = Color(0xFF10B981);
  static const Color chartBlue = Color(0xFF2563EB);
  static const Color chartCyan = Color(0xFF06B6D4);
  static const Color chartLineGrid = Color(0xFFF1F5F9);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navy, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [blue, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
