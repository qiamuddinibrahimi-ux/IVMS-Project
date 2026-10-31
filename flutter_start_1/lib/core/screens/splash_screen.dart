import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'startup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StartupScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFF102C4A);

    final Color textColor =
        isDark ? theme.colorScheme.onSurface : Colors.white;

    const Color accentColor = Color(0xFFE5C77A);

    final Color iconBoxColor = isDark ? theme.cardColor : Colors.white;

    final Color iconColor =
        isDark ? theme.colorScheme.onSurface : const Color(0xFF102C4A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                height: 125,
                width: 125,
                decoration: BoxDecoration(
                  color: iconBoxColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 75,
                  color: iconColor,
                ),
              ),

              const SizedBox(height: 28),

              // App Name
              Text(
                loc.getString('splash_app_name') ?? 'ALMADINA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                loc.getString('splash_subtitle') ??
                    'INVENTORY MANAGEMENT SYSTEM',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // Loading Indicator
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  color: accentColor,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}