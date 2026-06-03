import 'package:flutter/material.dart';

/// Defines all app-wide color constants extracted from the ZonaX design.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.inputBackground,
    required this.inputBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.accent,
    required this.inputIcon,
    required this.signInText,
    required this.divider,
  });

  final Color background;
  final Color surface;
  final Color inputBackground;
  final Color inputBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color accent;
  final Color inputIcon;
  final Color signInText;
  final Color divider;

  // Light theme
  static AppColors light() => const AppColors(
    background: Color(0xFFF9FAFB), // Soft off-white background
    surface: Color(0xFFFFFFFF), // White surface
    inputBackground: Color(0xFFF3F4F6), // Light gray input background
    inputBorder: Color(0xFFE5E7EB), // Subtle light border
    textPrimary: Color(0xFF111827), // Soft charcoal black text
    textSecondary: Color(0xFF4B5563), // Medium gray secondary text
    textHint: Color(0xFF9CA3AF), // Light gray hint text
    accent: Color(0xFF0D9488), // High contrast teal accent matching dark cyan
    inputIcon: Color(0xFF9CA3AF), // Medium-light gray icons
    signInText: Color(0xFF111827), // Soft charcoal black for sign in
    divider: Color(0xFFE5E7EB), // Light divider
  );

  // Dark theme
  static AppColors dark() => const AppColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1C1C1C),
    inputBackground: Color(0xFF1E1E1E),
    inputBorder: Color(0xFF2E2E2E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9E9E9E),
    textHint: Color(0xFF5E5E5E),
    accent: Color.fromARGB(255, 55, 254, 191),
    inputIcon: Color(0xFF6E6E6E),
    signInText: Color(0xFFFFFFFF),
    divider: Color(0xFF2A2A2A),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? inputBackground,
    Color? inputBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? accent,
    Color? inputIcon,
    Color? signInText,
    Color? divider,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      accent: accent ?? this.accent,
      inputIcon: inputIcon ?? this.inputIcon,
      signInText: signInText ?? this.signInText,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      inputIcon: Color.lerp(inputIcon, other.inputIcon, t)!,
      signInText: Color.lerp(signInText, other.signInText, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
