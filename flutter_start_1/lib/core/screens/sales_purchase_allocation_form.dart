import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sales_purchase_allocation_model.dart';
import '../providers/sales_purchase_allocation_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class SalesPurchaseAllocationFormScreen extends StatefulWidget {
  final SalesPurchaseAllocationModel? allocation;

  const SalesPurchaseAllocationFormScreen({
    super.key,
    this.allocation,
  });

  @override
  State<SalesPurchaseAllocationFormScreen> createState() =>
      _SalesPurchaseAllocationFormScreenState();
}

class _SalesPurchaseAllocationFormScreenState
    extends State<SalesPurchaseAllocationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController =
      TextEditingController();

  int? _saleDetailId;
  int? _purchaseDetailId;

  bool _initialized = false;
  bool _loadingError = false;

  bool get _isEditing => widget.allocation != null;

  @override
  void initState() {
    super.initState();

    final allocation = widget.allocation;

    if (allocation != null) {
      _saleDetailId = allocation.saleDetailId;
      _purchaseDetailId = allocation.purchaseDetailId;
      _quantityController.text =
          allocation.allocatedQuantity.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOptions();
    });
  }

  Future<void> _loadOptions() async {
    if (!mounted) return;

    setState(() {
      _loadingError = false;
    });

    try {
      final provider =
          context.read<SalesPurchaseAllocationProvider>();

      await provider.loadDetailOptions(forceRefresh: true);

      if (!mounted) return;

      setState(() {
        _initialized = true;
        _loadingError = provider.errorMessage != null;
      });

      if (provider.saleDetails.isEmpty ||
          provider.purchaseDetails.isEmpty) {
        debugPrint(
          'Allocation options: '
          'sales=${provider.saleDetails.length}, '
          'purchases=${provider.purchaseDetails.length}',
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _initialized = true;
        _loadingError = true;
      });

      debugPrint('Failed to load allocation options: $error');
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  SaleDetailOptionModel? get _selectedSaleDetail {
    final details =
        context.read<SalesPurchaseAllocationProvider>().saleDetails;

    for (final detail in details) {
      if (detail.saleDetailId == _saleDetailId) {
        return detail;
      }
    }

    return null;
  }

  PurchaseDetailOptionModel? get _selectedPurchaseDetail {
    final details =
        context.read<SalesPurchaseAllocationProvider>().purchaseDetails;

    for (final detail in details) {
      if (detail.purchaseDetailId == _purchaseDetailId) {
        return detail;
      }
    }

    return null;
  }

  List<SaleDetailOptionModel> _availableSaleDetails(
    SalesPurchaseAllocationProvider provider,
  ) {
    final list = [...provider.saleDetails];

    list.sort((a, b) {
      final aHas = a.remainingQuantity > 0 ? 0 : 1;
      final bHas = b.remainingQuantity > 0 ? 0 : 1;
      return aHas.compareTo(bHas);
    });

    return list;
  }

  List<PurchaseDetailOptionModel> _matchingPurchaseDetails(
    SalesPurchaseAllocationProvider provider,
  ) {
    final saleDetail = _selectedSaleDetail;

    if (saleDetail == null) return [];

    final sameItemPurchases = provider.purchaseDetails
        .where((p) => p.itemId == saleDetail.itemId)
        .toList();

    sameItemPurchases.sort((a, b) {
      int weight(PurchaseDetailOptionModel p) {
        if (p.purchaseDetailId == _purchaseDetailId) return 0;
        if (p.remainingQuantity > 0) return 0;
        return 1;
      }

      return weight(a).compareTo(weight(b));
    });

    return sameItemPurchases;
  }

  Future<void> _save() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    final provider =
        context.read<SalesPurchaseAllocationProvider>();

    final saleDetail = _selectedSaleDetail;
    final purchaseDetail = _selectedPurchaseDetail;

    if (saleDetail == null) {
      _showMessage(
          loc.getString('please_select_sales_detail') ??
              'Please select a sales detail.');
      return;
    }

    if (purchaseDetail == null) {
      _showMessage(
          loc.getString('please_select_matching_purchase_required') ??
              'Please select a matching purchase detail.');
      return;
    }

    if (saleDetail.itemId != purchaseDetail.itemId) {
      _showMessage(
        loc.getString('sales_and_purchase_must_match_same_item') ??
            'The sales detail and purchase detail must refer to the same item.',
      );
      return;
    }

    final quantity =
        double.tryParse(_quantityController.text.trim());

    if (quantity == null || !quantity.isFinite || quantity <= 0) {
      _showMessage(
          loc.getString('enter_valid_quantity_greater_zero') ??
              'Enter a valid quantity greater than zero.');
      return;
    }

    if (!_isEditing) {
      final maximum = saleDetail.remainingQuantity <
              purchaseDetail.remainingQuantity
          ? saleDetail.remainingQuantity
          : purchaseDetail.remainingQuantity;

      if (quantity > maximum) {
        _showMessage(
          (loc.getString('quantity_cannot_exceed_available') ??
                  'Quantity cannot exceed the available amount of {value}.')
              .replaceAll('{value}', _quantity(maximum)),
        );
        return;
      }
    }

    final bool success;

    try {
      if (_isEditing) {
        success = await provider.updateAllocation(
          allocationId: widget.allocation!.allocationId,
          saleDetailId: saleDetail.saleDetailId,
          purchaseDetailId: purchaseDetail.purchaseDetailId,
          itemId: saleDetail.itemId,
          allocatedQuantity: quantity,
        );
      } else {
        success = await provider.createAllocation(
          saleDetailId: saleDetail.saleDetailId,
          purchaseDetailId: purchaseDetail.purchaseDetailId,
          itemId: saleDetail.itemId,
          allocatedQuantity: quantity,
        );
      }
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        (loc.getString('failed_to_save_allocation_error') ??
                'Failed to save allocation: {error}')
            .replaceAll('{error}', '$error'),
      );
      return;
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? (loc.getString('allocation_updated') ??
                    'Allocation updated successfully.')
                : (loc.getString('allocation_created') ??
                    'Allocation created successfully.'),
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      _showMessage(
        provider.errorMessage ??
            (loc.getString('failed_to_save_allocation') ??
                'Failed to save allocation.'),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _quantity(double value) {
    return value.toStringAsFixed(4)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider =
        context.watch<SalesPurchaseAllocationProvider>();

    final saleDetails = _availableSaleDetails(provider);
    final purchaseDetails = _matchingPurchaseDetails(provider);

    final saleValue = saleDetails.any(
      (detail) => detail.saleDetailId == _saleDetailId,
    )
        ? _saleDetailId
        : null;

    final purchaseValue = purchaseDetails.any(
      (detail) => detail.purchaseDetailId == _purchaseDetailId,
    )
        ? _purchaseDetailId
        : null;

    final isLoading =
        !_initialized || provider.isLoadingOptions;

    final hasSelectablePurchase = purchaseDetails.any(
      (p) => p.remainingQuantity > 0,
    );

    final selectedSale = _selectedSaleDetail;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          _isEditing
              ? (loc.getString('edit_allocation') ?? 'Edit Allocation')
              : (loc.getString('create_allocation') ??
                  'Create Allocation'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOptions,
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_loadingError ||
                        provider.errorMessage != null)
                      Card(
                        color: theme.brightness == Brightness.dark
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.errorMessage ??
                                    (loc.getString(
                                            'could_not_load_allocation_options') ??
                                        'Could not load allocation options.'),
                                style: TextStyle(
                                  color: theme.brightness ==
                                          Brightness.dark
                                      ? Colors.red.shade300
                                      : Colors.red.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _loadOptions,
                                icon: const Icon(Icons.refresh),
                                label: Text(
                                    loc.getString('retry_loading') ??
                                        'Retry loading'),
                              ),
                            ],
                          ),
                        ),
                      ),

                    DropdownButtonFormField<int>(
                      value: saleValue,
                      isExpanded: true,
                      menuMaxHeight: 350,
                      dropdownColor: theme.cardColor,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: loc.getString('sales_detail_required') ??
                            'Sales Detail',
                        labelStyle: TextStyle(
                          color: theme.hintColor,
                        ),
                        helperText: saleDetails.isEmpty
                            ? (loc.getString('no_sales_details_exist') ??
                                'No sales details exist yet. Create a sale first.')
                            : (loc.getString('select_sales_invoice_item') ??
                                'Select a sales invoice and item.'),
                        helperStyle: TextStyle(
                          color: theme.hintColor,
                        ),
                        prefixIcon: Icon(
                          Icons.point_of_sale,
                          color: theme.hintColor,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: saleDetails.map((detail) {
                        final fullyAllocated =
                            detail.remainingQuantity <= 0;

                        return DropdownMenuItem<int>(
                          value: detail.saleDetailId,
                          enabled: !fullyAllocated ||
                              detail.saleDetailId == _saleDetailId,
                          child: Row(
                            textDirection: Directionality.of(context),
                            children: [
                              Expanded(
                                child: Text(
                                  '${detail.invoiceNo} • '
                                  '${detail.itemName} • '
                                  '${loc.getString('remaining_quantity') ?? 'Remaining'}: '
                                  '${_quantity(detail.remainingQuantity)}',
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme
                                        .colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (fullyAllocated)
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 6),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.brightness ==
                                            Brightness.dark
                                        ? Colors.red
                                            .withValues(alpha: 0.25)
                                        : Colors.red.shade100,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    loc.getString('fully_allocated') ??
                                        'Fully allocated',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.brightness ==
                                              Brightness.dark
                                          ? Colors.red.shade200
                                          : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: provider.isSaving ||
                              saleDetails.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _saleDetailId = value;
                                _purchaseDetailId = null;
                              });
                            },
                      validator: (value) => value == null
                          ? (loc.getString(
                                  'please_select_sales_detail') ??
                              'Please select a sales detail.')
                          : null,
                    ),

                    const SizedBox(height: 12),

                    if (selectedSale != null)
                      _detailSummary(
                        theme: theme,
                        title:
                            loc.getString('selected_sale') ?? 'Selected Sale',
                        invoice: selectedSale.invoiceNo,
                        item: selectedSale.itemName,
                        total: selectedSale.saleQuantity,
                        allocated: selectedSale.allocatedQuantity,
                        remaining: selectedSale.remainingQuantity,
                      ),

                    if (selectedSale != null &&
                        purchaseDetails.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Card(
                          color: theme.brightness == Brightness.dark
                              ? Colors.orange.withValues(alpha: 0.2)
                              : Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              textDirection: Directionality.of(context),
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.brightness ==
                                          Brightness.dark
                                      ? Colors.orange.shade300
                                      : Colors.orange.shade800,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    (loc.getString(
                                                'no_purchase_exists_for_item') ??
                                            'No purchase exists for item "{item}". '
                                                'Create a purchase for this item before allocating.')
                                        .replaceAll('{item}',
                                            selectedSale.itemName),
                                    style: TextStyle(
                                      color: theme.brightness ==
                                              Brightness.dark
                                          ? Colors.orange.shade200
                                          : Colors.orange.shade900,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (selectedSale != null &&
                        purchaseDetails.isNotEmpty &&
                        !hasSelectablePurchase)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Card(
                          color: theme.brightness == Brightness.dark
                              ? Colors.orange.withValues(alpha: 0.2)
                              : Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              textDirection: Directionality.of(context),
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.brightness ==
                                          Brightness.dark
                                      ? Colors.orange.shade300
                                      : Colors.orange.shade800,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    (loc.getString(
                                                'all_purchases_fully_allocated') ??
                                            'All purchases of "{item}" are already fully allocated. '
                                                'Buy more or free up an existing allocation.')
                                        .replaceAll('{item}',
                                            selectedSale.itemName),
                                    style: TextStyle(
                                      color: theme.brightness ==
                                              Brightness.dark
                                          ? Colors.orange.shade200
                                          : Colors.orange.shade900,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<int>(
                      value: purchaseValue,
                      isExpanded: true,
                      menuMaxHeight: 350,
                      dropdownColor: theme.cardColor,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            loc.getString('matching_purchase_detail') ??
                                'Matching Purchase Detail',
                        labelStyle: TextStyle(
                          color: theme.hintColor,
                        ),
                        helperText: selectedSale == null
                            ? (loc.getString('select_sales_detail_first') ??
                                'Select a sales detail first.')
                            : purchaseDetails.isEmpty
                                ? (loc.getString(
                                        'no_purchases_exist_for_item') ??
                                    'No purchases exist for this item.')
                                : !hasSelectablePurchase
                                    ? (loc.getString(
                                            'all_matching_purchases_allocated') ??
                                        'All matching purchases are fully allocated.')
                                    : (loc.getString(
                                            'only_purchases_for_selected_item') ??
                                        'Only purchases for the selected item are shown.'),
                        helperStyle: TextStyle(
                          color: theme.hintColor,
                        ),
                        prefixIcon: Icon(
                          Icons.inventory_2,
                          color: theme.hintColor,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: purchaseDetails.map((detail) {
                        final fullyAllocated =
                            detail.remainingQuantity <= 0;
                        final isCurrent =
                            detail.purchaseDetailId ==
                                _purchaseDetailId;

                        return DropdownMenuItem<int>(
                          value: detail.purchaseDetailId,
                          enabled: !fullyAllocated || isCurrent,
                          child: Row(
                            textDirection: Directionality.of(context),
                            children: [
                              Expanded(
                                child: Text(
                                  '${detail.invoiceNo} • '
                                  '${detail.itemName} • '
                                  '${loc.getString('remaining_quantity') ?? 'Remaining'}: '
                                  '${_quantity(detail.remainingQuantity)}',
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme
                                        .colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (fullyAllocated)
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 6),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.brightness ==
                                            Brightness.dark
                                        ? Colors.red
                                            .withValues(alpha: 0.25)
                                        : Colors.red.shade100,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    loc.getString('fully_allocated') ??
                                        'Fully allocated',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.brightness ==
                                              Brightness.dark
                                          ? Colors.red.shade200
                                          : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: provider.isSaving ||
                              selectedSale == null ||
                              !hasSelectablePurchase
                          ? null
                          : (value) {
                              setState(() {
                                _purchaseDetailId = value;
                              });
                            },
                      validator: (value) => value == null
                          ? (loc.getString(
                                  'please_select_matching_purchase') ??
                              'Please select a matching purchase detail.')
                          : null,
                    ),

                    const SizedBox(height: 12),

                    if (_selectedPurchaseDetail != null)
                      _detailSummary(
                        theme: theme,
                        title: loc.getString('selected_purchase') ??
                            'Selected Purchase',
                        invoice:
                            _selectedPurchaseDetail!.invoiceNo,
                        item: _selectedPurchaseDetail!.itemName,
                        total: _selectedPurchaseDetail!
                            .purchaseQuantity,
                        allocated: _selectedPurchaseDetail!
                            .allocatedQuantity,
                        remaining: _selectedPurchaseDetail!
                            .remainingQuantity,
                      ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _quantityController,
                      enabled: !provider.isSaving,
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
                            loc.getString('allocated_quantity') ??
                                'Allocated Quantity',
                        labelStyle: TextStyle(
                          color: theme.hintColor,
                        ),
                        hintText:
                            loc.getString('enter_quantity') ??
                                'Enter quantity',
                        hintStyle: TextStyle(
                          color: theme.hintColor,
                        ),
                        prefixIcon: Icon(
                          Icons.scale,
                          color: theme.hintColor,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final quantity =
                            double.tryParse(value?.trim() ?? '');

                        if (quantity == null ||
                            !quantity.isFinite ||
                            quantity <= 0) {
                          return loc.getString(
                                  'enter_quantity_greater_zero') ??
                              'Enter a quantity greater than zero.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    QiamuddinDesign.primaryButton(
                      context: context,
                      text: provider.isSaving
                          ? (loc.getString('saving') ?? 'Saving...')
                          : _isEditing
                              ? (loc.getString('update_allocation') ??
                                  'Update Allocation')
                              : (loc.getString('create_allocation') ??
                                  'Create Allocation'),
                      icon: _isEditing
                          ? Icons.save_rounded
                          : Icons.add_rounded,
                      isLoading: provider.isSaving,
                      onPressed: provider.isSaving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _detailSummary({
    required ThemeData theme,
    required String title,
    required String invoice,
    required String item,
    required double total,
    required double allocated,
    required double remaining,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: isDark
          ? const Color(0xFF2C2C2C)
          : Colors.grey.shade100,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: Directionality.of(context),
              children: [
                Icon(
                  title.contains('Sale') ||
                          title.contains('Sale'.toLowerCase()) ||
                          title.contains('پلور') ||
                          title.contains('فروش')
                      ? Icons.point_of_sale
                      : Icons.inventory_2,
                  size: 16,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Divider(
              height: 18,
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
            _infoRow(theme, loc.getString('invoice_label') ?? 'Invoice',
                invoice),
            _infoRow(
                theme, loc.getString('item_label') ?? 'Item', item),
            _infoRow(
              theme,
              loc.getString('original_quantity') ??
                  'Original quantity',
              _quantity(total),
            ),
            _infoRow(
              theme,
              loc.getString('already_allocated') ?? 'Already allocated',
              _quantity(allocated),
            ),
            _infoRow(
              theme,
              loc.getString('remaining_quantity') ?? 'Remaining quantity',
              _quantity(remaining),
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    ThemeData theme,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.5,
                color: theme.hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}