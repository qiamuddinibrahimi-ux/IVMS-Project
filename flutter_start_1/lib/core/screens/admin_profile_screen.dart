import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';
import '../providers/admin_provider.dart';
import '../screens/qiamuddin_design.dart';
import 'startup_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
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

    _glowAnimation = Tween<double>(begin: 2, end: 9).animate(
      CurvedAnimation(
        parent: _avatarController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.admin == null) {
        provider.loadAdmin();
      }
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  String _formatDate(String? value) {
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    if (value == null || value.isEmpty) return loc.getString('not_available') ?? "Not available";
    try {
      final date = DateTime.parse(value).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return value;
    }
  }

  Future<void> _logout() async {
    final provider = context.read<AdminProvider>();
    await provider.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StartupScreen()),
      (route) => false,
    );
  }

  Future<void> _deactivateAccount() async {
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('deactivate_confirm_title') ?? "Deactivate Account",
      content: loc.getString('deactivate_confirm_message') ?? "Are you sure you want to deactivate this admin account?",
      cancelText: loc.getString('cancel') ?? "Cancel",
      deleteText: loc.getString('deactivate') ?? "Deactivate",
    );

    if (confirmed != true) return;
    final provider = context.read<AdminProvider>();
    final success = await provider.deactivate();

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartupScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? (loc.getString('failed_to_deactivate') ?? "Failed to deactivate account."))),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_confirm_title') ?? "Delete Admin Account",
      content: loc.getString('delete_confirm_message') ?? "This action cannot be undone. Are you sure you want to permanently delete this admin account?",
      cancelText: loc.getString('cancel') ?? "Cancel",
      deleteText: loc.getString('delete') ?? "Delete",
    );

    if (confirmed != true) return;
    final provider = context.read<AdminProvider>();
    final success = await provider.deleteAccount();

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartupScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? (loc.getString('failed_to_delete_account') ?? "Failed to delete account."))),
      );
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final theme = Theme.of(context);
    final provider = context.read<AdminProvider>();
    final admin = provider.admin;
    if (admin == null) return;

    final nameController = TextEditingController(text: admin.adminName);
    final emailController = TextEditingController(text: admin.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            textDirection: Directionality.of(context),
            children: [
              Icon(Icons.edit_rounded, color: theme.colorScheme.onSurface),
              const SizedBox(width: 10),
              Text(loc.getString('edit_profile_title') ?? "Edit Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
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
                    textDirection: Directionality.of(context),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: loc.getString('admin_name') ?? "Admin Name",
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return loc.getString('name_required') ?? "Name is required.";
                      if (value.trim().length < 2) return loc.getString('name_min_2') ?? "Name must be at least 2 characters.";
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
                      labelText: loc.getString('email_address') ?? "Email Address",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return loc.getString('email_required') ?? "Email is required.";
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) return loc.getString('invalid_email') ?? "Enter a valid email.";
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.getString('cancel') ?? "Cancel", style: TextStyle(color: theme.hintColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFFE0E0E0) : navy,
                foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final success = await provider.updateProfile(
                  adminName: nameController.text.trim(),
                  email: emailController.text.trim(),
                );
                if (!dialogContext.mounted) return;
                if (success) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.getString('admin_profile_updated') ?? "Admin profile updated successfully.")),
                  );
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage ?? (loc.getString('failed_to_update_profile') ?? "Failed to update profile."))),
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                textDirection: Directionality.of(context),
                children: [
                  Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 10),
                  Text(loc.getString('change_password_title') ?? "Change Password",
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
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
                          labelText: loc.getString('current_password') ?? "Current Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setDialogState(() => obscureCurrentPassword = !obscureCurrentPassword),
                            icon: Icon(obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return loc.getString('enter_current_password') ?? "Enter your current password.";
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
                          labelText: loc.getString('new_password') ?? "New Password",
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setDialogState(() => obscureNewPassword = !obscureNewPassword),
                            icon: Icon(obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return loc.getString('enter_new_password') ?? "Enter a new password.";
                          if (value.length < 8) return loc.getString('password_min_8') ?? "Password must be at least 8 characters.";
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
                          labelText: loc.getString('confirm_new_password') ?? "Confirm New Password",
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          suffixIcon: IconButton(
                            onPressed: () => setDialogState(() => obscureConfirmPassword = !obscureConfirmPassword),
                            icon: Icon(obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return loc.getString('confirm_your_new_password') ?? "Confirm your new password.";
                          if (value != newPasswordController.text) return loc.getString('passwords_do_not_match') ?? "Passwords do not match.";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(loc.getString('cancel') ?? "Cancel", style: TextStyle(color: theme.hintColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFFE0E0E0) : navy,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final success = await context.read<AdminProvider>().changePassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                    );
                    if (!dialogContext.mounted) return;
                    if (success) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.getString('password_changed') ?? "Password changed successfully.")),
                      );
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(context.read<AdminProvider>().errorMessage ?? (loc.getString('failed_to_change_password') ?? "Failed to change password."))),
                      );
                    }
                  },
                  child: Text(loc.getString('update_password') ?? "Update Password"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<AdminProvider>();
    final admin = provider.admin;

    if (provider.isLoading && admin == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (admin == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          title: Text(loc.getString('admin_profile') ?? "Admin Profile", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(child: Text(loc.getString('admin_info_not_available') ?? "Admin information is not available.", style: TextStyle(color: theme.hintColor))),
      );
    }

    final name = admin.adminName.trim().isNotEmpty ? admin.adminName.trim() : (loc.getString('admin') ?? "Administrator");
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "A";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(loc.getString('admin_profile') ?? "Admin Profile", style: const TextStyle(fontWeight: FontWeight.w600)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // GLOWING AVATAR
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withValues(alpha: 0.85), width: 1.5),
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
                child: Text(firstLetter, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: navy)),
              ),
            ),

            const SizedBox(height: 16),

            // NAME
            Text(name, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 6),

            // EMAIL
            Text(admin.email, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: theme.hintColor)),
            const SizedBox(height: 24),

            // STATUS PILL
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: admin.isActive
                    ? (theme.brightness == Brightness.dark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade50)
                    : (theme.brightness == Brightness.dark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                textDirection: Directionality.of(context),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(admin.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 18, color: admin.isActive ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    admin.isActive
                        ? (loc.getString('active_admin_account') ?? "Active Admin Account")
                        : (loc.getString('inactive_admin_account') ?? "Inactive Admin Account"),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: admin.isActive
                          ? (theme.brightness == Brightness.dark ? Colors.green.shade300 : Colors.green.shade700)
                          : (theme.brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ADMIN INFORMATION
            Align(
              alignment: Directionality.of(context) == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(loc.getString('admin_information') ?? "Admin Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            ),
            const SizedBox(height: 12),

            _ProfileInfoCard(theme: theme, icon: Icons.person_outline_rounded, title: loc.getString('admin_name') ?? "Admin Name", value: admin.adminName),
            const SizedBox(height: 10),
            _ProfileInfoCard(theme: theme, icon: Icons.email_outlined, title: loc.getString('email_address') ?? "Email Address", value: admin.email),

            const SizedBox(height: 30),

            // ACCOUNT ACTIONS
            Align(
              alignment: Directionality.of(context) == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(loc.getString('account') ?? "Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            ),
            const SizedBox(height: 12),

            _AccountActionCard(
              theme: theme, icon: Icons.edit_rounded,
              iconBackground: theme.brightness == Brightness.dark ? navy : const Color(0xFFE8EEF5),
              iconColor: theme.brightness == Brightness.dark ? Colors.white : navy,
              title: loc.getString('edit_profile') ?? "Edit Profile",
              subtitle: loc.getString('edit_profile_subtitle') ?? "Update admin name and email",
              onTap: () => _showEditProfileDialog(context),
            ),
            const SizedBox(height: 12),
            _AccountActionCard(
              theme: theme, icon: Icons.lock_outline_rounded,
              iconBackground: theme.brightness == Brightness.dark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFEAF4ED),
              iconColor: theme.brightness == Brightness.dark ? Colors.green.shade300 : Colors.green.shade700,
              title: loc.getString('change_password') ?? "Change Password",
              subtitle: loc.getString('change_password_subtitle') ?? "Update your admin password",
              onTap: () => _showChangePasswordDialog(context),
            ),
            const SizedBox(height: 12),
            _AccountActionCard(
              theme: theme, icon: Icons.logout_rounded,
              iconBackground: theme.brightness == Brightness.dark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFF5E6E6),
              iconColor: Colors.red,
              title: loc.getString('logout') ?? "Logout",
              subtitle: loc.getString('logout_subtitle') ?? "Sign out of admin account",
              onTap: _logout,
            ),
            const SizedBox(height: 12),
            
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoCard({required this.theme, required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF102C4A) : const Color(0xFFE8EEF5),
          child: Icon(icon, color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF102C4A)),
        ),
        title: Text(title, style: TextStyle(fontSize: 13, color: theme.hintColor)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        ),
      ),
    );
  }
}

class _AccountActionCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountActionCard({
    required this.theme, required this.icon, required this.iconBackground,
    required this.iconColor, required this.title, required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          leading: CircleAvatar(backgroundColor: iconBackground, child: Icon(icon, color: iconColor)),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          subtitle: Text(subtitle, style: TextStyle(color: theme.hintColor)),
          trailing: Icon(Icons.chevron_right, color: theme.hintColor),
        ),
      ),
    );
  }
}