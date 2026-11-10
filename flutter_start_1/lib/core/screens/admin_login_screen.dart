import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';
import '../screens/qiamuddin_design.dart'; // ✅ Added QiamuddinDesign
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AdminProvider>();

    final success = await provider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? "Admin login failed.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // ✅ SAME ICON AS USER LOGIN
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 80,
                      color: theme.colorScheme.onSurface,
                    ),

                    const SizedBox(height: 24),

                    // ✅ SAME TITLE AS USER LOGIN
                    Text(
                      'AlMadina Inventory',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ✅ SUBTITLE (Admin Panel)
                    Text(
                      'Admin Panel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: Directionality.of(context),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Admin Email',
                        hintStyle: TextStyle(color: theme.hintColor),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your email.";
                        }
                        final emailRegex =
                            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return "Please enter a valid email.";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textDirection: Directionality.of(context),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: theme.hintColor),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: theme.hintColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password.";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ✅ QIAMUDDIN LOGIN BUTTON (Matches User Login)
                    QiamuddinDesign.primaryButton(
                      context: context,
                      text: 'ADMIN LOGIN',
                      icon: Icons.login_rounded,
                      isLoading: provider.isLoading,
                      onPressed: _login,
                    ),

                    const SizedBox(height: 24),

                    // DIVIDER
                    Row(
                      children: [
                        Expanded(child: Divider(color: theme.dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or sign in with',
                            style: TextStyle(
                                color: theme.hintColor, fontSize: 12),
                          ),
                        ),
                        Expanded(child: Divider(color: theme.dividerColor)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SOCIAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.apple,
                            color: theme.colorScheme.onSurface,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.g_mobiledata,
                            color: theme.colorScheme.onSurface,
                            size: 32,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // FOOTER NOTE
                    Text(
                      "Admin access is restricted to authorized administrators.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}