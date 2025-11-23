import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Application text styles
class AppTextStyles {
  AppTextStyles._();

  // Heading styles
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Button text styles
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Caption and label styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Special styles
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Error text style
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );

  // Link text style
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  // Blood type badge style
  static const TextStyle bloodTypeBadge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Urgency badge style
  static const TextStyle urgencyBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Dark theme variants
  static TextStyle h1Dark = h1.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle h2Dark = h2.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle h3Dark = h3.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle h4Dark = h4.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle h5Dark = h5.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle h6Dark = h6.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle bodyLargeDark = bodyLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle bodyMediumDark = bodyMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle bodySmallDark = bodySmall.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle labelDark = label.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle subtitle1Dark = subtitle1.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle subtitle2Dark = subtitle2.copyWith(color: AppColors.textSecondaryDark);
}
