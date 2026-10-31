import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../storage/storage_service.dart';
import '../localization/app_localizations.dart'; // ADDED

class LowStockScreen extends StatefulWidget {
  final String? token;

  const LowStockScreen({
    super.key,
    this.token,
  });

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  final TextEditingController _thresholdController =
      TextEditingController(text: '5');

  double _threshold = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final token = widget.token ?? await StorageService.getUserAccessToken();

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

    await context.read<InventoryProvider>().loadLowStockItems(
          token: token,
          threshold: _threshold,
        );
  }

  void _applyThreshold() {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final value = double.tryParse(_thresholdController.text);

    if (value == null || !value.isFinite || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('invalid_threshold') ??
                'Enter a valid threshold of zero or more.',
          ),
        ),
      );
      return;
    }

    setState(() => _threshold = value);
    _load();
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
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
          loc.getString('low_stock_items') ?? 'Low Stock Items',
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
          return Column(
            children: [
              // ============================================
              // THRESHOLD INPUT
              // ============================================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _thresholdController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textDirection: Directionality.of(context),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText:
                              loc.getString('stock_threshold') ??
                                  'Stock threshold',
                          labelStyle: TextStyle(color: theme.hintColor),
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _applyThreshold,
                      child: Text(loc.getString('apply') ?? 'Apply'),
                    ),
                  ],
                ),
              ),

              if (provider.isLoading)
                const LinearProgressIndicator(),

              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // ============================================
              // HEADER
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: Text(
                        (loc.getString('items_at_or_below') ??
                                'Items at or below {value}')
                            .replaceAll(
                                '{value}', _format(_threshold)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${provider.lowStockItems.length} '
                      '${loc.getString('items') ?? 'items'}',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
              ),

              // ============================================
              // LIST / EMPTY STATE
              // ============================================
              Expanded(
                child: provider.lowStockItems.isEmpty && !provider.isLoading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 90),
                          const Icon(
                            Icons.check_circle_outline,
                            size: 56,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              loc.getString('no_low_stock_items') ??
                                  'No low-stock items found.',
                              style: TextStyle(color: theme.hintColor),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.lowStockItems.length,
                        itemBuilder: (context, index) {
                          final item = provider.lowStockItems[index];
                          final outOfStock = item.currentStock <= 0;

                          return Card(
                            color: theme.cardColor,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: Icon(
                                outOfStock
                                    ? Icons.warning_amber_rounded
                                    : Icons.inventory_2_outlined,
                                color: outOfStock
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                              title: Text(
                                item.itemName,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${loc.getString('category') ?? 'Category'}: '
                                '${item.categoryName ?? (loc.getString('na') ?? 'N/A')}'
                                '\n${loc.getString('unit') ?? 'Unit'}: '
                                '${item.unitName ?? (loc.getString('na') ?? 'N/A')}'
                                '${item.barcode == null ? '' : '\n${loc.getString('barcode') ?? 'Barcode'}: ${item.barcode}'}',
                                style: TextStyle(color: theme.hintColor),
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _format(item.currentStock),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: outOfStock
                                          ? Colors.red
                                          : Colors.orange,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    outOfStock
                                        ? (loc.getString('out_of_stock') ??
                                            'Out of stock')
                                        : (loc.getString('low_stock') ??
                                            'Low stock'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}