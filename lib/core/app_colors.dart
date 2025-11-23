import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  AppColors._();

  // Primary colors - Blood donation theme
  static const Color primary = Color(0xFFD32F2F); // Deep red
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color primaryDark = Color(0xFFB71C1C);
  
  // Secondary colors
  static const Color secondary = Color(0xFF1976D2); // Blue
  static const Color secondaryLight = Color(0xFF42A5F5);
  static const Color secondaryDark = Color(0xFF0D47A1);
  
  // Accent colors
  static const Color accent = Color(0xFFFF6F00); // Orange
  static const Color accentLight = Color(0xFFFF9800);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Divider and border colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color border = Color(0xFFBDBDBD);
  
  // Blood type specific colors (for badges/chips)
  static const Color bloodTypePositive = Color(0xFFE57373);
  static const Color bloodTypeNegative = Color(0xFF9575CD);
  
  // Urgency level colors
  static const Color urgentHigh = Color(0xFFD32F2F);
  static const Color urgentMedium = Color(0xFFFF6F00);
  static const Color urgentLow = Color(0xFF1976D2);
  
  // Map marker colors
  static const Color markerDonor = Color(0xFF4CAF50);
  static const Color markerHospital = Color(0xFF2196F3);
  static const Color markerBloodBank = Color(0xFFD32F2F);
  static const Color markerRequest = Color(0xFFFF6F00);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
