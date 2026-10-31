import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';
import 'startup_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState
    extends State<AdminProfileScreen> {
  bool _initialized = false;

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<AdminProvider>();

      if (provider.admin == null) {
        await provider.loadAdmin();
      }

      if (!mounted) {
        return;
      }

      final admin = provider.admin;

      if (admin != null && !_initialized) {
        _nameController.text = admin.adminName;
        _emailController.text = admin.email;

        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Not available";
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
  // UPDATE PROFILE
  // ==========================================================

  void _showEditProfileDialog(BuildContext context) {
    final provider = context.read<AdminProvider>();
    final admin = provider.admin;

    if (admin == null) {
      return;
    }

    final nameController = TextEditingController(
      text: admin.adminName,
    );

    final emailController = TextEditingController(
      text: admin.email,
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Color(0xFF102C4A),
              ),
              SizedBox(width: 10),
              Text(
                "Edit Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                  // NAME
                  TextFormField(
                    controller: nameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Admin Name",
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final name =
                          value?.trim() ?? "";

                      if (name.isEmpty) {
                        return "Name is required.";
                      }

                      if (name.length < 2) {
                        return
                            "Name must be at least 2 characters.";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // EMAIL
                  TextFormField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final email =
                          value?.trim() ?? "";

                      final emailRegex = RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      );

                      if (email.isEmpty) {
                        return "Email is required.";
                      }

                      if (!emailRegex.hasMatch(email)) {
                        return "Enter a valid email.";
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
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF102C4A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final provider =
                    context.read<AdminProvider>();

                final success =
                    await provider.updateProfile(
                  adminName:
                      nameController.text.trim(),
                  email:
                      emailController.text.trim(),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                if (success) {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Admin profile updated successfully.",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(dialogContext)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ??
                            "Failed to update profile.",
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Save Changes",
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  void _showChangePasswordDialog(
      BuildContext context) {
    final currentPasswordController =
        TextEditingController();

    final newPasswordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    final formKey = GlobalKey<FormState>();

    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(22),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF102C4A),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Change Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
                      // CURRENT PASSWORD
                      TextFormField(
                        controller:
                            currentPasswordController,
                        obscureText:
                            obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText:
                              "Current Password",
                          prefixIcon:
                              const Icon(
                            Icons.lock_outline,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureCurrentPassword =
                                    !obscureCurrentPassword;
                              });
                            },
                            icon: Icon(
                              obscureCurrentPassword
                                  ? Icons
                                      .visibility_off_outlined
                                  : Icons
                                      .visibility_outlined,
                            ),
                          ),
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return
                                "Enter your current password.";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // NEW PASSWORD
                      TextFormField(
                        controller:
                            newPasswordController,
                        obscureText:
                            obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          prefixIcon:
                              const Icon(
                            Icons.lock_rounded,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureNewPassword =
                                    !obscureNewPassword;
                              });
                            },
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons
                                      .visibility_off_outlined
                                  : Icons
                                      .visibility_outlined,
                            ),
                          ),
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return
                                "Enter a new password.";
                          }

                          if (value.length < 8) {
                            return
                                "Password must be at least 8 characters.";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // CONFIRM PASSWORD
                      TextFormField(
                        controller:
                            confirmPasswordController,
                        obscureText:
                            obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText:
                              "Confirm New Password",
                          prefixIcon:
                              const Icon(
                            Icons
                                .verified_user_outlined,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons
                                      .visibility_off_outlined
                                  : Icons
                                      .visibility_outlined,
                            ),
                          ),
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return
                                "Confirm your new password.";
                          }

                          if (value !=
                              newPasswordController
                                  .text) {
                            return
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
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF102C4A),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!
                        .validate()) {
                      return;
                    }

                    final provider =
                        context.read<AdminProvider>();

                    final success =
                        await provider.changePassword(
                      currentPassword:
                          currentPasswordController
                              .text,
                      newPassword:
                          newPasswordController.text,
                    );

                    if (!dialogContext.mounted) {
                      return;
                    }

                    if (success) {
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Password changed successfully.",
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(
                              dialogContext)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ??
                                "Failed to change password.",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Update Password",
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
  // LOGOUT
  // ==========================================================

  Future<void> _logout() async {
    final provider =
        context.read<AdminProvider>();

    await provider.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const StartupScreen(),
      ),
      (route) => false,
    );
  }

  // ==========================================================
  // DEACTIVATE ACCOUNT
  // ==========================================================

  Future<void> _deactivateAccount() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            "Deactivate Account",
          ),
          content: const Text(
            "Are you sure you want to deactivate this admin account?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Deactivate"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final provider =
        context.read<AdminProvider>();

    final success =
        await provider.deactivate();

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const StartupScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                "Failed to deactivate account.",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DELETE ACCOUNT
  // ==========================================================

  Future<void> _deleteAccount() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            "Delete Admin Account",
          ),
          content: const Text(
            "This action cannot be undone. Are you sure you want to permanently delete this admin account?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final provider =
        context.read<AdminProvider>();

    final success =
        await provider.deleteAccount();

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const StartupScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                "Failed to delete account.",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        final admin = provider.admin;

        if (provider.isLoading &&
            admin == null) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        if (admin == null) {
          return Scaffold(
            backgroundColor:
                const Color(0xFFF6F8FB),
            appBar: AppBar(
              backgroundColor:
                  const Color(0xFF102C4A),
              foregroundColor: Colors.white,
              title:
                  const Text("Admin Profile"),
            ),
            body: const Center(
              child: Text(
                "Admin information is not available.",
              ),
            ),
          );
        }

        final name =
            admin.adminName.trim().isNotEmpty
                ? admin.adminName.trim()
                : "Administrator";

        final firstLetter =
            name.isNotEmpty
                ? name[0].toUpperCase()
                : "A";

        return Scaffold(
          backgroundColor:
              const Color(0xFFF6F8FB),

          // ====================================================
          // APP BAR
          // ====================================================

          appBar: AppBar(
            backgroundColor:
                const Color(0xFF102C4A),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Admin Profile",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ====================================================
          // BODY
          // ====================================================

          body: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ==================================================
                // AVATAR
                // ==================================================

                Container(
                  width: 110,
                  height: 110,
                  decoration:
                      BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        const Color(0xFFE5C77A),
                    border: Border.all(
                      color:
                          const Color(0xFF102C4A),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.12),
                        blurRadius: 15,
                        offset:
                            const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style:
                          const TextStyle(
                        fontSize: 42,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF102C4A),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // NAME
                Text(
                  name,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF102C4A),
                  ),
                ),

                const SizedBox(height: 6),

                // EMAIL
                Text(
                  admin.email,
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // STATUS
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration:
                      BoxDecoration(
                    color: admin.isActive
                        ? Colors.green
                            .shade50
                        : Colors.red
                            .shade50,
                    borderRadius:
                        BorderRadius
                            .circular(30),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        admin.isActive
                            ? Icons
                                .check_circle_rounded
                            : Icons
                                .cancel_rounded,
                        size: 18,
                        color: admin.isActive
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(
                          width: 8),
                      Text(
                        admin.isActive
                            ? "Active Admin Account"
                            : "Inactive Admin Account",
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          color: admin.isActive
                              ? Colors
                                  .green.shade700
                              : Colors
                                  .red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // ADMIN INFORMATION
                // ==================================================

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    "Admin Information",
                    style:
                        TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF102C4A),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _ProfileInfoCard(
                  icon:
                      Icons.person_outline_rounded,
                  title: "Admin Name",
                  value: admin.adminName,
                ),

                const SizedBox(height: 10),

                _ProfileInfoCard(
                  icon:
                      Icons.email_outlined,
                  title: "Email Address",
                  value: admin.email,
                ),

                const SizedBox(height: 10),

                _ProfileInfoCard(
                  icon:
                      Icons.badge_outlined,
                  title: "Admin ID",
                  value:
                      admin.adminId.toString(),
                ),

                const SizedBox(height: 10),

                _ProfileInfoCard(
                  icon:
                      Icons.calendar_today_outlined,
                  title: "Account Created",
                  value:
                      _formatDate(
                    admin.createdAt,
                  ),
                ),

                const SizedBox(height: 10),

                _ProfileInfoCard(
                  icon:
                      Icons.login_rounded,
                  title: "Last Login",
                  value:
                      _formatDate(
                    admin.lastLoginAt,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // ACCOUNT
                // ==================================================

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    "Account",
                    style:
                        TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF102C4A),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // EDIT PROFILE
                _AccountActionCard(
                  icon:
                      Icons.edit_rounded,
                  iconBackground:
                      const Color(0xFFE8EEF5),
                  iconColor:
                      const Color(0xFF102C4A),
                  title: "Edit Profile",
                  subtitle:
                      "Update admin name and email",
                  onTap: () =>
                      _showEditProfileDialog(
                    context,
                  ),
                ),

                const SizedBox(height: 12),

                // CHANGE PASSWORD
                _AccountActionCard(
                  icon:
                      Icons.lock_outline_rounded,
                  iconBackground:
                      const Color(0xFFEAF4ED),
                  iconColor:
                      Colors.green.shade700,
                  title:
                      "Change Password",
                  subtitle:
                      "Update your admin password",
                  onTap: () =>
                      _showChangePasswordDialog(
                    context,
                  ),
                ),

                const SizedBox(height: 12),

                // LOGOUT
                _AccountActionCard(
                  icon:
                      Icons.logout_rounded,
                  iconBackground:
                      const Color(0xFFF5E6E6),
                  iconColor: Colors.red,
                  title: "Logout",
                  subtitle:
                      "Sign out of admin account",
                  onTap: _logout,
                ),

                const SizedBox(height: 12),

                // DEACTIVATE
                _AccountActionCard(
                  icon:
                      Icons.person_off_outlined,
                  iconBackground:
                      const Color(0xFFFFF3E0),
                  iconColor:
                      Colors.orange.shade700,
                  title:
                      "Deactivate Account",
                  subtitle:
                      "Temporarily disable this admin account",
                  onTap:
                      _deactivateAccount,
                ),

                const SizedBox(height: 12),

                // DELETE
                _AccountActionCard(
                  icon:
                      Icons.delete_outline_rounded,
                  iconBackground:
                      const Color(0xFFFDECEC),
                  iconColor: Colors.red,
                  title:
                      "Delete Admin Account",
                  subtitle:
                      "Permanently delete this account",
                  onTap:
                      _deleteAccount,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================
// PROFILE INFORMATION CARD
// ==========================================================

class _ProfileInfoCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFFE8EEF5),
          child: Icon(
            icon,
            color:
                const Color(0xFF102C4A),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color:
                Colors.grey.shade600,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 3,
          ),
          child: Text(
            value,
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
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

class _AccountActionCard
    extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountActionCard({
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
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 6,
          ),
          leading: CircleAvatar(
            backgroundColor:
                iconBackground,
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          title: Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
          ),
          trailing: const Icon(
            Icons.chevron_right,
          ),
        ),
      ),
    );
  }
}