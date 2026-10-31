import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';

import 'admin_login_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AdminProvider>().loadAdmin();
    });
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final provider = context.read<AdminProvider>();

    await provider.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // OPEN ADMIN PROFILE
  // ============================================================

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminProfileScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        final admin = provider.admin;

        // ======================================================
        // ADMIN INFORMATION
        // ======================================================

        final adminName =
            admin?.adminName.trim().isNotEmpty == true
                ? admin!.adminName.trim()
                : "Admin";

        final adminEmail =
            admin?.email ?? "";

        final firstLetter =
            adminName.isNotEmpty
                ? adminName[0].toUpperCase()
                : "A";

        return Scaffold(

          // ====================================================
          // APP BAR
          // ====================================================

          appBar: AppBar(
            backgroundColor:
                const Color(0xFF102C4A),

            foregroundColor:
                Colors.white,

            elevation: 0,

            toolbarHeight: 76,

            titleSpacing: 16,

            title: GestureDetector(
              onTap: _openProfile,

              child: Row(
                children: [

                  // ==========================================
                  // ADMIN INITIAL AVATAR
                  // ==========================================

                  Container(
                    width: 48,
                    height: 48,

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFFE5C77A),
                          Color(0xFFF4DFA0),
                        ],

                        begin:
                            Alignment.topLeft,

                        end:
                            Alignment.bottomRight,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.20),

                          blurRadius: 8,

                          offset:
                              const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Text(
                        firstLetter,

                        style:
                            const TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w800,

                          color:
                              Color(0xFF102C4A),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ==========================================
                  // ADMIN NAME + EMAIL
                  // ==========================================

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          adminName,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          adminEmail,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(0.72),

                            fontSize: 12.5,

                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // LOGOUT BUTTON
            // ==================================================

            actions: [
              IconButton(
                tooltip: "Logout",

                icon: const Icon(
                  Icons.logout_rounded,
                ),

                onPressed: _logout,
              ),

              const SizedBox(width: 6),
            ],
          ),

          // ====================================================
          // BODY
          // ====================================================

          body: provider.isLoading &&
                  admin == null

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadAdmin();
                  },

                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // ======================================
                        // SYSTEM OVERVIEW
                        // ======================================

                        const Text(
                          "System Overview",

                          style:
                              TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ======================================
                        // OVERVIEW GRID
                        // ======================================

                        GridView.count(
                          crossAxisCount: 2,

                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          crossAxisSpacing: 14,

                          mainAxisSpacing: 14,

                          childAspectRatio:
                              1.15,

                          children: [

                            // =================================
                            // USERS
                            // =================================

                            _DashboardTile(
                              icon:
                                  Icons.people_alt_rounded,

                              title:
                                  "Users",

                              value:
                                  "0",

                              color:
                                  const Color(0xFF174A7E),

                              onTap: () {
                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "User management will be added later.",
                                    ),
                                  ),
                                );
                              },
                            ),

                            // =================================
                            // SALES
                            // =================================

                            _DashboardTile(
                              icon:
                                  Icons.point_of_sale_rounded,

                              title:
                                  "Sales",

                              value:
                                  "0",

                              color:
                                  const Color(0xFF147D78),

                              onTap: () {
                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Sales statistics will be added later.",
                                    ),
                                  ),
                                );
                              },
                            ),

                            // =================================
                            // ITEMS
                            // =================================

                            _DashboardTile(
                              icon:
                                  Icons.inventory_2_rounded,

                              title:
                                  "Items",

                              value:
                                  "0",

                              color:
                                  const Color(0xFF176B40),

                              onTap: () {
                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Item statistics will be added later.",
                                    ),
                                  ),
                                );
                              },
                            ),

                            // =================================
                            // PROFIT
                            // =================================

                            _DashboardTile(
                              icon:
                                  Icons.bar_chart_rounded,

                              title:
                                  "Profit",

                              value:
                                  "\$0.00",

                              color:
                                  const Color(0xFF8B5A2B),

                              onTap: () {
                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Profit statistics will be added later.",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // ======================================
                        // MANAGEMENT TITLE
                        // ======================================

                        const Text(
                          "Management",

                          style:
                              TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ======================================
                        // MANAGE USERS
                        // ======================================

                        _ManagementTile(
                          icon:
                              Icons.people_alt_rounded,

                          iconColor:
                              const Color(0xFF174A7E),

                          title:
                              "Manage Users",

                          subtitle:
                              "View and manage system users",

                          onTap: () {
                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "User management will be added later.",
                                ),
                              ),
                            );
                          },
                        ),

                        // ======================================
                        // REPORTS
                        // ======================================

                        _ManagementTile(
                          icon:
                              Icons.bar_chart_rounded,

                          iconColor:
                              const Color(0xFF455A64),

                          title:
                              "Reports",

                          subtitle:
                              "View system reports and statistics",

                          onTap: () {
                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Reports will be added later.",
                                ),
                              ),
                            );
                          },
                        ),

                        // ======================================
                        // ACTIVITY
                        // ======================================

                        _ManagementTile(
                          icon:
                              Icons.history_rounded,

                          iconColor:
                              const Color(0xFF7A4E2D),

                          title:
                              "Activity",

                          subtitle:
                              "View system activity",

                          onTap: () {
                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Activity will be added later.",
                                ),
                              ),
                            );
                          },
                        ),

                        // ======================================
                        // ADMIN PROFILE
                        // ======================================

                        _ManagementTile(
                          icon:
                              Icons.person_outline_rounded,

                          iconColor:
                              const Color(0xFF6B4AA1),

                          title:
                              "Admin Profile",

                          subtitle:
                              "Manage your administrator account",

                          onTap: _openProfile,
                        ),

                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

// ============================================================
// DASHBOARD TILE
// ============================================================

class _DashboardTile extends StatelessWidget {
  final IconData icon;

  final String title;

  final String value;

  final Color color;

  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,

      color: Colors.white,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),

        onTap: onTap,

        child: Padding(
          padding:
              const EdgeInsets.all(14),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              // ==============================================
              // ICON
              // ==============================================

              Icon(
                icon,

                size: 35,

                color: color,
              ),

              const SizedBox(
                height: 10,
              ),

              // ==============================================
              // TITLE
              // ==============================================

              Text(
                title,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // ==============================================
              // VALUE
              // ==============================================

              Text(
                value,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,

                  color:
                      Color(0xFF102C4A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MANAGEMENT TILE
// ============================================================

class _ManagementTile
    extends StatelessWidget {

  final IconData icon;

  final Color iconColor;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  const _ManagementTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      elevation: 1,

      color: Colors.white,

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

          // ================================================
          // ICON
          // ================================================

          leading: CircleAvatar(
            backgroundColor:
                iconColor.withOpacity(0.10),

            child: Icon(
              icon,

              color:
                  iconColor,
            ),
          ),

          // ================================================
          // TITLE
          // ================================================

          title: Text(
            title,

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          // ================================================
          // SUBTITLE
          // ================================================

          subtitle:
              Text(subtitle),

          // ================================================
          // ARROW
          // ================================================

          trailing:
              const Icon(
            Icons.chevron_right,
          ),
        ),
      ),
    );
  }
}