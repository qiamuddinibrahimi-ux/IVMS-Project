import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/stock_movement_model.dart';
import '../models/item_model.dart';
import '../models/purchase_model.dart';
import '../models/sale_model.dart';
import '../providers/stock_movement_provider.dart';
import '../constants/api_constants.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class StockMovementFormScreen extends StatefulWidget {
  final List<ItemModel> items;
  final List<PurchaseModel> purchases;
  final List<SaleModel> sales;
  final String? token;
  final StockMovementModel? movement;

  const StockMovementFormScreen({
    super.key,
    required this.items,
    required this.purchases,
    required this.sales,
    this.token,
    this.movement,
  });

  @override
  State<StockMovementFormScreen> createState() =>
      _StockMovementFormScreenState();
}

class _StockMovementFormScreenState
    extends State<StockMovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  int? _itemId;
  int? _sourceId;
  String _movementType = 'IN';
  String _sourceType = 'ADJUSTMENT';

  bool get _isEditing => widget.movement != null;

  @override
  void initState() {
    super.initState();

    final movement = widget.movement;

    if (movement != null) {
      _itemId = movement.itemId;
      _sourceId = movement.sourceId;
      _movementType = movement.movementType;
      _sourceType = movement.sourceType;
      _quantityController.text = movement.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<int>> _sourceItems(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (_sourceType == 'PURCHASE') {
      return widget.purchases.map((purchase) {
        return DropdownMenuItem<int>(
          value: purchase.purchaseId,
          child: Text(
            '${purchase.invoiceNo.isEmpty ? (loc.getString('purchase_short') ?? 'Purchase') : purchase.invoiceNo}'
            ' • ${purchase.vendorName}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList();
    }

    if (_sourceType == 'SALE') {
      return widget.sales.map((sale) {
        return DropdownMenuItem<int>(
          value: sale.saleId,
          child: Text(
            '${sale.invoiceNo.isEmpty ? (loc.getString('sale_short') ?? 'Sale') : sale.invoiceNo}'
            ' • ${sale.customerName}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList();
    }

    return [];
  }

  Future<void> _submit() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text.trim());

    if (quantity == null || !quantity.isFinite || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('enter_quantity_greater_zero') ??
                'Enter a quantity greater than zero.',
          ),
        ),
      );
      return;
    }

    final provider = context.read<StockMovementProvider>();

    final bool success;

    if (_isEditing) {
      success = await provider.updateMovement(
        movementId: widget.movement!.movementId,
        itemId: _itemId!,
        movementType: _movementType,
        quantity: quantity,
        sourceType: _sourceType,
        sourceId: _sourceId,
        token: widget.token,
      );
    } else {
      success = await provider.createMovement(
        itemId: _itemId!,
        movementType: _movementType,
        quantity: quantity,
        sourceType: _sourceType,
        sourceId: _sourceId,
        token: widget.token,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? (loc.getString('stock_movement_updated') ??
                    'Stock movement updated successfully.')
                : (loc.getString('stock_movement_created') ??
                    'Stock movement created successfully.'),
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ??
              (loc.getString('operation_failed') ?? 'Operation failed.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<StockMovementProvider>();
    final sourceItems = _sourceItems(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          _isEditing
              ? (loc.getString('edit_stock_movement') ??
                  'Edit Stock Movement')
              : (loc.getString('create_stock_movement') ??
                  'Create Stock Movement'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ITEM
            DropdownButtonFormField<int>(
              value: _itemId,
              isExpanded: true,
              dropdownColor: theme.cardColor,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('item') ?? 'Item',
                labelStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: widget.items.map((item) {
                return DropdownMenuItem<int>(
                  value: item.itemId,
                  child: Text(
                    '${item.itemName} (${item.unitName})',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _itemId = value);
              },
              validator: (value) {
                if (value == null) {
                  return loc.getString('please_select_item') ??
                      'Please select an item.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // MOVEMENT TYPE
            DropdownButtonFormField<String>(
              value: _movementType,
              dropdownColor: theme.cardColor,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText:
                    loc.getString('movement_type') ?? 'Movement Type',
                labelStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'IN',
                  child: Text(
                    loc.getString('movement_in_label') ??
                        'IN — Stock received',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: 'OUT',
                  child: Text(
                    loc.getString('movement_out_label') ??
                        'OUT — Stock issued',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _movementType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // QUANTITY
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('quantity_short') ?? 'Quantity',
                labelStyle: TextStyle(color: theme.hintColor),
                hintText:
                    loc.getString('enter_quantity') ?? 'Enter quantity',
                hintStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                final quantity = double.tryParse(value?.trim() ?? '');
                if (quantity == null || !quantity.isFinite || quantity <= 0) {
                  return loc.getString('enter_quantity_greater_zero') ??
                      'Enter a quantity greater than zero.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // SOURCE TYPE
            DropdownButtonFormField<String>(
              value: _sourceType,
              isExpanded: true,
              dropdownColor: theme.cardColor,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText:
                    loc.getString('source_type') ?? 'Source Type',
                labelStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'PURCHASE',
                  child: Text(
                    loc.getString('source_purchase') ?? 'Purchase',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: 'SALE',
                  child: Text(
                    loc.getString('source_sale') ?? 'Sale',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: 'OPENING',
                  child: Text(
                    loc.getString('source_opening') ?? 'Opening Stock',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: 'ADJUSTMENT',
                  child: Text(
                    loc.getString('source_adjustment') ?? 'Adjustment',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: 'RETURN',
                  child: Text(
                    loc.getString('source_return') ?? 'Return',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _sourceType = value;
                  _sourceId = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // SOURCE RECORD (PURCHASE / SALE)
            if (_sourceType == 'PURCHASE' || _sourceType == 'SALE') ...[
              DropdownButtonFormField<int>(
                value: sourceItems.any((item) => item.value == _sourceId)
                    ? _sourceId
                    : null,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: _sourceType == 'PURCHASE'
                      ? (loc.getString('select_purchase') ??
                          'Select Purchase')
                      : (loc.getString('select_sale_record') ??
                          'Select Sale'),
                  labelStyle: TextStyle(color: theme.hintColor),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: sourceItems,
                onChanged: (value) {
                  setState(() => _sourceId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return loc.getString('select_linked_record') ??
                        'Select the linked record.';
                  }
                  return null;
                },
              ),
              if (sourceItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    loc.getString('no_source_records_available') ??
                        'No source records are available. '
                            'Load the relevant purchase or sale records first.',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // ERROR
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // QIAMUDDIN SUBMIT BUTTON
            QiamuddinDesign.primaryButton(
              context: context,
              text: provider.isSaving
                  ? (loc.getString('saving') ?? 'Saving...')
                  : _isEditing
                      ? (loc.getString('update_movement') ??
                          'Update Movement')
                      : (loc.getString('create_movement') ??
                          'Create Movement'),
              icon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
              isLoading: provider.isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}