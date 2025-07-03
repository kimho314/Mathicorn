import 'package:flutter/material.dart';

class UnicornColors {
  // Primary
  static const purple = Color(0xFF8B5CF6);
  static const magenta = Color(0xFFD946EF);
  static const pink = Color(0xFFEC4899);
  static const lightPink = Color(0xFFF472B6);
  // Secondary
  static const cyan = Color(0xFF06B6D4);
  static const teal = Color(0xFF14B8A6);
  static const yellow = Color(0xFFFDE047);
  static const orange = Color(0xFFFB923C);
  // Neutral
  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFF8FAFC);
  static const mediumGray = Color(0xFFE2E8F0);
  static const textGray = Color(0xFF64748B);
  static const darkText = Color(0xFF1E293B);
}

class UnicornGradients {
  static const primaryBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      UnicornColors.purple,
      UnicornColors.magenta,
      UnicornColors.pink,
    ],
  );
  static const cardGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(255,255,255,0.25),
      Color.fromRGBO(255,255,255,0.1),
    ],
  );
  static const rainbowAccent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      UnicornColors.pink,
      UnicornColors.lightPink,
      UnicornColors.yellow,
      UnicornColors.cyan,
      UnicornColors.purple,
      UnicornColors.magenta,
    ],
  );
}

class UnicornShadows {
  static const card = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  static const button = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

class UnicornDecorations {
  static BoxDecoration appBackground = const BoxDecoration(
    gradient: UnicornGradients.primaryBackground,
  );
  static BoxDecoration cardGlass = BoxDecoration(
    gradient: UnicornGradients.cardGlass,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Color.fromRGBO(255,255,255,0.3), width: 1),
    boxShadow: UnicornShadows.card,
  );
  static BoxDecoration playlistCard = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(255,255,255,0.2),
        Color.fromRGBO(255,255,255,0.08),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Color.fromRGBO(255,255,255,0.25), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}

class UnicornTextStyles {
  static const header = TextStyle(
    color: UnicornColors.white,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    shadows: [Shadow(offset: Offset(0,2), blurRadius: 4, color: Colors.black12)],
  );
  static const storyTitle = TextStyle(
    color: UnicornColors.white,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
  static const metadata = TextStyle(
    color: Color.fromRGBO(255,255,255,0.7),
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );
  static const currentTrack = TextStyle(
    color: UnicornColors.white,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.2,
    // textAlign: TextAlign.center, // set in widget
  );
  static const button = TextStyle(
    color: UnicornColors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
  static const body = TextStyle(
    color: UnicornColors.white,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );
}

class UnicornButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: UnicornColors.purple,
    foregroundColor: UnicornColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    shadowColor: Colors.black12,
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );
  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: Color.fromRGBO(255,255,255,0.2),
    foregroundColor: UnicornColors.purple,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );
} 