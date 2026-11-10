import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';
import '../screens/qiamuddin_design.dart';
import '../models/user_model.dart';
import 'user_details_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllUsers();
    });

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filteredUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AdminProvider>();
    final filteredUsers = _filteredUsers(provider.users);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'Manage Users', // ✅ Hardcoded English
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.ltr, // ✅ Always LTR in Admin
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by name or email...', // ✅ English
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search_rounded, color: theme.hintColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: Icon(Icons.clear_rounded, color: theme.hintColor),
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LIST OF USERS
          Expanded(
            child: provider.isLoading && provider.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? "No users found"
                              : "No matching users found",
                          style: TextStyle(color: theme.hintColor),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QiamuddinDesign.listCard(
                              context: context,
                              theme: theme,
                              avatarText: user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              title: user.name,
                              subtitle: user.email,
                              avatarBgColor: user.isActive
                                  ? const Color(0xFF176B40)
                                  : Colors.red.shade700,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        UserDetailsScreen(userId: user.userId),
                                  ),
                                ).then((_) {
                                  context.read<AdminProvider>().loadAllUsers();
                                });
                              },
                              onDelete: () {}, // Not used
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}