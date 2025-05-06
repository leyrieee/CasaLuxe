import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF1A1A2E); // deep navy
  static const Color background = Color(0xFFFAF9F6); // off-white
}

class AppTextStyles {
  static final headline = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final body = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.primary,
  );
}
