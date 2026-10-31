import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../models/purchase_model.dart';
import '../models/purchase_detail_model.dart';
import '../providers/purchase_detail_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class PurchaseDetailsScreen extends StatefulWidget {
  final String token;
  final List<PurchaseModel> purchases;
  final List<ItemModel> items;

  const PurchaseDetailsScreen({
    super.key,
    required this.token,
    required this.purchases,
    required this.items,
  });

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  static const Color gold = Color(0xFFE5C77A);

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  int? _selectedPurchaseId;
  int? _selectedItemId;
  int? _editingDetailId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PurchaseDetailProvider>().loadDetails(token: widget.token);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _quantity =>
      double.tryParse(_quantityController.text.trim()) ?? 0;

  double get _price => double.tryParse(_priceController.text.trim()) ?? 0;

  double get _lineTotal => _quantity * _price;

  void _showMessage(String message, {bool error = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error
            ? Colors.red.shade700
            : (theme.brightness == Brightness.dark
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF102C4A)),
      ),
    );
  }

  String _formatNumber(double value) => value.toStringAsFixed(2);

  void _clearForm() {
    _formKey.currentState?.reset();

    setState(() {
      _editingDetailId = null;
      _selectedPurchaseId = null;
      _selectedItemId = null;
      _quantityController.clear();
      _priceController.clear();
    });
  }

  void _editDetail(PurchaseDetailModel detail) {
    final purchaseExists = widget.purchases.any(
      (purchase) => purchase.purchaseId == detail.purchaseId,
    );

    final itemExists = widget.items.any(
      (item) => item.itemId == detail.itemId,
    );

    setState(() {
      _editingDetailId = detail.purchaseDetailId;
      _selectedPurchaseId = purchaseExists ? detail.purchaseId : null;
      _selectedItemId = itemExists ? detail.itemId : null;
      _quantityController.text = detail.quantity.toString();
      _priceController.text = detail.unitPrice.toString();
    });

    _formKey.currentState?.reset();
  }

  Future<void> _saveDetail() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final purchaseId = _selectedPurchaseId;
    final itemId = _selectedItemId;

    if (purchaseId == null || itemId == null) {
      _showMessage(
        loc.getString('select_purchase_and_item') ??
            'Please select a purchase invoice and item.',
        error: true,
      );
      return;
    }

    final provider = context.read<PurchaseDetailProvider>();

    final success = await provider.saveDetail(
      token: widget.token,
      detailId: _editingDetailId,
      purchaseId: purchaseId,
      itemId: itemId,
      quantity: _quantity,
      unitPrice: _price,
    );

    if (!mounted) return;

    if (success) {
      _clearForm();
      _showMessage(
        _editingDetailId == null
            ? (loc.getString('purchase_detail_created') ??
                'Purchase detail created successfully.')
            : (loc.getString('purchase_detail_updated') ??
                'Purchase detail updated successfully.'),
      );
    } else {
      _showMessage(
        provider.errorMessage ??
            (loc.getString('could_not_save_purchase_detail') ??
                'Could not save purchase detail.'),
        error: true,
      );
    }
  }

  Future<void> _deleteDetail(PurchaseDetailModel detail) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_purchase_detail') ??
          'Delete purchase detail?',
      content: (loc.getString('delete_purchase_detail_confirm') ??
              'Delete {item} from purchase #{id}?')
          .replaceAll('{item}', detail.itemName)
          .replaceAll('{id}', '${detail.purchaseId}'),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<PurchaseDetailProvider>();

    final success = await provider.removeDetail(
      token: widget.token,
      detailId: detail.purchaseDetailId,
    );

    if (!mounted) return;

    if (success) {
      if (_editingDetailId == detail.purchaseDetailId) {
        _clearForm();
      }
      _showMessage(
        loc.getString('purchase_detail_deleted') ??
            'Purchase detail deleted successfully.',
      );
    } else {
      _showMessage(
        provider.errorMessage ??
            (loc.getString('could_not_delete_purchase_detail') ??
                'Could not delete purchase detail.'),
        error: true,
      );
    }
  }

  String _purchaseLabel(PurchaseModel purchase) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final invoice = purchase.invoiceNo.isEmpty
        ? (loc.getString('purchase_num') ?? 'Purchase #{id}')
            .replaceAll('{id}', '${purchase.purchaseId}')
        : purchase.invoiceNo;

    final vendor = purchase.vendorName.isEmpty
        ? (loc.getString('unknown_vendor') ?? 'Unknown vendor')
        : purchase.vendorName;

    final date = purchase.purchaseDate.isEmpty
        ? ''
        : ' • ${purchase.purchaseDate.split('T').first}';

    return '$invoice • $vendor$date';
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
          loc.getString('purchase_details') ?? 'Purchase Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: loc.getString('refresh_records') ?? 'Refresh records',
            onPressed: () {
              context.read<PurchaseDetailProvider>().loadDetails(
                    token: widget.token,
                  );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<PurchaseDetailProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildForm(provider, theme),
              const SizedBox(height: 22),
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Expanded(
                    child: Text(
                      loc.getString('purchase_detail_records') ??
                          'Purchase detail records',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    (loc.getString('records_count') ?? '{count} records')
                        .replaceAll('{count}', '${provider.details.length}'),
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (provider.isLoading) const LinearProgressIndicator(),

              if (provider.errorMessage != null) ...[
                const SizedBox(height: 10),
                _errorCard(provider.errorMessage!, theme),
              ],

              if (!provider.isLoading &&
                  provider.details.isEmpty &&
                  provider.errorMessage == null)
                Card(
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        loc.getString('no_purchase_details') ??
                            'No purchase details found.',
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                  ),
                ),

              ...provider.details.map((d) => _buildDetailCard(d, theme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(PurchaseDetailProvider provider, ThemeData theme) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editingDetailId == null
                    ? (loc.getString('add_purchase_detail') ??
                        'Add Purchase Detail')
                    : (loc.getString('edit_purchase_detail') ??
                        'Edit Purchase Detail'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _selectedPurchaseId,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: loc.getString('purchase_invoice_required') ??
                      'Purchase invoice *',
                  labelStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.receipt_long, color: theme.hintColor),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: widget.purchases.map((purchase) {
                  return DropdownMenuItem<int>(
                    value: purchase.purchaseId,
                    child: Text(
                      _purchaseLabel(purchase),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPurchaseId = value);
                },
                validator: (value) => value == null
                    ? (loc.getString('select_purchase_invoice') ??
                        'Select a purchase invoice.')
                    : null,
              ),

              if (widget.purchases.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    loc.getString('no_purchases_supplied') ??
                        'No purchases were supplied. Load purchases first.',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 14),

              DropdownButtonFormField<int>(
                value: _selectedItemId,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: loc.getString('item_required') ?? 'Item *',
                  labelStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.inventory_2, color: theme.hintColor),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: widget.items.map((item) {
                  return DropdownMenuItem<int>(
                    value: item.itemId,
                    child: Text(
                      '${item.itemName} (#${item.itemId})',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedItemId = value);
                },
                validator: (value) => value == null
                    ? (loc.getString('select_item') ?? 'Select an item.')
                    : null,
              ),

              if (widget.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    loc.getString('no_items_supplied') ??
                        'No items were supplied. Load items first.',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textDirection: Directionality.of(context),
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: loc.getString('quantity_required') ??
                      'Quantity *',
                  labelStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.numbers, color: theme.hintColor),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final quantity = double.tryParse(value?.trim() ?? '');

                  if (quantity == null ||
                      !quantity.isFinite ||
                      quantity <= 0) {
                    return loc.getString('enter_quantity_greater') ??
                        'Enter a quantity greater than zero.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textDirection: Directionality.of(context),
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: loc.getString('unit_price_required') ??
                      'Unit price *',
                  labelStyle: TextStyle(color: theme.hintColor),
                  prefixIcon:
                      Icon(Icons.payments_outlined, color: theme.hintColor),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');

                  if (price == null || !price.isFinite || price < 0) {
                    return loc.getString('enter_valid_price') ??
                        'Enter a valid price of zero or greater.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: Text(
                        loc.getString('line_total') ?? 'Line total',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      _formatNumber(_lineTotal),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF102C4A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ✅ QIAMUDDIN PRIMARY BUTTON
              QiamuddinDesign.primaryButton(
                context: context,
                text: provider.isSaving
                    ? (loc.getString('saving') ?? 'Saving...')
                    : _editingDetailId == null
                        ? (loc.getString('add_purchase_detail') ??
                            'Add Purchase Detail')
                        : (loc.getString('update_purchase_detail') ??
                            'Update Purchase Detail'),
                icon: _editingDetailId == null ? Icons.add : Icons.save,
                isLoading: provider.isSaving,
                onPressed: provider.isSaving ||
                        widget.purchases.isEmpty ||
                        widget.items.isEmpty
                    ? null
                    : _saveDetail,
              ),

              if (_editingDetailId != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _clearForm,
                    child: Text(
                      loc.getString('cancel_editing') ?? 'Cancel editing',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(PurchaseDetailModel detail, ThemeData theme) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final purchase = widget.purchases
        .where((p) => p.purchaseId == detail.purchaseId)
        .firstOrNull;

    final currency = purchase?.symbol.isNotEmpty == true
        ? purchase!.symbol
        : purchase?.currencyCode ?? '';

    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: Directionality.of(context),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF102C4A),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.itemName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        (loc.getString('purchase_num') ?? 'Purchase #{id}')
                                .replaceAll(
                                    '{id}', '${detail.purchaseId}') +
                            ' • ' +
                            (loc.getString('detail_num') ?? 'Detail #{id}')
                                .replaceAll(
                                    '{id}', '${detail.purchaseDetailId}'),
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: loc.getString('edit') ?? 'Edit',
                  onPressed: () => _editDetail(detail),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF102C4A),
                  ),
                ),
                IconButton(
                  tooltip: loc.getString('delete') ?? 'Delete',
                  onPressed: () => _deleteDetail(detail),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Divider(height: 22, color: theme.dividerColor),
            _detailRow(
              theme,
              loc.getString('quantity_short') ?? 'Quantity',
              detail.quantity.toString(),
            ),
            _detailRow(
              theme,
              loc.getString('unit_price') ?? 'Unit price',
              '$currency ${_formatNumber(detail.unitPrice)}',
            ),
            _detailRow(
              theme,
              loc.getString('line_total') ?? 'Line total',
              '$currency ${_formatNumber(detail.lineTotal)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    ThemeData theme,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: theme.hintColor),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: bold
                  ? (theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF102C4A))
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message, ThemeData theme) {
    return Card(
      color: theme.brightness == Brightness.dark
          ? Colors.red.withValues(alpha: 0.2)
          : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.red.shade300
                : Colors.red.shade800,
          ),
        ),
      ),
    );
  }
}