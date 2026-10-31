import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../models/sale_model.dart';
import '../models/sales_detail_model.dart';
import '../providers/sales_detail_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class SalesDetailsScreen extends StatefulWidget {
  final String token;
  final List<SaleModel> sales;
  final List<ItemModel> items;

  const SalesDetailsScreen({
    super.key,
    required this.token,
    required this.sales,
    required this.items,
  });

  @override
  State<SalesDetailsScreen> createState() => _SalesDetailsScreenState();
}

class _SalesDetailsScreenState extends State<SalesDetailsScreen> {
  static const Color gold = Color(0xFFE5C77A);

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  int? _selectedSaleId;
  int? _selectedItemId;
  int? _editingDetailId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SalesDetailProvider>().loadDetails(token: widget.token);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    setState(() {
      _selectedSaleId = null;
      _selectedItemId = null;
      _editingDetailId = null;
      _quantityController.clear();
      _unitPriceController.clear();
    });
  }

  double get _lineTotal {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_unitPriceController.text) ?? 0;
    return quantity * price;
  }

  Future<void> _saveDetail() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSaleId == null || _selectedItemId == null) {
      _showMessage(
          loc.getString('please_select_sale_and_item') ??
              'Please select a sale and an item.');
      return;
    }

    final provider = context.read<SalesDetailProvider>();

    final success = await provider.saveDetail(
      token: widget.token,
      detailId: _editingDetailId,
      saleId: _selectedSaleId!,
      itemId: _selectedItemId!,
      quantity: double.parse(_quantityController.text.trim()),
      unitPrice: double.parse(_unitPriceController.text.trim()),
    );

    if (!mounted) return;

    if (success) {
      _resetForm();
      _showMessage(
        _editingDetailId == null
            ? (loc.getString('sales_detail_created') ??
                'Sales detail created successfully.')
            : (loc.getString('sales_detail_updated') ??
                'Sales detail updated successfully.'),
      );
    } else {
      _showMessage(provider.errorMessage ??
          (loc.getString('could_not_save_sales_detail') ??
              'Could not save sales detail.'));
    }
  }

  void _editDetail(SalesDetailModel detail) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final saleExists =
        widget.sales.any((sale) => sale.saleId == detail.saleId);
    final itemExists =
        widget.items.any((item) => item.itemId == detail.itemId);

    setState(() {
      _editingDetailId = detail.saleDetailId;
      _selectedSaleId = saleExists ? detail.saleId : null;
      _selectedItemId = itemExists ? detail.itemId : null;
      _quantityController.text = _formatNumber(detail.quantity);
      _unitPriceController.text = _formatNumber(detail.unitPrice);
    });

    _showMessage(
      (loc.getString('editing_sales_detail_num') ??
              'Editing sales detail #{id}')
          .replaceAll('{id}', '${detail.saleDetailId}'),
    );
  }

  Future<void> _deleteDetail(SalesDetailModel detail) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_sales_detail') ?? 'Delete Sales Detail',
      content: (loc.getString('delete_sales_detail_confirm') ??
              'Delete sales detail #{id} for {item}?')
          .replaceAll('{id}', '${detail.saleDetailId}')
          .replaceAll('{item}', detail.itemName),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<SalesDetailProvider>();

    final success = await provider.removeDetail(
      token: widget.token,
      detailId: detail.saleDetailId,
    );

    if (!mounted) return;

    if (success) {
      if (_editingDetailId == detail.saleDetailId) {
        _resetForm();
      }
      _showMessage(loc.getString('sales_detail_deleted') ??
          'Sales detail deleted successfully.');
    } else {
      _showMessage(provider.errorMessage ??
          (loc.getString('could_not_delete_sales_detail') ??
              'Could not delete sales detail.'));
    }
  }

  Future<void> _refreshDetails() async {
    await context.read<SalesDetailProvider>().loadDetails(
          token: widget.token,
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
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
          loc.getString('sales_details') ?? 'Sales Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: loc.getString('refresh_sales_details') ??
                'Refresh sales details',
            onPressed: _refreshDetails,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Consumer<SalesDetailProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _refreshDetails,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFormCard(theme, provider),
                const SizedBox(height: 22),
                Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: Text(
                        loc.getString('sales_detail_records') ??
                            'Sales Detail Records',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      (loc.getString('records_count') ?? '{count} records')
                          .replaceAll(
                              '{count}', '${provider.details.length}'),
                      style: TextStyle(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.isLoading && provider.details.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.errorMessage != null &&
                    provider.details.isEmpty)
                  _buildErrorCard(theme, provider)
                else if (provider.details.isEmpty)
                  _buildEmptyCard(theme)
                else
                  ...provider.details.map(
                    (detail) => _buildDetailCard(theme, detail),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme, SalesDetailProvider provider) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF102C4A),
                    size: 27,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _editingDetailId == null
                          ? (loc.getString('add_sales_detail') ??
                              'Add Sales Detail')
                          : (loc.getString('edit_sales_detail_num') ??
                                  'Edit Sales Detail #{id}')
                              .replaceAll(
                                  '{id}', '$_editingDetailId'),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_editingDetailId != null)
                    IconButton(
                      tooltip:
                          loc.getString('cancel_editing') ?? 'Cancel editing',
                      onPressed: _resetForm,
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.hintColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<int>(
                value: _selectedSaleId,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: _inputDecoration(
                    theme, loc.getString('select_sale') ?? 'Sale'),
                hint: Text(
                  loc.getString('select_sale') ?? 'Select sale',
                  style: TextStyle(color: theme.hintColor),
                ),
                items: widget.sales.map((sale) {
                  return DropdownMenuItem<int>(
                    value: sale.saleId,
                    child: Text(
                      (loc.getString('sale_num') ?? 'Sale #{id}')
                          .replaceAll('{id}', '${sale.saleId}'),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSaleId = value);
                },
                validator: (value) => value == null
                    ? (loc.getString('please_select_sale') ??
                        'Please select a sale.')
                    : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<int>(
                value: _selectedItemId,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: _inputDecoration(
                    theme, loc.getString('item') ?? 'Item'),
                hint: Text(
                  loc.getString('select_item') ?? 'Select item',
                  style: TextStyle(color: theme.hintColor),
                ),
                items: widget.items.map((item) {
                  return DropdownMenuItem<int>(
                    value: item.itemId,
                    child: Text(
                      item.itemName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedItemId = value);
                },
                validator: (value) => value == null
                    ? (loc.getString('please_select_item') ??
                        'Please select an item.')
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textDirection: Directionality.of(context),
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: _inputDecoration(
                    theme, loc.getString('quantity_short') ?? 'Quantity'),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final number = double.tryParse(value?.trim() ?? '');
                  if (number == null || !number.isFinite || number <= 0) {
                    return loc.getString('enter_quantity_greater_zero') ??
                        'Enter a quantity greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _unitPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textDirection: Directionality.of(context),
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: _inputDecoration(
                    theme, loc.getString('unit_price') ?? 'Unit Price'),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final number = double.tryParse(value?.trim() ?? '');
                  if (number == null || !number.isFinite || number < 0) {
                    return loc.getString('enter_valid_price_zero_greater') ??
                        'Enter a valid price (zero or greater).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: Text(
                        loc.getString('line_total') ?? 'Line Total',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF102C4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _lineTotal.toStringAsFixed(2),
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF102C4A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ✅ QIAMUDDIN PRIMARY BUTTON
              QiamuddinDesign.primaryButton(
                context: context,
                text: provider.isSaving
                    ? (loc.getString('saving') ?? 'Saving...')
                    : _editingDetailId == null
                        ? (loc.getString('create_sales_detail') ??
                            'Create Sales Detail')
                        : (loc.getString('update_sales_detail') ??
                            'Update Sales Detail'),
                icon: _editingDetailId == null
                    ? Icons.add_rounded
                    : Icons.save_rounded,
                isLoading: provider.isSaving,
                onPressed: provider.isSaving ? null : _saveDetail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.hintColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF102C4A),
          width: 1.5,
        ),
      ),
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
    );
  }

  Widget _buildDetailCard(ThemeData theme, SalesDetailModel detail) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: Directionality.of(context),
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF102C4A)
                        : const Color(0xFF102C4A).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF102C4A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.itemName,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (loc.getString('detail_num_sale_num') ??
                                'Detail #{detail} • Sale #{sale}')
                            .replaceAll(
                                '{detail}', '${detail.saleDetailId}')
                            .replaceAll('{sale}', '${detail.saleId}'),
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
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF1976D2),
                  ),
                ),
                IconButton(
                  tooltip: loc.getString('delete') ?? 'Delete',
                  onPressed: () => _deleteDetail(detail),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: theme.dividerColor),
            _detailRow(
              theme,
              loc.getString('quantity_short') ?? 'Quantity',
              _formatNumber(detail.quantity),
            ),
            const SizedBox(height: 8),
            _detailRow(
              theme,
              loc.getString('unit_price') ?? 'Unit Price',
              detail.unitPrice.toStringAsFixed(2),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _detailRow(
                theme,
                loc.getString('line_total') ?? 'Line Total',
                detail.lineTotal.toStringAsFixed(2),
                bold: true,
              ),
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
    return Row(
      textDirection: Directionality.of(context),
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.hintColor,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            fontSize: bold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 46,
              color: theme.hintColor,
            ),
            const SizedBox(height: 12),
            Text(
              loc.getString('no_sales_details_found') ??
                  'No sales details found.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              loc.getString('create_sales_detail_hint') ??
                  'Create a sales detail using the form above.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, SalesDetailProvider provider) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              provider.errorMessage ??
                  (loc.getString('unable_to_load_records') ??
                      'Unable to load records.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _refreshDetails,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.dividerColor),
                foregroundColor: theme.colorScheme.onSurface,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(loc.getString('try_again') ?? 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}