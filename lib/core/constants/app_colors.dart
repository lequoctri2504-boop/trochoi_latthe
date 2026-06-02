import 'package:flutter/material.dart';

class AppColors {
  // Obsidian dark theme
  static const Color background = Color(0xFF0F0C1B);
  static const Color cardBg = Color(0xFF1E1A3A);
  static const Color primary = Color(0xFF7C4DFF); // Glowing Purple
  static const Color secondary = Color(0xFF00E5FF); // Neon Cyan
  static const Color accent = Color(0xFFFF4081); // Hot Pink
  
  // States
  static const Color success = Color(0xFF00E676); // Emerald Green
  static const Color error = Color(0xFFFF1744); // Neon Red
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA5A1C9);
  
  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F0C1B), Color(0xFF1E0A35)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1A3A), Color(0xFF27224D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
