import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../storage/storage_service.dart';
import '../providers/auth_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/customer_payment_provider.dart';
import '../localization/app_localizations.dart'; // ADDED

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final inventoryProvider = context.read<InventoryProvider>();
    final saleProvider = context.read<SaleProvider>();
    final paymentProvider = context.read<CustomerPaymentProvider>();

    final token = await StorageService.getUserAccessToken();

    if (token != null && token.isNotEmpty) {
      try {
        await inventoryProvider.loadInventory(token: token);
      } catch (_) {}
    }

    try {
      await saleProvider.loadSales();
    } catch (_) {}

    try {
      await paymentProvider.loadCustomerPayments();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final auth = context.watch<AuthProvider>();

    final inventory = context.watch<InventoryProvider>().inventory;

    final sales = context.watch<SaleProvider>().sales;
    final payments = context.watch<CustomerPaymentProvider>().payments;

    final notifications = <_NotificationItem>[];

    // ============================================================
    // 1. WELCOME MESSAGE
    // ============================================================
    final userName = _readName(auth.user);
    notifications.add(_NotificationItem(
      level: _Level.welcome,
      icon: Icons.celebration_rounded,
      title: userName.isEmpty
          ? (loc.getString('welcome_to_app') ??
              'Welcome to AlMadina Inventory')
          : (loc.getString('welcome_user_to_app') ??
                  'Welcome {name} to AlMadina Inventory')
              .replaceAll('{name}', userName),
      subtitle: loc.getString('notifications_welcome_subtitle') ??
          'You can now manage your inventory, sales, purchases and reports.',
    ));

    // ============================================================
    // 2. STOCK ALERTS
    // ============================================================
    for (final item in inventory) {
      final qty = item.currentStock;

      if (qty <= 0) {
        notifications.add(_NotificationItem(
          level: _Level.error,
          icon: Icons.error_outline_rounded,
          title: (loc.getString('item_out_of_stock') ??
                  '{item} is out of stock')
              .replaceAll('{item}', item.itemName),
          subtitle: loc.getString('item_out_of_stock_subtitle') ??
              '0 remaining • order more to continue selling',
        ));
      } else if (qty <= 5) {
        notifications.add(_NotificationItem(
          level: _Level.warning,
          icon: Icons.warning_amber_rounded,
          title: (loc.getString('item_low_stock') ??
                  '{item} is low on stock')
              .replaceAll('{item}', item.itemName),
          subtitle: (loc.getString('item_low_stock_subtitle') ??
                  '{qty} remaining • threshold is 5')
              .replaceAll('{qty}', _formatQty(qty)),
        ));
      }
    }

    // ============================================================
    // 3. RECENT SALES (last 5)
    // ============================================================
    final recentSales = sales.length > 5 ? sales.sublist(0, 5) : sales;
    for (final sale in recentSales) {
      notifications.add(_NotificationItem(
        level: _Level.info,
        icon: Icons.point_of_sale_rounded,
        title: (loc.getString('new_sale') ?? 'New sale • {invoice}')
            .replaceAll('{invoice}', sale.invoiceNo),
        subtitle: (loc.getString('new_sale_subtitle') ??
                '{customer} • {currency} • {date}')
            .replaceAll('{customer}', sale.customerName)
            .replaceAll('{currency}', sale.currencyCode)
            .replaceAll('{date}', sale.saleDate),
      ));
    }

    // ============================================================
    // 4. RECENT CUSTOMER PAYMENTS (last 5)
    // ============================================================
    final recentPayments =
        payments.length > 5 ? payments.sublist(0, 5) : payments;
    for (final p in recentPayments) {
      notifications.add(_NotificationItem(
        level: _Level.success,
        icon: Icons.payments_rounded,
        title: (loc.getString('payment_received') ??
                'Payment received • {amount}')
            .replaceAll(
                '{amount}', '${p.symbol}${p.amount.toStringAsFixed(2)}'),
        subtitle: (loc.getString('payment_received_subtitle') ??
                '{customer} • Invoice {invoice}')
            .replaceAll('{customer}', p.customerName)
            .replaceAll('{invoice}', p.invoiceNo),
      ));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('notifications') ?? 'Notifications',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_loaded)
            IconButton(
              tooltip: loc.getString('refresh_report') ?? 'Refresh',
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, i) =>
                    _buildCard(theme, notifications[i]),
              ),
            ),
    );
  }

  Widget _buildCard(ThemeData theme, _NotificationItem n) {
    final isDark = theme.brightness == Brightness.dark;

    final Color accent = switch (n.level) {
      _Level.error => Colors.red,
      _Level.warning => Colors.orange,
      _Level.success => Colors.green,
      _Level.info => Colors.blue,
      _Level.welcome => const Color(0xFFE5C77A),
    };

    return Card(
      color: theme.cardColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          textDirection: Directionality.of(context),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.20 : 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                n.icon,
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _readName(dynamic user) {
    if (user == null) return '';
    try {
      final n = user.name;
      if (n != null && n.toString().trim().isNotEmpty) {
        return n.toString().trim();
      }
    } catch (_) {}
    return '';
  }

  String _formatQty(double v) {
    return v == v.truncateToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(2);
  }
}

enum _Level { error, warning, success, info, welcome }

class _NotificationItem {
  final _Level level;
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationItem({
    required this.level,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}