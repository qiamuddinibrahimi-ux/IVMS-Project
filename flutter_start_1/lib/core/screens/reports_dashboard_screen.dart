import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'sales_report_screen.dart';
import 'purchases_report_screen.dart';
import 'customer_payments_report_screen.dart';
import 'vendor_payments_report_screen.dart';
import 'customer_balances_report_screen.dart';
import 'vendor_balances_report_screen.dart';
import 'inventory_report_screen.dart';
import 'item_sales_report_screen.dart';
import 'item_purchases_report_screen.dart';
import 'profit_report_screen.dart';
import 'daily_summary_report_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final reports = [
      _ReportMenuItem(
        title: loc.getString('sales_report_title') ?? 'Sales Report',
        description: loc.getString('sales_report_desc') ??
            'Sales records and currency-wise charts',
        icon: Icons.point_of_sale,
        screen: const SalesReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('purchases_report') ?? 'Purchases Report',
        description: loc.getString('purchases_report_desc') ??
            'Purchase records and totals',
        icon: Icons.shopping_cart,
        screen: const PurchasesReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('customer_payments') ?? 'Customer Payments',
        description: loc.getString('customer_payments_desc') ??
            'Payments received from customers',
        icon: Icons.payments,
        screen: const CustomerPaymentsReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('vendor_payments') ?? 'Vendor Payments',
        description: loc.getString('vendor_payments_desc') ??
            'Payments made to vendors',
        icon: Icons.account_balance_wallet,
        screen: const VendorPaymentsReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('customer_balances') ?? 'Customer Balances',
        description: loc.getString('customer_balances_desc') ??
            'Current customer outstanding balances',
        icon: Icons.people,
        screen: const CustomerBalancesReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('vendor_balances') ?? 'Vendor Balances',
        description: loc.getString('vendor_balances_desc') ??
            'Current vendor outstanding balances',
        icon: Icons.store,
        screen: const VendorBalancesReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('inventory_report') ?? 'Inventory Report',
        description: loc.getString('inventory_report_desc') ??
            'Stock in, stock out, and current stock',
        icon: Icons.inventory_2,
        screen: const InventoryReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('item_sales_title') ?? 'Item Sales',
        description: loc.getString('item_sales_desc') ??
            'Sales quantities and revenue by item',
        icon: Icons.bar_chart,
        screen: const ItemSalesReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('item_purchases_title') ?? 'Item Purchases',
        description: loc.getString('item_purchases_desc') ??
            'Purchased quantities by item',
        icon: Icons.shopping_bag,
        screen: const ItemPurchasesReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('profit_report_title') ?? 'Profit Report',
        description: loc.getString('profit_report_desc') ??
            'Allocation-based gross profit',
        icon: Icons.trending_up,
        screen: const ProfitReportScreen(),
      ),
      _ReportMenuItem(
        title: loc.getString('daily_summary') ?? 'Daily Summary',
        description: loc.getString('daily_summary_desc') ??
            'Daily sales, purchases, and payments',
        icon: Icons.today,
        screen: const DailySummaryReportScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('reports_analytics') ?? 'Reports & Analytics',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            loc.getString('business_reports') ?? 'Business Reports',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.getString('reports_dashboard_subtitle') ??
                'View read-only reports, financial summaries, '
                    'inventory information, and charts.',
            style: TextStyle(color: theme.hintColor),
          ),
          const SizedBox(height: 16),

          ...reports.map(
            (report) => Card(
              color: theme.cardColor,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  backgroundColor: theme.brightness == Brightness.dark
                      ? const Color(0xFF102C4A)
                      : const Color(0xFFE8EEF5),
                  child: Icon(
                    report.icon,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF102C4A),
                  ),
                ),
                title: Text(
                  report.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  report.description,
                  style: TextStyle(color: theme.hintColor),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.hintColor,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => report.screen,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMenuItem {
  final String title;
  final String description;
  final IconData icon;
  final Widget screen;

  const _ReportMenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.screen,
  });
}