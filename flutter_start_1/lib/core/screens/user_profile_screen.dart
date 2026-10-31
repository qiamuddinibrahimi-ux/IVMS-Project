import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import 'startup_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  // Gold accent works well in both themes
  static const Color gold = Color(0xFFE5C77A);
  static const Color navy = Color(0xFF102C4A);

  late final AnimationController _avatarController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 2,
      end: 9,
    ).animate(
      CurvedAnimation(
        parent: _avatarController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _logout(BuildContext context) async {
    final provider = context.read<AuthProvider>();

    await provider.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const StartupScreen(),
      ),
      (route) => false,
    );
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(String? value) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (value == null || value.isEmpty) {
      return loc.getString('not_available') ?? "Not available";
    }

    try {
      final date = DateTime.parse(value).toLocal();

      return "${date.year}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return value;
    }
  }

  // ==========================================================
  // EDIT PROFILE
  // ==========================================================

  void _showEditProfileDialog(BuildContext context) {
    final provider = context.read<AuthProvider>();
    final user = provider.user;
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            textDirection: Directionality.of(context),
            children: [
              Icon(
                Icons.edit_rounded,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Text(
                loc.getString('edit_profile') ?? "Edit Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    textDirection: Directionality.of(context),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: loc.getString('full_name') ?? "Full Name",
                      labelStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: theme.hintColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final name = value?.trim() ?? "";

                      if (name.isEmpty) {
                        return loc.getString('name_required') ??
                            "Name is required.";
                      }

                      if (name.length < 2) {
                        return loc.getString('name_min_characters') ??
                            "Name must be at least 2 characters.";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: Directionality.of(context),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText:
                          loc.getString('email_address') ?? "Email Address",
                      labelStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: theme.hintColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? "";

                      final emailRegex = RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      );

                      if (email.isEmpty) {
                        return loc.getString('email_required') ??
                            "Email is required.";
                      }

                      if (!emailRegex.hasMatch(email)) {
                        return loc.getString('invalid_email_short') ??
                            "Enter a valid email.";
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                loc.getString('cancel') ?? "Cancel",
                style: TextStyle(color: theme.hintColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark
                    ? const Color(0xFFE0E0E0)
                    : navy,
                foregroundColor: theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final success = await provider.updateProfile(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                );

                if (!dialogContext.mounted) return;

                if (success) {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        loc.getString('profile_updated') ??
                            "Profile updated successfully.",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ??
                            (loc.getString('failed_to_update_profile') ??
                                "Failed to update profile."),
                      ),
                    ),
                  );
                }
              },
              child: Text(loc.getString('save_changes') ?? "Save Changes"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final formKey = GlobalKey<FormState>();

    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                textDirection: Directionality.of(context),
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loc.getString('change_password') ?? "Change Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrentPassword,
                        textDirection: Directionality.of(context),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: loc.getString('current_password') ??
                              "Current Password",
                          labelStyle: TextStyle(color: theme.hintColor),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: theme.hintColor,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureCurrentPassword =
                                    !obscureCurrentPassword;
                              });
                            },
                            icon: Icon(
                              obscureCurrentPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: theme.hintColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.getString(
                                    'enter_current_password') ??
                                "Enter your current password.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNewPassword,
                        textDirection: Directionality.of(context),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText:
                              loc.getString('new_password') ?? "New Password",
                          labelStyle: TextStyle(color: theme.hintColor),
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: theme.hintColor,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureNewPassword = !obscureNewPassword;
                              });
                            },
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: theme.hintColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.getString('enter_new_password') ??
                                "Enter a new password.";
                          }

                          if (value.length < 8) {
                            return loc.getString('password_min_length_8') ??
                                "Password must be at least 8 characters.";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        textDirection: Directionality.of(context),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText:
                              loc.getString('confirm_new_password') ??
                                  "Confirm New Password",
                          labelStyle: TextStyle(color: theme.hintColor),
                          prefixIcon: Icon(
                            Icons.verified_user_outlined,
                            color: theme.hintColor,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: theme.hintColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.getString(
                                    'confirm_your_new_password') ??
                                "Confirm your new password.";
                          }

                          if (value != newPasswordController.text) {
                            return loc.getString('passwords_do_not_match') ??
                                "Passwords do not match.";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    loc.getString('cancel') ?? "Cancel",
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark
                        ? const Color(0xFFE0E0E0)
                        : navy,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final success =
                        await context.read<AuthProvider>().changePassword(
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                            );

                    if (!dialogContext.mounted) return;

                    if (success) {
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.getString('password_changed') ??
                                "Password changed successfully.",
                          ),
                        ),
                      );
                    } else {
                      final error =
                          context.read<AuthProvider>().errorMessage;

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            error ??
                                (loc.getString('failed_to_change_password') ??
                                    "Failed to change password."),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    loc.getString('update_password') ?? "Update Password",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<AuthProvider>();
    final user = provider.user;

    // ========================================================
    // USER NOT AVAILABLE
    // ========================================================

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          title: Text(
            loc.getString('my_profile') ?? "My Profile",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.cardColor,
                  ),
                  child: Icon(
                    Icons.person_off_outlined,
                    size: 50,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.getString('user_info_not_available') ??
                      "User information is not available.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.getString('session_may_have_expired') ??
                      "Your session may have expired. Please log in again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () async {
                    await provider.logout();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StartupScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: Text(
                    loc.getString('go_to_login') ?? "Go to Login",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark
                        ? const Color(0xFFE0E0E0)
                        : navy,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ========================================================
    // USER INFORMATION
    // ========================================================

    final name = user.name.trim().isNotEmpty
        ? user.name.trim()
        : (loc.getString('user') ?? "User");

    final email = user.email.trim().isNotEmpty
        ? user.email.trim()
        : (loc.getString('no_email') ?? "No email");

    final firstLetter =
        name.isNotEmpty ? name[0].toUpperCase() : "U";

    // ========================================================
    // MAIN SCREEN
    // ========================================================

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('my_profile') ?? "My Profile",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ==================================================
            // GLOWING AVATAR
            // ==================================================

            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: gold.withValues(alpha: 0.85),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(alpha: 0.30),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: _glowAnimation.value / 4,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: CircleAvatar(
                radius: 55,
                backgroundColor: gold,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // NAME
            // ==================================================

            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            // ==================================================
            // EMAIL
            // ==================================================

            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.hintColor,
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // ACCOUNT STATUS
            // ==================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: user.isActive
                    ? (theme.brightness == Brightness.dark
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.green.shade50)
                    : (theme.brightness == Brightness.dark
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.red.shade50),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                textDirection: Directionality.of(context),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.isActive
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 18,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.isActive
                        ? (loc.getString('active_account') ??
                            "Active Account")
                        : (loc.getString('inactive_account') ??
                            "Inactive Account"),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: user.isActive
                          ? (theme.brightness == Brightness.dark
                              ? Colors.green.shade300
                              : Colors.green.shade700)
                          : (theme.brightness == Brightness.dark
                              ? Colors.red.shade300
                              : Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // PERSONAL INFORMATION
            // ==================================================

            Align(
              alignment: Directionality.of(context) == TextDirection.rtl
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                loc.getString('personal_information') ??
                    "Personal Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _ProfileInfoCard(
              theme: theme,
              icon: Icons.person_outline_rounded,
              title: loc.getString('full_name') ?? "Full Name",
              value: name,
            ),

            const SizedBox(height: 10),

            _ProfileInfoCard(
              theme: theme,
              icon: Icons.email_outlined,
              title: loc.getString('email_address') ?? "Email Address",
              value: email,
            ),

            const SizedBox(height: 30),

            // ==================================================
            // ACCOUNT
            // ==================================================

            Align(
              alignment: Directionality.of(context) == TextDirection.rtl
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                loc.getString('account') ?? "Account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _AccountActionCard(
              theme: theme,
              icon: Icons.edit_rounded,
              iconBackground: theme.brightness == Brightness.dark
                  ? navy
                  : const Color(0xFFE8EEF5),
              iconColor: theme.brightness == Brightness.dark
                  ? Colors.white
                  : navy,
              title: loc.getString('edit_profile') ?? "Edit Profile",
              subtitle: loc.getString('edit_profile_subtitle') ??
                  "Update your name and email",
              onTap: () {
                _showEditProfileDialog(context);
              },
            ),

            const SizedBox(height: 12),

            _AccountActionCard(
              theme: theme,
              icon: Icons.lock_outline_rounded,
              iconBackground: theme.brightness == Brightness.dark
                  ? Colors.green.withValues(alpha: 0.2)
                  : const Color(0xFFEAF4ED),
              iconColor: theme.brightness == Brightness.dark
                  ? Colors.green.shade300
                  : Colors.green.shade700,
              title: loc.getString('change_password') ?? "Change Password",
              subtitle: loc.getString('change_password_subtitle') ??
                  "Update your account password",
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),

            const SizedBox(height: 12),

            _AccountActionCard(
              theme: theme,
              icon: Icons.logout_rounded,
              iconBackground: theme.brightness == Brightness.dark
                  ? Colors.red.withValues(alpha: 0.2)
                  : const Color(0xFFF5E6E6),
              iconColor: Colors.red,
              title: loc.getString('logout') ?? "Logout",
              subtitle: loc.getString('logout_subtitle') ??
                  "Sign out of your account",
              onTap: () {
                _logout(context);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// PROFILE INFORMATION CARD
// ==========================================================

class _ProfileInfoCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoCard({
    required this.theme,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF102C4A)
              : const Color(0xFFE8EEF5),
          child: Icon(
            icon,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF102C4A),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: theme.hintColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// ACCOUNT ACTION CARD
// ==========================================================

class _AccountActionCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountActionCard({
    required this.theme,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 6,
          ),
          leading: CircleAvatar(
            backgroundColor: iconBackground,
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: theme.hintColor),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.hintColor,
          ),
        ),
      ),
    );
  }
}