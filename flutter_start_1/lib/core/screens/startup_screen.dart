import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'admin_login_screen.dart';
import 'user_login_screen.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  size: 75,
                  color: theme.colorScheme.onSurface,
                ),

                const SizedBox(height: 18),

                Text(
                  loc.getString('welcome_to_app') ?? 'Welcome to AlMadina',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  loc.getString('inventory_management_system') ??
                      'Inventory Management System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.hintColor,
                  ),
                ),

                const SizedBox(height: 45),

                // Admin Choice Card
                _buildChoiceCard(
                  context: context,
                  icon: Icons.admin_panel_settings_rounded,
                  title:
                      loc.getString('continue_as_admin') ?? 'Continue as Admin',
                  description: loc.getString('continue_as_admin_desc') ??
                      'Manage the system and user accounts',
                  color: const Color(0xFF174A7E),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // User Choice Card
                _buildChoiceCard(
                  context: context,
                  icon: Icons.person_rounded,
                  title:
                      loc.getString('continue_as_user') ?? 'Continue as User',
                  description: loc.getString('continue_as_user_desc') ??
                      'Manage your inventory and business',
                  color: const Color(0xFF176B40),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                Text(
                  loc.getString('secure_organized_reliable') ??
                      'Secure • Organized • Reliable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: isRtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      description,
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                isRtl
                    ? Icons.arrow_back_ios_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 18,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}