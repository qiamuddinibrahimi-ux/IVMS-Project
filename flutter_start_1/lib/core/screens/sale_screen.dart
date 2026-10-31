import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sale_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED
import 'sale_form_screen.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SaleProvider>().loadSales();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredSales(SaleProvider provider) {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return provider.sales;
    }

    return provider.sales.where((sale) {
      return sale.invoiceNo.toLowerCase().contains(query) ||
          sale.customerName.toLowerCase().contains(query) ||
          sale.currencyName.toLowerCase().contains(query) ||
          sale.currencyCode.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openCreateForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SaleFormScreen()),
    );
  }

  Future<void> _openEditForm(sale) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SaleFormScreen(sale: sale)),
    );
  }

  Future<void> _deleteSale(int saleId, String invoiceNo) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_sale') ?? 'Delete Sale',
      content: (loc.getString('delete_sale_confirm') ??
              'Are you sure you want to delete invoice "{invoice}"?')
          .replaceAll('{invoice}', invoiceNo),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<SaleProvider>();
    final success = await provider.deleteSale(saleId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('sale_deleted') ?? 'Sale deleted successfully.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                (loc.getString('failed_to_delete_sale') ??
                    'Failed to delete sale.'),
          ),
        ),
      );
    }
  }

  void _showDetails(sale) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            loc.getString('sale_details') ?? 'Sale Details',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(theme, loc.getString('invoice') ?? 'Invoice',
                  sale.invoiceNo),
              _detailRow(theme, loc.getString('customer') ?? 'Customer',
                  sale.customerName),
              _detailRow(
                theme,
                loc.getString('currency') ?? 'Currency',
                '${sale.currencyName} (${sale.currencyCode})',
              ),
              _detailRow(
                  theme, loc.getString('symbol') ?? 'Symbol', sale.symbol),
              _detailRow(theme, loc.getString('sale_date') ?? 'Sale Date',
                  sale.saleDate),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<SaleProvider>();
    final sales = _getFilteredSales(provider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('sales') ?? 'Sales',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textDirection: Directionality.of(context),
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText:
                    loc.getString('search_sales_hint') ?? 'Search sales...',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
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
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),

          // CONTENT
          Expanded(
            child: provider.isLoading && provider.sales.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null && provider.sales.isEmpty
                    ? _buildError(theme, provider)
                    : sales.isEmpty
                        ? _buildEmpty(theme)
                        : RefreshIndicator(
                            onRefresh: () {
                              return provider.loadSales(forceRefresh: true);
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              itemCount: sales.length,
                              itemBuilder: (context, index) {
                                final sale = sales[index];
                                return _buildSaleCard(theme, sale);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        onPressed: _openCreateForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSaleCard(ThemeData theme, sale) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: Directionality.of(context),
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF102C4A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sale.invoiceNo,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: theme.hintColor),
                  onSelected: (value) {
                    if (value == 'details') {
                      _showDetails(sale);
                    }
                    if (value == 'edit') {
                      _openEditForm(sale);
                    }
                    if (value == 'delete') {
                      _deleteSale(sale.saleId, sale.invoiceNo);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'details',
                        child: Text(loc.getString('details') ?? 'Details')),
                    PopupMenuItem(
                        value: 'edit',
                        child: Text(loc.getString('edit') ?? 'Edit')),
                    PopupMenuItem(
                        value: 'delete',
                        child: Text(loc.getString('delete') ?? 'Delete')),
                  ],
                ),
              ],
            ),
            Divider(color: theme.dividerColor),
            Row(
              textDirection: Directionality.of(context),
              children: [
                Icon(Icons.person, size: 20, color: theme.hintColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sale.customerName,
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              textDirection: Directionality.of(context),
              children: [
                Icon(
                  Icons.currency_exchange,
                  size: 20,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${sale.currencyName} (${sale.currencyCode})',
                  style: TextStyle(color: theme.hintColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              textDirection: Directionality.of(context),
              children: [
                Icon(Icons.calendar_today, size: 18, color: theme.hintColor),
                const SizedBox(width: 8),
                Text(
                  sale.saleDate,
                  style: TextStyle(color: theme.hintColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 70, color: theme.hintColor),
          const SizedBox(height: 12),
          Text(
            _searchText.isEmpty
                ? (loc.getString('no_sales_found') ?? 'No sales found.')
                : (loc.getString('no_matching_sales') ??
                    'No matching sales found.'),
            style: TextStyle(fontSize: 16, color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, SaleProvider provider) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ??
                  (loc.getString('failed_to_load_sales') ??
                      'Failed to load sales.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.loadSales(forceRefresh: true);
              },
              child: Text(loc.getString('retry') ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}