import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/stock_movement_model.dart';
import '../models/item_model.dart';
import '../models/purchase_model.dart';
import '../models/sale_model.dart';
import '../providers/stock_movement_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED
import '../screens/stock_movement_card.dart';
import 'stock_movement_details_screen.dart';
import 'stock_movement_form_screen.dart';

class StockMovementScreen extends StatefulWidget {
  final List<ItemModel> items;
  final List<PurchaseModel> purchases;
  final List<SaleModel> sales;
  final String? token;

  const StockMovementScreen({
    super.key,
    required this.items,
    required this.purchases,
    required this.sales,
    this.token,
  });

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StockMovementProvider>().loadMovements(
            token: widget.token,
          );
    });
  }

  Future<void> _openForm({StockMovementModel? movement}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StockMovementFormScreen(
          items: widget.items,
          purchases: widget.purchases,
          sales: widget.sales,
          token: widget.token,
          movement: movement,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await context.read<StockMovementProvider>().loadMovements(
            token: widget.token,
          );
    }
  }

  Future<void> _deleteMovement(StockMovementModel movement) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title:
          loc.getString('delete_stock_movement') ?? 'Delete Stock Movement',
      content: (loc.getString('delete_stock_movement_confirm') ??
              'Delete movement #{id} for {item}?')
          .replaceAll('{id}', '${movement.movementId}')
          .replaceAll('{item}', movement.itemName),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<StockMovementProvider>();

    final success = await provider.deleteMovement(
      movementId: movement.movementId,
      token: widget.token,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (loc.getString('stock_movement_deleted') ??
                  'Stock movement deleted.')
              : (provider.errorMessage ??
                  (loc.getString('delete_failed') ?? 'Delete failed.')),
        ),
      ),
    );
  }

  void _openDetails(StockMovementModel movement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockMovementDetailsScreen(movement: movement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<StockMovementProvider>();

    final movements = provider.movements.where((movement) {
      if (_filter == 'IN') return movement.isStockIn;
      if (_filter == 'OUT') return movement.isStockOut;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('stock_movements') ?? 'Stock Movements',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: loc.getString('refresh_report') ?? 'Refresh',
            onPressed: provider.isLoading
                ? null
                : () => provider.loadMovements(token: widget.token),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.items.isEmpty ? null : () => _openForm(),
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        icon: const Icon(Icons.add),
        label: Text(loc.getString('new_movement') ?? 'New Movement'),
      ),
      body: Column(
        children: [
          // SUMMARY CARDS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              textDirection: Directionality.of(context),
              children: [
                Expanded(
                  child: _summaryCard(
                    theme,
                    loc.getString('total') ?? 'Total',
                    provider.movements.length.toString(),
                    Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryCard(
                    theme,
                    loc.getString('stock_in_short') ?? 'Stock In',
                    provider.movements
                        .where((m) => m.isStockIn)
                        .length
                        .toString(),
                    Icons.south_west,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryCard(
                    theme,
                    loc.getString('stock_out_short') ?? 'Stock Out',
                    provider.movements
                        .where((m) => m.isStockOut)
                        .length
                        .toString(),
                    Icons.north_east,
                  ),
                ),
              ],
            ),
          ),

          // FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<String>(
              style: SegmentedButton.styleFrom(
                backgroundColor: theme.cardColor,
                foregroundColor: theme.colorScheme.onSurface,
                selectedBackgroundColor:
                    theme.brightness == Brightness.dark
                        ? const Color(0xFFE0E0E0)
                        : const Color(0xFF102C4A),
                selectedForegroundColor:
                    theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                side: BorderSide(color: theme.dividerColor),
              ),
              segments: [
                ButtonSegment(
                  value: 'ALL',
                  label: Text(loc.getString('all') ?? 'All'),
                ),
                const ButtonSegment(value: 'IN', label: Text('IN')),
                const ButtonSegment(value: 'OUT', label: Text('OUT')),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) {
                setState(() => _filter = selection.first);
              },
            ),
          ),
          const SizedBox(height: 8),

          // BODY
          Expanded(child: _buildBody(theme, provider, movements)),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    StockMovementProvider provider,
    List<StockMovementModel> movements,
  ) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (provider.isLoading && provider.movements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.movements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    provider.loadMovements(token: widget.token),
                child: Text(loc.getString('try_again') ?? 'Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (movements.isEmpty) {
      return Center(
        child: Text(
          loc.getString('no_stock_movements_found') ??
              'No stock movements found.',
          style: TextStyle(color: theme.hintColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMovements(token: widget.token),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: movements.length,
        itemBuilder: (context, index) {
          final movement = movements[index];

          return StockMovementCard(
            movement: movement,
            onTap: () => _openDetails(movement),
            onEdit: () => _openForm(movement: movement),
            onDelete: () => _deleteMovement(movement),
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 82,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.hintColor),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}