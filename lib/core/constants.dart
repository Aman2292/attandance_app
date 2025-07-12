import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Constants
class AppConstants {
  static const double officeLatitude = 37.7749;
  static const double officeLongitude = -122.4194;
  static const int officeRadiusInMeters = 100;

  static const String workStartTime = '09:00';
  static const String workEndTime = '18:00';
  static const int lateThresholdMinutes = 15;

  static const int defaultPaidLeaves = 18;
  static const int defaultSickLeaves = 6;
  static const int defaultEarnedLeaves = 0;
}

/// Updated Color Scheme
class AppColors {
  static const Color primary = Color(0xFF00ADB5);       // Cyan Accent
  static const Color secondary = Color(0xFF393E46);     // Charcoal Surface
  static const Color accent = Color(0xFF00ADB5);        // Accent/Highlight
  static const Color background = Color(0xFFEEEEEE);    // Light Gray
  static const Color surface = Color(0xFF222831);       // Dark Background
  static const Color error = Color(0xFFD32F2F);         // Red

  static const Color textPrimary = Color(0xFF222831);   // Deep Gray Text
  static const Color textSecondary = Color(0xFF393E46); // Medium Gray Text
  static const Color textHint = Color(0xFFBDBDBD);      // Light Gray

  static const Color success = Color(0xFF4CAF50);       // Green
  static const Color warning = Color(0xFFFFC107);       // Amber
  static const Color info = Color(0xFF2196F3);          // Blue

  // Attendance Status
  static const Color present = Color(0xFF4CAF50);
  static const Color absent = Color(0xFFD32F2F);
  static const Color late = Color(0xFFFFA000);
  static const Color halfDay = Color(0xFF7E57C2);

  // Leave Status
  static const Color approved = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFFA000);
  static const Color rejected = Color(0xFFD32F2F);
}


class AppTextStyles {
  static final heading1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final heading2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final heading3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static final bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static final bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static final button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}


class AppInputDecorations {
  static InputDecoration textFieldDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
      hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.textHint),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}


class AppButtonStyles {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
}
