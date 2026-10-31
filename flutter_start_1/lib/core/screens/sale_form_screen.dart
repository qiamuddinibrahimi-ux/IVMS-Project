import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sale_model.dart';
import '../providers/customer_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/sale_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class SaleFormScreen extends StatefulWidget {
  final SaleModel? sale;

  const SaleFormScreen({
    super.key,
    this.sale,
  });

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  int? _selectedCustomerId;
  int? _selectedCurrencyId;

  bool _isSaving = false;

  bool get _isEditing => widget.sale != null;

  @override
  void initState() {
    super.initState();

    if (widget.sale != null) {
      _invoiceController.text = widget.sale!.invoiceNo;
      _dateController.text = widget.sale!.saleDate;
      _selectedCustomerId = widget.sale!.customerId;
      _selectedCurrencyId = widget.sale!.currencyId;
    } else {
      _dateController.text = _formatDate(DateTime.now());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadReferenceData();
    });
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final customerProvider = context.read<CustomerProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    await Future.wait([
      customerProvider.loadCustomers(),
      currencyProvider.loadCurrencies(),
    ]);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();

    if (_dateController.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_dateController.text);
      if (parsed != null) {
        initialDate = parsed;
      }
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _dateController.text = _formatDate(selected);
      });
    }
  }

  Future<void> _saveSale() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      _showMessage(
          loc.getString('please_select_customer') ?? 'Please select a customer.');
      return;
    }

    if (_selectedCurrencyId == null) {
      _showMessage(
          loc.getString('please_select_currency') ?? 'Please select a currency.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<SaleProvider>();

    bool success;

    if (_isEditing) {
      success = await provider.updateSale(
        saleId: widget.sale!.saleId,
        customerId: _selectedCustomerId!,
        currencyId: _selectedCurrencyId!,
        saleDate: _dateController.text.trim(),
        invoiceNo: _invoiceController.text.trim(),
      );
    } else {
      success = await provider.createSale(
        customerId: _selectedCustomerId!,
        currencyId: _selectedCurrencyId!,
        saleDate: _dateController.text.trim(),
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
                ? (loc.getString('sale_updated') ??
                    'Sale updated successfully.')
                : (loc.getString('sale_created') ??
                    'Sale created successfully.'),
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      _showMessage(provider.errorMessage ??
          (loc.getString('failed_to_save_sale') ?? 'Failed to save sale.'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final customerProvider = context.watch<CustomerProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          _isEditing
              ? (loc.getString('edit_sale') ?? 'Edit Sale')
              : (loc.getString('create_sale') ?? 'Create Sale'),
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
                prefixIcon: Icon(Icons.receipt_long, color: theme.hintColor),
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

            // CUSTOMER
            DropdownButtonFormField<int>(
              value: _selectedCustomerId,
              dropdownColor: theme.cardColor,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('customer') ?? 'Customer',
                labelStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.person, color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: customerProvider.customers.map((customer) {
                return DropdownMenuItem<int>(
                  value: customer.customerId,
                  child: Text(
                    customer.customerName,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCustomerId = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return loc.getString('please_select_customer') ??
                      'Please select a customer.';
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
                labelText: loc.getString('currency') ?? 'Currency',
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
                  return loc.getString('please_select_currency') ??
                      'Please select a currency.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // SALE DATE
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _isSaving ? null : _selectDate,
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('sale_date') ?? 'Sale Date',
                labelStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(
                  Icons.calendar_today,
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
                  return loc.getString('sale_date_required') ??
                      'Sale date is required.';
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
                      ? (loc.getString('update_sale') ?? 'Update Sale')
                      : (loc.getString('create_sale') ?? 'Create Sale'),
              icon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
              isLoading: _isSaving,
              onPressed: _saveSale,
            ),
          ],
        ),
      ),
    );
  }
}