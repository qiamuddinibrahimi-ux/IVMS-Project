import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

import 'item_form_screen.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ItemProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ItemModel> _filteredItems(List<ItemModel> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }

    return items.where((item) {
      final name = item.itemName.toLowerCase();
      final category = item.categoryName.toLowerCase();
      final unit = item.unitName.toLowerCase();
      final barcode = item.barcode?.toLowerCase() ?? "";
      final description = item.description?.toLowerCase() ?? "";

      return name.contains(_searchQuery) ||
          category.contains(_searchQuery) ||
          unit.contains(_searchQuery) ||
          barcode.contains(_searchQuery) ||
          description.contains(_searchQuery);
    }).toList();
  }

  Future<void> _addItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ItemFormScreen(),
      ),
    );
  }

  Future<void> _editItem(ItemModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(item: item),
      ),
    );
  }

  Future<void> _deleteItem(ItemModel item) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_item') ?? "Delete Item?",
      content: (loc.getString('delete_item_confirm') ??
              'Are you sure you want to delete "{name}"?')
          .replaceAll('{name}', item.itemName),
      cancelText: loc.getString('cancel') ?? "Cancel",
      deleteText: loc.getString('delete') ?? "Delete",
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final provider = context.read<ItemProvider>();
    final success = await provider.deleteItem(item.itemId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('item_deleted') ?? "Item deleted successfully.",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                (loc.getString('failed_to_delete_item') ??
                    "Failed to delete item."),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refresh() async {
    await context.read<ItemProvider>().loadItems(forceRefresh: true);
  }

  void _showDetails(ItemModel item) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            loc.getString('item_details') ?? "Item Details",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  theme,
                  loc.getString('item_id') ?? "Item ID",
                  item.itemId.toString(),
                ),
                _detailRow(
                  theme,
                  loc.getString('item_name') ?? "Item Name",
                  item.itemName,
                ),
                _detailRow(
                  theme,
                  loc.getString('category') ?? "Category",
                  item.categoryName,
                ),
                _detailRow(
                  theme,
                  loc.getString('unit') ?? "Unit",
                  item.unitName,
                ),
                _detailRow(
                  theme,
                  loc.getString('barcode') ?? "Barcode",
                  item.barcode?.isNotEmpty == true
                      ? item.barcode!
                      : (loc.getString('not_provided') ?? "Not provided"),
                ),
                _detailRow(
                  theme,
                  loc.getString('description') ?? "Description",
                  item.description?.isNotEmpty == true
                      ? item.description!
                      : (loc.getString('no_description') ?? "No description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.getString('close') ?? "Close",
                style: TextStyle(color: theme.hintColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<ItemProvider>();
    final items = _filteredItems(provider.items);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('items') ?? "Items",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: loc.getString('refresh_report') ?? "Refresh",
            onPressed: provider.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        icon: const Icon(Icons.add),
        label: Text(loc.getString('add_item') ?? "Add Item"),
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              textDirection: Directionality.of(context),
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: loc.getString('search_items') ?? "Search items...",
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.hintColor,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: Icon(
                          Icons.clear,
                          color: theme.hintColor,
                        ),
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

          // LOADING
          if (provider.isLoading && provider.items.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )

          // ERROR
          else if (provider.errorMessage != null && provider.items.isEmpty)
            Expanded(
              child: _ErrorView(
                theme: theme,
                message: provider.errorMessage!,
                onRetry: _refresh,
              ),
            )

          // EMPTY
          else if (items.isEmpty)
            Expanded(
              child: _EmptyView(
                theme: theme,
                isSearching: _searchQuery.isNotEmpty,
                onAdd: _addItem,
              ),
            )

          // LIST
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return _ItemCard(
                      theme: theme,
                      item: item,
                      onTap: () => _showDetails(item),
                      onEdit: () => _editItem(item),
                      onDelete: () => _deleteItem(item),
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

// ============================================================
// ITEM CARD  (kept; only translated)
// ============================================================

class _ItemCard extends StatelessWidget {
  final ThemeData theme;
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.theme,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF102C4A)
                          : const Color(0xFFE8F0F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF174A7E),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF102C4A)
                                    : const Color(0xFFE8F0F7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.unitName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF174A7E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: theme.dividerColor,
              ),
              const SizedBox(height: 8),
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Expanded(
                    child: Text(
                      item.barcode?.isNotEmpty == true
                          ? '${loc.getString('barcode') ?? "Barcode"}: ${item.barcode}'
                          : (loc.getString('no_barcode') ?? "No barcode"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: loc.getString('edit') ?? "Edit",
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 21,
                      color: theme.hintColor,
                    ),
                  ),
                  IconButton(
                    tooltip: loc.getString('delete') ?? "Delete",
                    onPressed: onDelete,
                    color: Colors.red,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY VIEW
// ============================================================

class _EmptyView extends StatelessWidget {
  final ThemeData theme;
  final bool isSearching;
  final VoidCallback onAdd;

  const _EmptyView({
    required this.theme,
    required this.isSearching,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 70,
              color: theme.hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? (loc.getString('no_items_found') ?? "No items found")
                  : (loc.getString('no_items_yet') ?? "No items yet"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (!isSearching)
              Text(
                loc.getString('create_first_item') ??
                    "Create your first inventory item.",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
            if (!isSearching) const SizedBox(height: 20),
            if (!isSearching)
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(loc.getString('add_item') ?? "Add Item"),
              ),
          ],
        ),
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
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              loc.getString('failed_to_load_items') ?? "Failed to load items",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.getString('try_again') ?? "Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}