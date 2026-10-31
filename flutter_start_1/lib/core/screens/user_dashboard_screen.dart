import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart'; 
import 'settings_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/sale_provider.dart';
import '../storage/storage_service.dart';

import 'user_profile_screen.dart';
import 'notifications_screen.dart';
import 'startup_screen.dart';

import 'category_screen.dart';
import 'unit_screen.dart';
import 'currency_screen.dart';
import 'exchange_rate_screen.dart';

import 'customer_screen.dart';
import 'vendor_screen.dart';

import 'purchase_screen.dart';
import 'purchase_details_screen.dart';
import 'purchase_payment_screen.dart';

import 'sale_screen.dart';
import 'sales_details_screen.dart';
import 'sales_purchase_allocation_screen.dart';
import 'customer_payment_screen.dart';

import 'inventory_screen.dart';
import 'inventory_summary_screen.dart';
import 'low_stock_screen.dart';
import 'inventory_movement_history_screen.dart';
import 'inventory_adjustment_screen.dart';
import 'stock_movement_screen.dart';

import 'reports_dashboard_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with TickerProviderStateMixin {
  static const Color gold = Color(0xFFE5C77A);

  // ============================================================
  // ROTATING DASHED RING (SNAKE)
  // ============================================================
  late AnimationController _ringController;

  // ============================================================
  // CAROUSEL STATE
  // ============================================================
  late PageController _carouselController;
  Timer? _carouselTimer;
  int _currentCarouselIndex = 0;
  static const int _carouselStartPage = 10000;

  // ============================================================
  // UNREAD NOTIFICATIONS
  // ============================================================
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _carouselController = PageController(
      viewportFraction: 0.88,
      initialPage: _carouselStartPage,
    );

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!_carouselController.hasClients) return;

      final currentPage =
          _carouselController.page?.round() ?? _carouselStartPage;
      final nextPage = currentPage + 1;

      _carouselController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<ItemProvider>().loadItems();
        await context.read<SaleProvider>().loadSales();
      } catch (_) {}

      await _refreshUnreadNotifications();
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  // ============================================================
  // UNREAD NOTIFICATIONS
  // ============================================================
  Future<void> _refreshUnreadNotifications() async {
    try {
      final user = context.read<AuthProvider>().user;
      final userId = _readUserId(user);
      if (userId == 0) return;

      final lastSeen =
          await StorageService.getLastSeenNotifications(userId);

      if (lastSeen == null) {
        if (mounted) {
          setState(() => _hasUnreadNotifications = true);
        }
        return;
      }

      final sales = context.read<SaleProvider>().sales;
      bool hasNew = false;

      for (final sale in sales) {
        final parsed = DateTime.tryParse(sale.saleDate.toString());
        if (parsed != null && parsed.isAfter(lastSeen)) {
          hasNew = true;
          break;
        }
      }

      if (mounted) {
        setState(() => _hasUnreadNotifications = hasNew);
      }
    } catch (_) {}
  }

  int _readUserId(dynamic user) {
    if (user == null) return 0;
    try {
      final id = user.userId;
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? '') ?? 0;
    } catch (_) {}
    return 0;
  }

  // ============================================================
  // CAROUSEL DATA (NOW DYNAMIC)
  // ============================================================
  List<_CarouselItem> _getCarouselItems(AppLocalizations loc) {
    return [
      _CarouselItem(
        title: loc.getString('general_setup') ?? 'Management',
        subtitle: loc.getString('configure_system') ?? 'Categories, units, currencies & rates',
        icon: Icons.settings_suggest_outlined,
        color: const Color(0xFF3F51B5),
      ),
      _CarouselItem(
        title: loc.getString('purchases') ?? 'Your Purchases',
        subtitle: loc.getString('manage_purchases') ?? 'Purchases, details & vendor payments',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF6D4C41),
      ),
      _CarouselItem(
        title: loc.getString('payments') ?? 'Payments',
        subtitle: loc.getString('manage_payments') ?? 'Customer & purchase payment records',
        icon: Icons.payments_outlined,
        color: const Color(0xFF2E7D32),
      ),
      _CarouselItem(
        title: loc.getString('sales') ?? 'Sales',
        subtitle: loc.getString('manage_sales') ?? 'Sales, details & allocations',
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFFC62828),
      ),
      _CarouselItem(
        title: loc.getString('inventory') ?? 'Inventory',
        subtitle: loc.getString('monitor_stock') ?? 'Stock, movements & adjustments',
        icon: Icons.warehouse_outlined,
        color: const Color(0xFF1565C0),
      ),
    ];
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================
  Future<void> _openScreen(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) {
      await _refreshUnreadNotifications();
    }
  }

  Future<void> _openProfile(BuildContext context) async {
    await _openScreen(context, const UserProfileScreen());
  }

  Future<void> _openNotifications(BuildContext context) async {
    await _openScreen(context, const NotificationsScreen());
  }

  Future<void> _openSettings(BuildContext context) async {
    await _openScreen(context, const SettingsScreen());
  }

  String _readUserField(dynamic user, String field) {
    if (user == null) return '';
    if (user is Map) {
      final value = user[field];
      return value?.toString().trim() ?? '';
    }
    try {
      if (field == 'name') {
        final value = user.name;
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      if (field == 'email') {
        final value = user.email;
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    } catch (_) {}
    try {
      if (field == 'name') {
        final value = user.userName;
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      if (field == 'name') {
        final value = user.fullName;
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    } catch (_) {}
    return '';
  }

  Future<void> _openSalesDetails(BuildContext context) async {
    final token = await StorageService.getUserAccessToken();
    if (!context.mounted) return;
    if (token == null || token.isEmpty) {
      _showMessage(context, 'Login session missing. Please log in again.');
      return;
    }
    final itemProvider = context.read<ItemProvider>();
    final saleProvider = context.read<SaleProvider>();
    await Future.wait([itemProvider.loadItems(), saleProvider.loadSales()]);
    if (!context.mounted) return;
    final error = itemProvider.errorMessage ?? saleProvider.errorMessage;
    if (error != null) {
      _showMessage(context, 'Could not load sales and items: $error');
      return;
    }
    _openScreen(
      context,
      SalesDetailsScreen(
        token: token,
        sales: saleProvider.sales,
        items: itemProvider.items,
      ),
    );
  }

  Future<void> _openPurchaseDetails(BuildContext context) async {
    final token = await StorageService.getUserAccessToken();
    if (!context.mounted) return;
    if (token == null || token.isEmpty) {
      _showMessage(context, 'Login session missing. Please log in again.');
      return;
    }
    final itemProvider = context.read<ItemProvider>();
    final purchaseProvider = context.read<PurchaseProvider>();
    await Future.wait([
      itemProvider.loadItems(),
      purchaseProvider.loadPurchases(),
    ]);
    if (!context.mounted) return;
    final error = itemProvider.errorMessage ?? purchaseProvider.errorMessage;
    if (error != null) {
      _showMessage(context, 'Could not load purchases and items: $error');
      return;
    }
    _openScreen(
      context,
      PurchaseDetailsScreen(
        token: token,
        purchases: purchaseProvider.purchases,
        items: itemProvider.items,
      ),
    );
  }

  Future<void> _openStockMovements(BuildContext context) async {
    final token = await StorageService.getUserAccessToken();
    if (!context.mounted) return;
    if (token == null || token.isEmpty) {
      _showMessage(context, 'Login session missing. Please log in again.');
      return;
    }
    final itemProvider = context.read<ItemProvider>();
    final purchaseProvider = context.read<PurchaseProvider>();
    final saleProvider = context.read<SaleProvider>();
    await Future.wait([
      itemProvider.loadItems(),
      purchaseProvider.loadPurchases(),
      saleProvider.loadSales(),
    ]);
    if (!context.mounted) return;
    final error = itemProvider.errorMessage ??
        purchaseProvider.errorMessage ??
        saleProvider.errorMessage;
    if (error != null) {
      _showMessage(context, 'Could not load required data: $error');
      return;
    }
    _openScreen(
      context,
      StockMovementScreen(
        items: itemProvider.items,
        purchases: purchaseProvider.purchases,
        sales: saleProvider.sales,
        token: token,
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  void _onCarouselTap(int realIndex) {
    switch (realIndex) {
      case 0:
        _openScreen(context, const CategoryScreen());
        break;
      case 1:
        _openScreen(context, const PurchaseScreen());
        break;
      case 2:
        _openScreen(context, const CustomerPaymentScreen());
        break;
      case 3:
        _openScreen(context, const SaleScreen());
        break;
      case 4:
        _openScreen(context, const InventoryScreen());
        break;
    }
  }

  // ============================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================
  // compact  < 340   (very small phones like 320px screens)
  // small    340-360
  // normal   361-599
  // tablet   600-899
  // desktop  >= 900
  bool _isCompact(double w) => w < 340;
  bool _isSmall(double w) => w < 360;
  bool _isTablet(double w) => w >= 600 && w < 900;
  bool _isDesktop(double w) => w >= 900;

  int _gridColumns(double w) {
    if (_isDesktop(w)) return 4;
    if (_isTablet(w)) return 3;
    if (_isCompact(w)) return 2; // keep 2 columns even on very small
    return 2;
  }

  double _gridAspectRatio(double w) {
    if (_isDesktop(w)) return 1.25;
    if (_isTablet(w)) return 1.18;
    if (_isCompact(w)) return 0.95; // taller cards on tiny phones so text fits
    return 1.12;
  }

  double _carouselHeight(double w) {
    if (_isDesktop(w)) return 200;
    if (_isTablet(w)) return 200;
    if (_isCompact(w)) return 155;
    return 175;
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final dynamic currentUser = authProvider.user;

    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final name = _readUserField(currentUser, 'name');
    final email = _readUserField(currentUser, 'email');

    final displayName = name.isNotEmpty ? name : loc.getString('profile') ?? 'Your Profile';

    final avatarLetter = name.isNotEmpty
        ? name.trim().characters.first.toUpperCase()
        : '?';

    final carouselItems = _getCarouselItems(loc);

    // ✅ Responsive size breakpoints
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isCompact = _isCompact(width);
    final isSmall = _isSmall(width);
    final isTablet = _isTablet(width);
    final isDesktop = _isDesktop(width);

    // Header sizing
    final avatarSize = isDesktop ? 76.0 : isTablet ? 72.0 : isCompact ? 54.0 : 64.0;
    final appBarHeight = isDesktop ? 108.0 : isTablet ? 104.0 : isCompact ? 80.0 : 92.0;
    final horizontalPad = isDesktop ? 28.0 : isTablet ? 24.0 : isCompact ? 12.0 : 18.0;
    final iconSize = isCompact ? 22.0 : 24.0;

    // Name column typography
    final nameSize = isDesktop ? 19.0 : isTablet ? 18.0 : isCompact ? 14.0 : 17.0;
    final emailSize = isCompact ? 10.5 : 12.0;
    final subtitleSize = isCompact ? 9.0 : 10.0;

    // Section + grid
    final columns = _gridColumns(width);
    final aspectRatio = _gridAspectRatio(width);
    final carouselHeight = _carouselHeight(width);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ============================================================
      // RESPONSIVE APP BAR
      // ============================================================
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPad,
                vertical: 8,
              ),
              child: Row(
                children: [
                  // AVATAR (tappable → profile)
                  InkWell(
                    onTap: () => _openProfile(context),
                    borderRadius: BorderRadius.circular(avatarSize),
                    child: SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _ringController,
                            builder: (context, _) {
                              return Transform.rotate(
                                angle: _ringController.value *
                                    2 *
                                    3.1415926535,
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
                                avatarLetter,
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

                  // NAME / EMAIL COLUMN (tappable → profile)
                  Expanded(
                    child: InkWell(
                      onTap: () => _openProfile(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayName,
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
                              email.isNotEmpty
                                  ? email
                                  : loc.getString('profile') ?? 'View your profile',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: emailSize,
                              ),
                            ),
                            // Hide the app brand on very small phones to save height
                            if (!isCompact) ...[
                              SizedBox(height: isSmall ? 2 : 3),
                              Text(
                                'AlMadina Inventory Management',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: gold,
                                  fontSize: subtitleSize,
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

                  // SETTINGS ICON
                 

                  // NOTIFICATIONS ICON
                  IconButton(
                    visualDensity: isCompact
                        ? VisualDensity.compact
                        : VisualDensity.standard,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: iconSize + 8,
                      minHeight: iconSize + 8,
                    ),
                    tooltip: loc.getString('notifications') ?? 'Notifications',
                    onPressed: () => _openNotifications(context),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: theme.colorScheme.onSurface,
                          size: iconSize,
                        ),
                        if (_hasUnreadNotifications)
                          Positioned(
                            top: -1,
                            right: -1,
                            child: Container(
                              width: isCompact ? 8 : 10,
                              height: isCompact ? 8 : 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.cardColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                   IconButton(
                    visualDensity: isCompact
                        ? VisualDensity.compact
                        : VisualDensity.standard,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: iconSize + 8,
                      minHeight: iconSize + 8,
                    ),
                    tooltip: loc.getString('settings') ?? 'Settings',
                    onPressed: () => _openSettings(context),
                    icon: Icon(
                      Icons.settings_outlined,
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

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────────────────────
              // CAROUSEL (height scales)
              // ─────────────────────────────────────────────
              SizedBox(
                height: carouselHeight,
                child: PageView.builder(
                  controller: _carouselController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentCarouselIndex =
                          index % carouselItems.length;
                    });
                  },
                  itemBuilder: (context, index) {
                    final realIndex = index % carouselItems.length;
                    final item = carouselItems[realIndex];

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 4 : 8,
                      ),
                      child: _buildCarouselCard(
                        theme: theme,
                        item: item,
                        onTap: () => _onCarouselTap(realIndex),
                        tapText: loc.getString('tap_to_open') ?? 'Tap to open',
                        compact: isCompact,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ─────────────────────────────────────────────
              // PAGE INDICATORS
              // ─────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    carouselItems.length,
                    (index) {
                      final isActive = index == _currentCarouselIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        height: 8,
                        width: isActive ? 22 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? carouselItems[_currentCarouselIndex]
                                  .color
                              : theme.hintColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ─────────────────────────────────────────────
              // DASHBOARD SECTIONS
              // ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 16,
                ),
                child: Column(
                  children: [
                    _buildSection(
                      theme: theme,
                      title: loc.getString('general_setup') ?? 'General Setup',
                      subtitle:
                          'Configure the basic system information',
                      icon: Icons.settings_suggest_outlined,
                      color: const Color(0xFF3F51B5),
                      columns: columns,
                      aspectRatio: aspectRatio,
                      isCompact: isCompact,
                      cards: [
                        _DashboardItem(
                          title: loc.getString('categories') ?? 'Categories',
                          subtitle: loc.getString('organize_products') ?? 'Organize products',
                          icon: Icons.category_outlined,
                          color: const Color(0xFF3F51B5),
                          onTap: () => _openScreen(
                              context, const CategoryScreen()),
                        ),
                        _DashboardItem(
                          title: loc.getString('units') ?? 'Units',
                          subtitle: loc.getString('manage_units') ?? 'Manage measurement units',
                          icon: Icons.straighten_rounded,
                          color: const Color(0xFF00897B),
                          onTap: () =>
                              _openScreen(context, const UnitScreen()),
                        ),
                        _DashboardItem(
                          title: loc.getString('currencies') ?? 'Currencies',
                          subtitle: loc.getString('manage_currencies') ?? 'Manage currencies',
                          icon: Icons.currency_exchange_rounded,
                          color: const Color(0xFF8E44AD),
                          onTap: () => _openScreen(
                              context, const CurrencyScreen()),
                        ),
                        _DashboardItem(
                          title: loc.getString('exchange_rates') ?? 'Exchange Rates',
                          subtitle: loc.getString('manage_rates') ?? 'Manage currency rates',
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF1976D2),
                          onTap: () => _openScreen(
                              context, const ExchangeRateScreen()),
                        ),
                      ],
                    ),

                    _buildSection(
                      theme: theme,
                      title: loc.getString('people_business') ?? 'People & Businesses',
                      subtitle: 'Manage customers and suppliers',
                      icon: Icons.groups_outlined,
                      color: const Color(0xFF00838F),
                      columns: columns,
                      aspectRatio: aspectRatio,
                      isCompact: isCompact,
                      cards: [
                        _DashboardItem(
                          title: loc.getString('customers') ?? 'Customers',
                          subtitle: loc.getString('customer_records') ?? 'Customer records',
                          icon: Icons.people_alt_outlined,
                          color: const Color(0xFF00838F),
                          onTap: () => _openScreen(
                              context, const CustomerScreen()),
                        ),
                        _DashboardItem(
                          title: loc.getString('vendors') ?? 'Vendors',
                          subtitle: loc.getString('supplier_records') ?? 'Supplier records',
                          icon: Icons.local_shipping_outlined,
                          color: const Color(0xFF546E7A),
                          onTap: () =>
                              _openScreen(context, const VendorScreen()),
                        ),
                      ],
                    ),

                    _buildSection(
                      theme: theme,
                      title: loc.getString('purchases') ?? 'Purchases',
                      subtitle:
                          'Manage incoming goods and purchase records',
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF6D4C41),
                      columns: columns,
                      aspectRatio: aspectRatio,
                      isCompact: isCompact,
                      cards: [
                        _DashboardItem(
                          title: loc.getString('purchases') ?? 'Purchases',
                          subtitle: loc.getString('purchase_transactions') ?? 'Purchase transactions',
                          icon: Icons.shopping_bag_outlined,
                          color: const Color(0xFF6D4C41),
                          onTap: () => _openScreen(
                              context, const PurchaseScreen()),
                        ),
                        _DashboardItem(
                          title: loc.getString('purchase_details') ?? 'Purchase Details',
                          subtitle: loc.getString('items_each_purchase') ?? 'Items in each purchase',
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFFB8860B),
                          onTap: () => _openPurchaseDetails(context),
                        ),
                      ],
                    ),

                    _buildSection(
                      theme: theme,
                      title: loc.getString('sales') ?? 'Sales',
                      subtitle: 'Manage sales and transaction details',
                      icon: Icons.point_of_sale_rounded,
                      color: const Color(0xFFC62828),
                      columns: columns,
                      aspectRatio: aspectRatio,
                      isCompact: isCompact,
                      cards: [
                        _DashboardItem(
                          title: loc.getString('sales') ?? 'Sales',
                          subtitle: loc.getString('sales_transactions') ?? 'Sales transactions',
                          icon: Icons.point_of_sale_rounded,
                          color: const Color(0xFFC62828),
                          onTap: () =>
                              _openScreen(context, const SaleScreen()),
                        ),
                        _DashboardItem(
                          title: loc.getString('sales_details') ?? 'Sales Details',
                          subtitle: loc.getString('items_each_sale') ?? 'Items in each sale',
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFFAD3434),
                          onTap: () => _openSalesDetails(context),
                        ),
                        _DashboardItem(
                          title: loc.getString('sales_allocation') ?? 'Sales/Purchase Allocation',
                          subtitle: loc.getString('allocate_payments') ?? 'Allocate payments and balances',
                          icon: Icons.compare_arrows_rounded,
                          color: const Color(0xFF5E35B1),
                          onTap: () => _openScreen(
                            context,
                            const SalesPurchaseAllocationScreen(),
                          ),
                        ),
                      ],
                    ),

                    _buildSection(
                      theme: theme,
                      title: loc.getString('payments') ?? 'Payments',
                      subtitle: 'Manage money received and paid',
                      icon: Icons.payments_outlined,
                      color: const Color(0xFF2E7D32),
                      columns: columns,
                      aspectRatio: aspectRatio,
                      isCompact: isCompact,
                      cards: [
                        _DashboardItem(
                          title: loc.getString('customer_payments') ?? 'Customer Payments',
                          subtitle: loc.getString('record_customer') ?? 'Record customer receipts',
                          icon: Icons.payments_outlined,
                          color: const Color(0xFF2E7D32),
                          onTap: () => _openScreen(
                            context,
                            const CustomerPaymentScreen(),
                          ),
                        ),
                        _DashboardItem(
                          title: loc.getString('purchase_payments') ?? 'Purchase Payments',
                          subtitle: loc.getString('record_vendor') ?? 'Record vendor payments',
                          icon: Icons.price_check_rounded,
                          color: const Color(0xFF558B2F),
                          onTap: () => _openScreen(
                            context,
                            const PurchasePaymentScreen(),
                          ),
                        ),
                      ],
                    ),

                    _buildSection(
                      theme: theme,
                      title: loc.getString('inventory') ?? 'Inventory & Stock',
                      subtitle:
                          'Monitor quantities, movements and adjustments',
                      icon: Icons.warehouse_outlined,
                      color: const Color(0xFF1565C0),
                      columns: columns,
                      aspectRatio: aspectRatio,
                      isCompact: isCompact,
                      cards: [
                        _DashboardItem(
                          title: loc.getString('inventory') ?? 'Inventory',
                          subtitle: loc.getString('view_inventory') ?? 'View inventory records',
                          icon: Icons.warehouse_outlined,
                          color: const Color(0xFF1565C0),
                          onTap: () => _openScreen(
                            context,
                            const InventoryScreen(),
                          ),
                        ),
                        _DashboardItem(
                          title: loc.getString('inventory_summary') ?? 'Inventory Summary',
                          subtitle: loc.getString('review_summaries') ?? 'Review stock summaries',
                          icon: Icons.analytics_outlined,
                          color: const Color(0xFF00897B),
                          onTap: () => _openScreen(
                            context,
                            const InventorySummaryScreen(),
                          ),
                        ),
                        _DashboardItem(
                          title: loc.getString('low_stock') ?? 'Low Stock',
                          subtitle: loc.getString('items_replenishment') ?? 'Items needing replenishment',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFE65100),
                          onTap: () => _openScreen(
                            context,
                            const LowStockScreen(),
                          ),
                        ),
                        _DashboardItem(
                          title: loc.getString('stock_movements') ?? 'Stock Movements',
                          subtitle: loc.getString('review_transactions') ?? 'Review stock transactions',
                          icon: Icons.swap_vert_rounded,
                          color: const Color(0xFF00695C),
                          onTap: () => _openStockMovements(context),
                        ),
                        _DashboardItem(
                          title: loc.getString('movement_history') ?? 'Movement History',
                          subtitle: loc.getString('review_history') ?? 'Review movement history',
                          icon: Icons.history_rounded,
                          color: const Color(0xFF6A1B9A),
                          onTap: () => _openScreen(
                            context,
                            const InventoryMovementHistoryScreen(),
                          ),
                        ),
                        _DashboardItem(
                          title: loc.getString('stock_adjustments') ?? 'Stock Adjustments',
                          subtitle: loc.getString('manual_adjustments') ?? 'Make manual adjustments',
                          icon: Icons.edit_note_rounded,
                          color: const Color(0xFF455A64),
                          onTap: () => _openScreen(
                            context,
                            const InventoryAdjustmentScreen(),
                          ),
                        ),
                      ],
                    ),

                    _buildSection(
                      theme: theme,
                      title: loc.getString('reports') ?? 'Reports & Analytics',
                      subtitle:
                          'Review business activity and performance',
                      icon: Icons.insights_rounded,
                      color: const Color(0xFF102C4A),
                      columns: columns,
                      aspectRatio: aspectRatio,
                      isCompact: isCompact,
                      cards: [
                        _DashboardItem(
                          title: loc.getString('reports_analytics') ?? 'Reports & Analytics',
                          subtitle: loc.getString('view_reports') ?? 'View reports and summaries',
                          icon: Icons.analytics_rounded,
                          color: const Color(0xFF102C4A),
                          onTap: () => _openScreen(
                            context,
                            const ReportsDashboardScreen(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        'AlMadina Inventory Management System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAROUSEL CARD (compact-aware)
  // ============================================================
  Widget _buildCarouselCard({
    required ThemeData theme,
    required _CarouselItem item,
    required VoidCallback onTap,
    required String tapText,
    required bool compact,
  }) {
    final iconBoxSize = compact ? 48.0 : 64.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(compact ? 16 : 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 16 : 20),
            gradient: LinearGradient(
              colors: theme.brightness == Brightness.dark
                  ? [
                      item.color.withValues(alpha: 0.35),
                      item.color.withValues(alpha: 0.15),
                    ]
                  : [
                      item.color.withValues(alpha: 0.15),
                      item.color.withValues(alpha: 0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: item.color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 18),
            child: Row(
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    size: compact ? 24 : 32,
                    color: item.color,
                  ),
                ),

                SizedBox(width: compact ? 10 : 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 16 : 19,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 6),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 10.5 : 12,
                          color: theme.hintColor,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tapText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: compact ? 10 : 11,
                                fontWeight: FontWeight.w600,
                                color: item.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: compact ? 12 : 14,
                            color: item.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION BUILDER (responsive)
  // ============================================================
  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<_DashboardItem> cards,
    required int columns,
    required double aspectRatio,
    required bool isCompact,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isCompact ? 36 : 42,
                height: isCompact ? 36 : 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(isCompact ? 11 : 13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isCompact ? 20 : 23,
                ),
              ),
              SizedBox(width: isCompact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: isCompact ? 15 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: isCompact ? 10 : 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = cards[index];

              return _buildDashboardCard(
                theme: theme,
                title: item.title,
                subtitle: item.subtitle,
                icon: item.icon,
                color: item.color,
                onTap: item.onTap,
                compact: isCompact,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
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
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha:
                      theme.brightness == Brightness.dark ? 0.2 : 0.03,
                ),
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
                child: Icon(
                  icon,
                  size: compact ? 20 : 23,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
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
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: compact ? 9 : 10,
                  height: 1.25,
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
// MODELS
// ============================================================
class _CarouselItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CarouselItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// ============================================================
// DASHED RING PAINTER
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