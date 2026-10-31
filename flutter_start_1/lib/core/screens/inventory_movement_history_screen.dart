import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../storage/storage_service.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class InventoryMovementHistoryScreen extends StatefulWidget {
  final String? token;

  const InventoryMovementHistoryScreen({
    super.key,
    this.token,
  });

  @override
  State<InventoryMovementHistoryScreen> createState() =>
      _InventoryMovementHistoryScreenState();
}

class _InventoryMovementHistoryScreenState
    extends State<InventoryMovementHistoryScreen> {
  int? _itemId;
  String? _movementType;
  String? _sourceType;

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

    await context.read<InventoryProvider>().loadMovementHistory(
          token: token,
          itemId: _itemId,
          movementType: _movementType,
          sourceType: _sourceType,
        );
  }

  void _resetFilters() {
    setState(() {
      _itemId = null;
      _movementType = null;
      _sourceType = null;
    });
    _load();
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
          loc.getString('inventory_movement_history') ??
              'Inventory Movement History',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // ============================================
                // ITEM FILTER
                // ============================================
                DropdownButtonFormField<int?>(
                  value: _itemId,
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText:
                        loc.getString('filter_by_item') ?? 'Filter by item',
                    labelStyle: TextStyle(color: theme.hintColor),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        loc.getString('all_items') ?? 'All items',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    ...context.read<InventoryProvider>().inventory.map(
                          (item) => DropdownMenuItem<int?>(
                            value: item.itemId,
                            child: Text(
                              item.itemName,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                  ],
                  onChanged: (value) {
                    setState(() => _itemId = value);
                  },
                ),
                const SizedBox(height: 8),

                // ============================================
                // MOVEMENT TYPE FILTER
                // ============================================
                DropdownButtonFormField<String?>(
                  value: _movementType,
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText:
                        loc.getString('movement_type') ?? 'Movement type',
                    labelStyle: TextStyle(color: theme.hintColor),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        loc.getString('all_movement_types') ??
                            'All movement types',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'IN',
                      child: Text(
                        'IN',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'OUT',
                      child: Text(
                        'OUT',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _movementType = value);
                  },
                ),
                const SizedBox(height: 8),

                // ============================================
                // SOURCE TYPE FILTER
                // ============================================
                DropdownButtonFormField<String?>(
                  value: _sourceType,
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText:
                        loc.getString('source_type') ?? 'Source type',
                    labelStyle: TextStyle(color: theme.hintColor),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        loc.getString('all_sources') ?? 'All sources',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'PURCHASE',
                      child: Text(
                        loc.getString('source_purchase') ?? 'Purchase',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'SALE',
                      child: Text(
                        loc.getString('source_sale') ?? 'Sale',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'OPENING',
                      child: Text(
                        loc.getString('source_opening') ?? 'Opening',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'ADJUSTMENT',
                      child: Text(
                        loc.getString('source_adjustment') ?? 'Adjustment',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'RETURN',
                      child: Text(
                        loc.getString('source_return') ?? 'Return',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _sourceType = value);
                  },
                ),
                const SizedBox(height: 10),

                // ============================================
                // APPLY / RESET BUTTONS
                // ============================================
                Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      // ✅ QIAMUDDIN APPLY BUTTON
                      child: QiamuddinDesign.primaryButton(
                        context: context,
                        text: loc.getString('apply_filters') ??
                            'Apply filters',
                        icon: Icons.filter_alt,
                        onPressed: _load,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.dividerColor),
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                      child: Text(loc.getString('reset') ?? 'Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.movements.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null &&
                    provider.movements.isEmpty) {
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
                            child: Text(
                              loc.getString('retry') ?? 'Retry',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.movements.isEmpty) {
                  return Center(
                    child: Text(
                      loc.getString('no_movement_records') ??
                          'No movement records found.',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: provider.movements.length,
                    itemBuilder: (context, index) {
                      final movement = provider.movements[index];

                      final isIn = movement.isStockIn;

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
                          leading: CircleAvatar(
                            backgroundColor:
                                (isIn ? Colors.green : Colors.red)
                                    .withValues(alpha: 0.12),
                            child: Icon(
                              isIn ? Icons.south_west : Icons.north_east,
                              color: isIn ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            movement.itemName,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '${loc.getString('source_label') ?? 'Source'}: '
                            '${movement.sourceType}'
                            '${movement.sourceId == null ? '' : ' #${movement.sourceId}'}'
                            '\n${loc.getString('date') ?? 'Date'}: '
                            '${movement.createdAt?.toLocal().toString() ?? (loc.getString('na') ?? 'N/A')}'
                            '\n${loc.getString('movement_id') ?? 'Movement ID'}: '
                            '${movement.movementId}',
                            style: TextStyle(color: theme.hintColor),
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isIn ? '+' : '-'}${_format(movement.quantity)}',
                                style: TextStyle(
                                  color: isIn ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                movement.movementType,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}