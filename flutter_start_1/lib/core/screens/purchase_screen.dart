import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purchase_model.dart';
import '../providers/purchase_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED
import 'purchase_form_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PurchaseProvider>().loadPurchases();
    });

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PurchaseModel> _filteredPurchases(List<PurchaseModel> purchases) {
    if (_searchText.isEmpty) {
      return purchases;
    }

    return purchases.where((purchase) {
      return purchase.invoiceNo.toLowerCase().contains(_searchText) ||
          purchase.vendorName.toLowerCase().contains(_searchText) ||
          purchase.currencyName.toLowerCase().contains(_searchText) ||
          purchase.currencyCode.toLowerCase().contains(_searchText);
    }).toList();
  }

  Future<void> _addPurchase() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PurchaseFormScreen(),
      ),
    );
  }

  Future<void> _editPurchase(PurchaseModel purchase) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseFormScreen(purchase: purchase),
      ),
    );
  }

  void _showDetails(PurchaseModel purchase) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            loc.getString('purchase_details') ?? 'Purchase Details',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(theme,
                  loc.getString('invoice') ?? 'Invoice', purchase.invoiceNo),
              _detailRow(theme,
                  loc.getString('vendor') ?? 'Vendor', purchase.vendorName),
              _detailRow(
                theme,
                loc.getString('currency') ?? 'Currency',
                '${purchase.currencyName} (${purchase.currencyCode})',
              ),
              _detailRow(theme,
                  loc.getString('symbol') ?? 'Symbol', purchase.symbol),
              _detailRow(
                  theme,
                  loc.getString('purchase_date') ?? 'Purchase Date',
                  purchase.purchaseDate),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.getString('close') ?? 'Close',
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: theme.hintColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePurchase(PurchaseModel purchase) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_purchase') ?? 'Delete Purchase',
      content: (loc.getString('delete_purchase_confirm') ??
              'Are you sure you want to delete invoice "{invoice}"?')
          .replaceAll('{invoice}', purchase.invoiceNo),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<PurchaseProvider>();
    final success = await provider.deletePurchase(purchase.purchaseId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('purchase_deleted') ??
                'Purchase deleted successfully.',
          ),
        ),
      );
    } else {
      final error = provider.errorMessage ??
          (loc.getString('failed_to_delete_purchase') ??
              'Failed to delete purchase.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<PurchaseProvider>();
    final purchases = _filteredPurchases(provider.purchases);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('purchases') ?? 'Purchases',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              textDirection: Directionality.of(context),
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: loc.getString('search_purchases_hint') ??
                    'Search invoice, vendor or currency...',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: Icon(Icons.clear, color: theme.hintColor),
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

          // CONTENT
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                return provider.loadPurchases(forceRefresh: true);
              },
              child: _buildContent(theme, provider, purchases),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPurchase,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        icon: const Icon(Icons.add),
        label: Text(loc.getString('add_purchase') ?? 'Add Purchase'),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    PurchaseProvider provider,
    List<PurchaseModel> purchases,
  ) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (provider.isLoading && provider.purchases.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null && provider.purchases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  provider.loadPurchases(forceRefresh: true);
                },
                child: Text(loc.getString('try_again') ?? 'Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.purchases.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: theme.hintColor,
                ),
                const SizedBox(height: 12),
                Text(
                  loc.getString('no_purchases_found') ??
                      'No purchases found.',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (purchases.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          Center(
            child: Text(
              loc.getString('no_matching_purchases') ??
                  'No matching purchases found.',
              style: TextStyle(color: theme.hintColor),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];

        return Card(
          color: theme.cardColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFF102C4A),
              foregroundColor: theme.brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              child: Text(
                purchase.invoiceNo.isNotEmpty
                    ? purchase.invoiceNo.substring(0, 1).toUpperCase()
                    : '#',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${loc.getString('invoice') ?? 'Invoice'}: ${purchase.invoiceNo}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${loc.getString('vendor') ?? 'Vendor'}: ${purchase.vendorName}',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${loc.getString('currency') ?? 'Currency'}: ${purchase.currencyName} (${purchase.currencyCode})',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${loc.getString('purchase_date') ?? 'Date'}: ${purchase.purchaseDate}',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            isThreeLine: true,
            onTap: () {
              _showDetails(purchase);
            },
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: theme.hintColor),
              onSelected: (value) {
                if (value == 'edit') {
                  _editPurchase(purchase);
                }
                if (value == 'delete') {
                  _deletePurchase(purchase);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 10),
                        Text(loc.getString('edit') ?? 'Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 10),
                        Text(loc.getString('delete') ?? 'Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        );
      },
    );
  }
}