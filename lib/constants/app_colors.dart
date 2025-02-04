import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية
  static const primaryLight = Color(0xFF2C7B8E);
  static const primaryDark = Color(0xFF3B95A9);
  static const secondaryLight = Color(0xFF4DACBF);
  static const secondaryDark = Color(0xFF64C3D6);
  
  // ألوان الخلفية
  static const backgroundLight = Color(0xFFF5F5F5);
  static const backgroundDark = Color(0xFF121212);
  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF1E1E1E);
  
  // ألوان النصوص
  static const textPrimaryLight = Color(0xFF1F1F1F);
  static const textPrimaryDark = Colors.white;
  static const textSecondaryLight = Color(0xFF757575);
  static const textSecondaryDark = Color(0xFFB3B3B3);
  
  // ألوان البطاقات
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF2C2C2C);
  static const cardBorderLight = Color(0xFFE0E0E0);
  static const cardBorderDark = Color(0xFF404040);
  
  // ألوان الحدود
  static const borderLight = Color(0xFFE0E0E0);
  static const borderDark = Color(0xFF424242);
  
  // ألوان الحالة
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF2196F3);
  
  // ألوان التفاعل
  static const rippleLight = Color(0x1F000000);
  static const rippleDark = Color(0x1FFFFFFF);
  static const hoverLight = Color(0x0A000000);
  static const hoverDark = Color(0x0AFFFFFF);
  
  // ألوان الفئات
  static const Map<String, Color> categoryColors = {
    'تعليم': Color(0xFF1565C0),
    'ايجار': Color(0xFFD81B60),
    'طعام': Color(0xFF00897B),
    'مواصلات': Color(0xFFFB8C00),
    'تسلية': Color(0xFF8E24AA),
    'اخرى': Color(0xFF546E7A),
  };

  // دوال مساعدة للحصول على الألوان حسب الوضع
  static Color getPrimaryColor(bool isDark) => isDark ? primaryDark : primaryLight;
  static Color getBackgroundColor(bool isDark) => isDark ? backgroundDark : backgroundLight;
  static Color getSurfaceColor(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color getTextPrimaryColor(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color getTextSecondaryColor(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color getCardColor(bool isDark) => isDark ? cardDark : cardLight;
  static Color getCardBorderColor(bool isDark) => isDark ? cardBorderDark : cardBorderLight;
  static Color getRippleColor(bool isDark) => isDark ? rippleDark : rippleLight;
  static Color getHoverColor(bool isDark) => isDark ? hoverDark : hoverLight;
  static Color getBorderColor(bool isDark) => isDark ? borderDark : borderLight;
}
