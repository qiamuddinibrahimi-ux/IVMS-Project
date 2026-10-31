import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purchase_model.dart';
import '../providers/purchase_provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/currency_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class PurchaseFormScreen extends StatefulWidget {
  final PurchaseModel? purchase;

  const PurchaseFormScreen({
    super.key,
    this.purchase,
  });

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  int? _selectedVendorId;
  int? _selectedCurrencyId;

  bool _isSaving = false;

  bool get _isEditing => widget.purchase != null;

  @override
  void initState() {
    super.initState();

    if (widget.purchase != null) {
      final purchase = widget.purchase!;

      _selectedVendorId = purchase.vendorId;
      _selectedCurrencyId = purchase.currencyId;
      _invoiceController.text = purchase.invoiceNo;
      _dateController.text = _formatDateForInput(purchase.purchaseDate);
    } else {
      final now = DateTime.now();
      _dateController.text = _formatDate(now);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadReferenceData();
    });
  }

  Future<void> _loadReferenceData() async {
    await Future.wait([
      context.read<VendorProvider>().loadVendors(),
      context.read<CurrencyProvider>().loadCurrencies(),
    ]);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDateForInput(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }
    return value;
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();

    if (_dateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dateController.text);
      } catch (_) {}
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _dateController.text = _formatDate(selectedDate);
    });
  }

  Future<void> _savePurchase() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    if (_selectedVendorId == null) {
      _showError(loc.getString('select_vendor_required') ??
          'Please select a vendor.');
      return;
    }

    if (_selectedCurrencyId == null) {
      _showError(loc.getString('select_currency_required') ??
          'Please select a currency.');
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      _showError(loc.getString('please_select_purchase_date') ??
          'Please select a purchase date.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<PurchaseProvider>();

    bool success;

    if (_isEditing) {
      success = await provider.updatePurchase(
        purchaseId: widget.purchase!.purchaseId,
        vendorId: _selectedVendorId!,
        currencyId: _selectedCurrencyId!,
        purchaseDate: _dateController.text.trim(),
        invoiceNo: _invoiceController.text.trim(),
      );
    } else {
      success = await provider.createPurchase(
        vendorId: _selectedVendorId!,
        currencyId: _selectedCurrencyId!,
        purchaseDate: _dateController.text.trim(),
        invoiceNo: _invoiceController.text.trim(),
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? (loc.getString('purchase_updated') ??
                    'Purchase updated successfully.')
                : (loc.getString('purchase_created') ??
                    'Purchase created successfully.'),
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      _showError(provider.errorMessage ??
          (loc.getString('something_wrong') ?? 'Something went wrong.'));
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final vendorProvider = context.watch<VendorProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          _isEditing
              ? (loc.getString('edit_purchase') ?? 'Edit Purchase')
              : (loc.getString('add_purchase') ?? 'Add Purchase'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // INVOICE NUMBER
            TextFormField(
              controller: _invoiceController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('invoice_number') ??
                    'Invoice Number',
                labelStyle: TextStyle(color: theme.hintColor),
                hintText: loc.getString('enter_invoice_number') ??
                    'Enter invoice number',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(
                  Icons.receipt_long,
                  color: theme.hintColor,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.getString('invoice_number_required') ??
                      'Invoice number is required.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // VENDOR
            DropdownButtonFormField<int>(
              value: _selectedVendorId,
              dropdownColor: theme.cardColor,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('vendor_required') ?? 'Vendor',
                labelStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(
                  Icons.business,
                  color: theme.hintColor,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: vendorProvider.vendors.map((vendor) {
                return DropdownMenuItem<int>(
                  value: vendor.vendorId,
                  child: Text(
                    vendor.vendorName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedVendorId = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return loc.getString('select_vendor_required') ??
                      'Please select a vendor.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // CURRENCY
            DropdownButtonFormField<int>(
              value: _selectedCurrencyId,
              dropdownColor: theme.cardColor,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText:
                    loc.getString('currency_required') ?? 'Currency',
                labelStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(
                  Icons.currency_exchange,
                  color: theme.hintColor,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: currencyProvider.currencies.map((currency) {
                return DropdownMenuItem<int>(
                  value: currency.currencyId,
                  child: Text(
                    '${currency.currencyName} (${currency.currencyCode})',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCurrencyId = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return loc.getString('select_currency_required') ??
                      'Please select a currency.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // PURCHASE DATE
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _isSaving ? null : _selectDate,
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText:
                    loc.getString('purchase_date') ?? 'Purchase Date',
                labelStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: theme.hintColor,
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.hintColor,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.getString('purchase_date_required') ??
                      'Purchase date is required.';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            // QIAMUDDIN SAVE BUTTON
            QiamuddinDesign.primaryButton(
              context: context,
              text: _isSaving
                  ? (loc.getString('saving') ?? 'Saving...')
                  : _isEditing
                      ? (loc.getString('update_purchase') ??
                          'Update Purchase')
                      : (loc.getString('create_purchase') ??
                          'Create Purchase'),
              icon: _isEditing ? Icons.save_rounded : Icons.add_shopping_cart,
              isLoading: _isSaving,
              onPressed: _savePurchase,
            ),
          ],
        ),
      ),
    );
  }
}