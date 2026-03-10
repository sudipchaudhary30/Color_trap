import 'package:flutter/material.dart';

class AppColors {
  // Game colors - the 4 colors used in gameplay
  static const List<Color> gameColors = [
    Color(0xFFFF4757), // Red
    Color(0xFF2ED573), // Green
    Color(0xFF1E90FF), // Blue
    Color(0xFFFFD700), // Yellow
  ];

  static const Color background = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFF16213E);
  static const Color white = Colors.white;
  static const Color darkText = Color(0xFF0F0F0F);

  // UI colors
  static const Color scoreColor = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFF2ED573);
}

class AppConstants {
  // Ball
  static const double ballRadius = 30.0;
  static const double ballStartY = 0.35; // fraction of screen height

  // Platform
  static const double platformHeight = 25.0;
  static const double platformWidth = 0.75; // fraction of screen width
  static const double platformY = 0.72; // fraction of screen height

  // Physics
  static const double gravity = 800.0;
  static const double jumpVelocity = -500.0;
  static const double ballBounceVelocity = -550.0;
  static const double bounceCooldown = 0.2;

  // Speed settings
  static const double initialPlatformSpeed = 180.0;
  static const double speedIncreasePerScore = 8.0;
  static const double maxPlatformSpeed = 450.0;

  // Ads
  static const int deathsPerAd = 3;

  // AdMob IDs (Test IDs - replace with real ones before publishing)
  static const String interstitialAdId =
      'ca-app-pub-3940256099942544/1033173712'; // test
  static const String bannerAdId =
      'ca-app-pub-3940256099942544/6300978111'; // test
}
