import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../storage/storage_service.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';

import 'splash_screen.dart';
import 'user_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() =>
      _AuthGateScreenState();
}

class _AuthGateScreenState
    extends State<AuthGateScreen> {

  @override
  void initState() {
    super.initState();

    _checkAuthentication();
  }

  // ======================================================
  // CHECK AUTHENTICATION
  // ======================================================

  Future<void> _checkAuthentication() async {

    // ====================================================
    // CHECK ADMIN SESSION FIRST
    // ====================================================

    final adminToken =
        await StorageService.getAdminToken();

    if (adminToken != null &&
        adminToken.isNotEmpty) {

      if (!mounted) return;

      final adminProvider =
          context.read<AdminProvider>();

      final success =
          await adminProvider.loadAdmin();

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const AdminDashboardScreen(),
          ),
        );

        return;
      }

      // Admin token is no longer valid.
      await StorageService.removeAdminToken();
    }

    // ====================================================
    // CHECK USER SESSION
    // ====================================================

    final userAccessToken =
        await StorageService.getUserAccessToken();

    if (userAccessToken != null &&
        userAccessToken.isNotEmpty) {

      if (!mounted) return;

      final authProvider =
          context.read<AuthProvider>();

      // --------------------------------------------------
      // IMPORTANT
      //
      // This does:
      // 1. Check access token
      // 2. Call /me
      // 3. If expired -> refresh token
      // 4. Call /me again
      // 5. Set AuthProvider.user
      // --------------------------------------------------

      final success =
          await authProvider.restoreUserSession();

      if (!mounted) return;

      if (success &&
          authProvider.user != null) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const UserDashboardScreen(),
          ),
        );

        return;
      }
    }

    // ====================================================
    // NOBODY IS AUTHENTICATED
    // ====================================================

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SplashScreen(),
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF102C4A),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE5C77A),
        ),
      ),
    );
  }
}