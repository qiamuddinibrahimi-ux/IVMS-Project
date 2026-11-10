import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/admin_provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final provider = context.read<AdminProvider>();
      final user = await provider.repository.getUserDetails(widget.userId);
      setState(() { _user = user; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _toggleStatus() async {
    if (_user == null) return;
    final provider = context.read<AdminProvider>();
    try {
      await provider.repository.toggleUserStatus(_user!.userId);
      _loadDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User status updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: const Text('User Details'), // ✅ English
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _user == null
                  ? const Center(child: Text('User not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(_user!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(_user!.email, style: TextStyle(color: theme.hintColor)),
                          
                          const SizedBox(height: 24),
                          
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _user!.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _user!.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _user!.isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Stats Grid
                          Row(
                            children: [
                              Expanded(child: _statCard('Sales', _user!.salesCount, Colors.blue, theme)),
                              const SizedBox(width: 12),
                              Expanded(child: _statCard('Purchases', _user!.purchasesCount, Colors.orange, theme)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _statCard('Customers', _user!.customersCount, Colors.green, theme)),
                              const SizedBox(width: 12),
                              Expanded(child: _statCard('Vendors', _user!.vendorsCount, Colors.purple, theme)),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Toggle Status Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _user!.isActive ? Colors.red : Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _toggleStatus,
                              icon: Icon(_user!.isActive ? Icons.block : Icons.check_circle),
                              label: Text(
                                _user!.isActive ? 'Deactivate User' : 'Activate User',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _statCard(String title, int value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: theme.hintColor, fontSize: 13)),
          const SizedBox(height: 8),
          Text('$value', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}