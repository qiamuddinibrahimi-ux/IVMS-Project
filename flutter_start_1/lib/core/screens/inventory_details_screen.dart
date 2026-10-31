import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_model.dart';
import '../providers/inventory_provider.dart';
import '../storage/storage_service.dart';
import '../localization/app_localizations.dart'; // ADDED

class InventoryDetailsScreen extends StatefulWidget {
  final InventoryModel item;
  final String? token;

  const InventoryDetailsScreen({
    super.key,
    required this.item,
    this.token,
  });

  @override
  State<InventoryDetailsScreen> createState() => _InventoryDetailsScreenState();
}

class _InventoryDetailsScreenState extends State<InventoryDetailsScreen> {
  InventoryModel? _details;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token =
          widget.token ?? await StorageService.getUserAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is required.');
      }

      final result = await context.read<InventoryProvider>().loadInventoryByItem(
            token: token,
            itemId: widget.item.itemId,
          );

      if (result == null) {
        throw Exception('Could not load inventory details.');
      }

      if (!mounted) return;
      setState(() => _details = result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final item = _details ?? widget.item;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('inventory_details') ?? 'Inventory Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loadDetails,
            icon: const Icon(Icons.refresh),
            tooltip: loc.getString('refresh_report') ?? 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.hintColor),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadDetails,
                          child: Text(loc.getString('retry') ?? 'Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: theme.cardColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.itemName,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_format(item.currentStock)} '
                              '${item.unitName ?? ''}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: item.currentStock <= 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                            Text(
                              loc.getString('current_stock') ??
                                  'Current stock',
                              style: TextStyle(color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _detailTile(
                      theme,
                      loc.getString('item_id') ?? 'Item ID',
                      '${item.itemId}',
                    ),
                    _detailTile(
                      theme,
                      loc.getString('barcode') ?? 'Barcode',
                      item.barcode ?? (loc.getString('na') ?? 'N/A'),
                    ),
                    _detailTile(
                      theme,
                      loc.getString('category') ?? 'Category',
                      item.categoryName ?? (loc.getString('na') ?? 'N/A'),
                    ),
                    _detailTile(
                      theme,
                      loc.getString('unit') ?? 'Unit',
                      item.unitName ?? (loc.getString('na') ?? 'N/A'),
                    ),
                    _detailTile(
                      theme,
                      loc.getString('description') ?? 'Description',
                      item.description ?? (loc.getString('na') ?? 'N/A'),
                    ),
                    const SizedBox(height: 12),
                    _stockTile(
                      theme,
                      loc.getString('total_stock_in') ?? 'Total stock in',
                      item.totalStockIn,
                      Colors.green,
                    ),
                    _stockTile(
                      theme,
                      loc.getString('total_stock_out') ?? 'Total stock out',
                      item.totalStockOut,
                      Colors.orange,
                    ),
                    _stockTile(
                      theme,
                      loc.getString('current_stock') ?? 'Current stock',
                      item.currentStock,
                      Colors.blue,
                    ),
                  ],
                ),
    );
  }

  Widget _detailTile(ThemeData theme, String title, String value) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: theme.hintColor),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _stockTile(
    ThemeData theme,
    String title,
    double value,
    Color color,
  ) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(Icons.analytics_outlined, color: color),
        title: Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        trailing: Text(
          _format(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
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