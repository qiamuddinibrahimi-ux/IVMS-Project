import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';
import 'admin_login_screen.dart';
import 'admin_profile_screen.dart';
import 'user_management_screen.dart';
import 'activity_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  static const Color gold = Color(0xFFE5C77A);

  // ✅ CHANGED: Not 'late', initialized to null safely
  AnimationController? _ringController;

  @override
  void initState() {
    super.initState();

    // ✅ Safe initialization
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<AdminProvider>();
      
      // 1. Load Admin Info
      await provider.loadAdmin();
      
      // 2. Load Dashboard Stats
      await provider.loadDashboardStats();
    });
  }

  @override
  void dispose() {
    // ✅ Safe disposal
    _ringController?.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final provider = context.read<AdminProvider>();
    await provider.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
    );
  }

  // ============================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================
  bool _isCompact(double w) => w < 340;
  bool _isSmall(double w) => w < 360;
  bool _isTablet(double w) => w >= 600 && w < 900;
  bool _isDesktop(double w) => w >= 900;

  int _gridColumns(double w) {
    if (_isDesktop(w)) return 4;
    if (_isTablet(w)) return 3;
    return 2;
  }

  double _gridAspectRatio(double w) {
    if (_isDesktop(w)) return 1.25;
    if (_isTablet(w)) return 1.18;
    if (_isCompact(w)) return 0.95;
    return 1.12;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AdminProvider>();
    final admin = provider.admin;

    final adminName = admin?.adminName.trim().isNotEmpty == true
        ? admin!.adminName.trim()
        : "Admin";
    final adminEmail = admin?.email ?? "";
    final firstLetter = adminName.isNotEmpty ? adminName[0].toUpperCase() : "A";

    // ✅ REAL DATA EXTRACTION
    final totalUsers = admin?.totalUsers ?? 0;
    final totalItems = admin?.totalItems ?? 0;
    final totalSales = admin?.totalSales ?? 0;
    final totalProfit = admin?.totalProfit ?? 0.0;

    // Responsive variables
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isCompact = _isCompact(width);
    final isSmall = _isSmall(width);
    final isTablet = _isTablet(width);
    final isDesktop = _isDesktop(width);

    final avatarSize = isDesktop ? 76.0 : isTablet ? 72.0 : isCompact ? 54.0 : 64.0;
    final appBarHeight = isDesktop ? 108.0 : isTablet ? 104.0 : isCompact ? 80.0 : 92.0;
    final horizontalPad = isDesktop ? 28.0 : isTablet ? 24.0 : isCompact ? 12.0 : 18.0;
    final iconSize = isCompact ? 22.0 : 24.0;
    final nameSize = isDesktop ? 19.0 : isTablet ? 18.0 : isCompact ? 14.0 : 17.0;
    final emailSize = isCompact ? 10.5 : 12.0;

    final columns = _gridColumns(width);
    final aspectRatio = _gridAspectRatio(width);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ============================================================
      // APP BAR WITH ANIMATED AVATAR
      // ============================================================
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 8),
              child: Row(
                children: [
                  // ✅ ANIMATED AVATAR
                  InkWell(
                    onTap: _openProfile,
                    borderRadius: BorderRadius.circular(avatarSize),
                    child: SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Rotating dashed ring
                          if (_ringController != null)
                            AnimatedBuilder(
                              animation: _ringController!,
                              builder: (context, _) {
                                return Transform.rotate(
                                  angle: _ringController!.value * 2 * 3.1415926535,
                                  child: CustomPaint(
                                    size: Size(avatarSize - 2, avatarSize - 2),
                                    painter: _DashedRingPainter(
                                      color: gold,
                                      strokeWidth: isCompact ? 2.2 : 3,
                                      dashCount: 24,
                                      dashFraction: 0.55,
                                    ),
                                  ),
                                );
                              },
                            ),

                          // 2. Inner Gold Avatar
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: gold.withValues(alpha: 0.9),
                                width: isCompact ? 1.2 : 1.8,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: (avatarSize - 12) / 2,
                              backgroundColor: gold,
                              child: Text(
                                firstLetter,
                                style: TextStyle(
                                  color: const Color(0xFF102C4A),
                                  fontSize: isCompact ? 16 : 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isCompact ? 8 : 14),

                  // NAME / EMAIL
                  Expanded(
                    child: InkWell(
                      onTap: _openProfile,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              adminName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: nameSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isCompact ? 2 : 4),
                            Text(
                              adminEmail.isNotEmpty ? adminEmail : 'Administrator',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: emailSize,
                              ),
                            ),
                            if (!isCompact) ...[
                              SizedBox(height: isSmall ? 2 : 3),
                              Text(
                                'AlMadina System Admin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: gold,
                                  fontSize: isCompact ? 9.0 : 10.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: isCompact ? 2 : 8),

                  // LOGOUT ICON
                  IconButton(
                    visualDensity: isCompact ? VisualDensity.compact : VisualDensity.standard,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: iconSize + 8,
                      minHeight: iconSize + 8,
                    ),
                    tooltip: "Logout",
                    onPressed: _logout,
                    icon: Icon(
                      Icons.logout_rounded,
                      color: theme.colorScheme.onSurface,
                      size: iconSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: provider.isLoading && admin == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await provider.loadAdmin();
                await provider.loadDashboardStats();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ERROR MESSAGE
                    if (provider.errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // SYSTEM OVERVIEW
                    Text(
                      "System Overview",
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.builder(
                      itemCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final items = [
                          _DashboardItem(
                            icon: Icons.people_alt_rounded,
                            title: "Users",
                            value: "$totalUsers",
                            color: const Color(0xFF174A7E),
                            onTap: () => _showSnack("User management will be added later."),
                          ),
                          _DashboardItem(
                            icon: Icons.point_of_sale_rounded,
                            title: "Sales",
                            value: "$totalSales",
                            color: const Color(0xFF147D78),
                            onTap: () => _showSnack("Sales statistics will be added later."),
                          ),
                          _DashboardItem(
                            icon: Icons.inventory_2_rounded,
                            title: "Items",
                            value: "$totalItems",
                            color: const Color(0xFF176B40),
                            onTap: () => _showSnack("Item statistics will be added later."),
                          ),
                          _DashboardItem(
                            icon: Icons.bar_chart_rounded,
                            title: "Profit",
                            value: "\$${totalProfit.toStringAsFixed(2)}",
                            color: const Color(0xFF8B5A2B),
                            onTap: () => _showSnack("Profit statistics will be added later."),
                          ),
                        ];
                        
                        final item = items[index];

                        return _buildDashboardCard(
                          theme: theme,
                          title: item.title,
                          value: item.value,
                          icon: item.icon,
                          color: item.color,
                          onTap: item.onTap,
                          compact: isCompact,
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // MANAGEMENT
                    Text(
                      "Management",
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildManagementTile(
                      theme: theme,
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF174A7E),
                      title: "Manage Users",
                      subtitle: "View and manage system users",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                        );
                      },
                    ),

                    _buildManagementTile(
                      theme: theme,
                      icon: Icons.history_rounded,
                      iconColor: const Color(0xFF7A4E2D),
                      title: "Activity",
                      subtitle: "View system activity",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ActivityScreen()),
                        );
                      },
                    ),

                    _buildManagementTile(
                      theme: theme,
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF6B4AA1),
                      title: "Admin Profile",
                      subtitle: "Manage your administrator account",
                      onTap: _openProfile,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildDashboardCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool compact,
  }) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(compact ? 14 : 17),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 14 : 17),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(compact ? 10 : 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 14 : 17),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 7 : 9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(compact ? 10 : 12),
                ),
                child: Icon(icon, size: compact ? 20 : 23, color: color),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: compact ? 12 : 13,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementTile({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.10),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
          ),
          subtitle: Text(subtitle, style: TextStyle(color: theme.hintColor)),
          trailing: Icon(Icons.chevron_right, color: theme.hintColor),
        ),
      ),
    );
  }
}

class _DashboardItem {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;
  const _DashboardItem({required this.icon, required this.title, required this.value, required this.color, required this.onTap});
}

// ============================================================
// ✅ DASHED RING PAINTER
// ============================================================
class _DashedRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;
  final double dashFraction;

  _DashedRingPainter({
    required this.color,
    this.strokeWidth = 3,
    this.dashCount = 24,
    this.dashFraction = 0.55,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final slotAngle = (2 * 3.1415926535) / dashCount;
    final dashAngle = slotAngle * dashFraction;

    for (int i = 0; i < dashCount; i++) {
      final start = i * slotAngle;
      final end = start + dashAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        end - start,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dashCount != dashCount ||
        old.dashFraction != dashFraction;
  }
}