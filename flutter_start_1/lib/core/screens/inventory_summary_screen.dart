import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../storage/storage_service.dart';
import '../localization/app_localizations.dart'; // ADDED

class InventorySummaryScreen extends StatefulWidget {
  final String? token;

  const InventorySummaryScreen({
    super.key,
    this.token,
  });

  @override
  State<InventorySummaryScreen> createState() => _InventorySummaryScreenState();
}

class _InventorySummaryScreenState extends State<InventorySummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final token =
        widget.token ?? await StorageService.getUserAccessToken();

    if (!mounted) return;

    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('auth_token_required') ??
                'Authorization token is required.',
          ),
        ),
      );
      return;
    }

    await context.read<InventoryProvider>().loadSummary(token: token);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('inventory_summary') ?? 'Inventory Summary',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: loc.getString('refresh_report') ?? 'Refresh',
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.summary == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.hintColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      child: Text(loc.getString('retry') ?? 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final summary = provider.summary;

          if (summary == null) {
            return Center(
              child: Text(
                loc.getString('no_inventory_summary') ??
                    'No inventory summary available.',
                style: TextStyle(color: theme.hintColor),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(
                  theme,
                  title: loc.getString('total_items') ?? 'Total Items',
                  value: '${summary.totalItems}',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                _summaryCard(
                  theme,
                  title: loc.getString('current_stock') ?? 'Current Stock',
                  value: _format(summary.totalCurrentStock),
                  icon: Icons.warehouse_outlined,
                  color: Colors.teal,
                ),
                _summaryCard(
                  theme,
                  title: loc.getString('total_stock_in') ?? 'Total Stock In',
                  value: _format(summary.totalStockIn),
                  icon: Icons.south_west,
                  color: Colors.green,
                ),
                _summaryCard(
                  theme,
                  title: loc.getString('total_stock_out') ?? 'Total Stock Out',
                  value: _format(summary.totalStockOut),
                  icon: Icons.north_east,
                  color: Colors.orange,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    loc.getString('stock_summary_note') ??
                        'Stock quantities are totals across items. '
                            'Different units are not converted into one unit.',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}