import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_model.dart';
import '../providers/inventory_provider.dart';
import '../storage/storage_service.dart';
import '../localization/app_localizations.dart';
import '../screens/qiamuddin_design.dart';
import '../screens/inventory_item_card.dart';
import 'inventory_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  final String? token;

  const InventoryScreen({
    super.key,
    this.token,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventory();
    });

    // ✅ live filtering listener (same pattern as Customer/Vendor/Unit)
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _search = _searchController.text.trim();
      });
    });
  }

  Future<String?> _getToken() async {
    return widget.token ?? await StorageService.getUserAccessToken();
  }

  Future<void> _loadInventory() async {
    final token = await _getToken();

    if (!mounted) return;

    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('please_login_to_view_inventory') ??
                'Please log in to view inventory.',
          ),
        ),
      );
      return;
    }

    await context.read<InventoryProvider>().loadInventory(
          token: token,
        );
  }

  List<InventoryModel> _filteredItems(List<InventoryModel> items) {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) return items;

    return items.where((item) {
      return item.itemName.toLowerCase().contains(query) ||
          (item.barcode ?? '').toLowerCase().contains(query) ||
          (item.categoryName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          loc.getString('inventory') ?? 'Inventory',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // ✅ Removed the extra refresh IconButton — pull-to-refresh
        //    (RefreshIndicator below) already handles reloading.
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.inventory.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              provider.inventory.isEmpty) {
            return _ErrorView(
              theme: theme,
              message: provider.errorMessage!,
              onRetry: _loadInventory,
            );
          }

          final items = _filteredItems(provider.inventory);

          return RefreshIndicator(
            onRefresh: _loadInventory,
            child: Column(
              children: [
                // ============================================
                // ✅ FIXED: SEARCH BAR NOW MATCHES OTHER SCREENS
                //    (cardColor fill, radius 12, RTL)
                // ============================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: TextField(
                    controller: _searchController,
                    textDirection: Directionality.of(context),
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: loc.getString('search_items_hint') ??
                          'Search items, barcode, category',
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: theme.hintColor),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              onPressed: () => _searchController.clear(),
                              icon: Icon(Icons.clear_rounded,
                                  color: theme.hintColor),
                            )
                          : null,
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // ============================================
                // ERROR MESSAGE
                // ============================================
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // ============================================
                // ITEM COUNT HEADER
                // ============================================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    textDirection: Directionality.of(context),
                    children: [
                      Expanded(
                        child: Text(
                          loc.getString('inventory_items') ??
                              'Inventory items',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        (loc.getString('items_count') ?? '{count} items')
                            .replaceAll('{count}', '${items.length}'),
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),

                // ============================================
                // LIST / EMPTY STATE
                // ============================================
                Expanded(
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 100),
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: theme.hintColor,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                loc.getString('no_inventory_items_found') ??
                                    'No inventory items found.',
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return InventoryItemCard(
                              item: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InventoryDetailsScreen(
                                      item: item,
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final ThemeData theme;
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.theme,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.getString('retry') ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}