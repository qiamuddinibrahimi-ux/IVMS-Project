import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purchase_payment_model.dart';
import '../providers/purchase_payment_provider.dart';
import '../providers/purchase_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class PurchasePaymentFormScreen extends StatefulWidget {
  final PurchasePaymentModel? payment;

  const PurchasePaymentFormScreen({
    super.key,
    this.payment,
  });

  @override
  State<PurchasePaymentFormScreen> createState() =>
      _PurchasePaymentFormScreenState();
}

class _PurchasePaymentFormScreenState
    extends State<PurchasePaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();

  int? _selectedPurchaseId;

  DateTime _paymentDate = DateTime.now();

  bool _isSubmitting = false;

  bool get isEditing => widget.payment != null;

  @override
  void initState() {
    super.initState();

    if (widget.payment != null) {
      _selectedPurchaseId = widget.payment!.purchaseId;
      _amountController.text = widget.payment!.amount.toStringAsFixed(2);

      final date = DateTime.tryParse(widget.payment!.paymentDate);
      if (date != null) {
        _paymentDate = date;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PurchaseProvider>().loadPurchases();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    setState(() {
      _paymentDate = selected;
    });
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _submit() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    if (_selectedPurchaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('please_select_purchase') ??
                'Please select a purchase.',
          ),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('please_enter_valid_amount') ??
                'Please enter a valid amount.',
          ),
        ),
      );
      return;
    }

    final purchaseProvider = context.read<PurchaseProvider>();
    final selectedPurchase = _findSelectedPurchase(purchaseProvider);

    if (selectedPurchase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('selected_purchase_not_found') ??
                'Selected purchase was not found.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final paymentProvider = context.read<PurchasePaymentProvider>();

    bool success;

    if (isEditing) {
      success = await paymentProvider.updatePurchasePayment(
        paymentId: widget.payment!.paymentId,
        purchaseId: selectedPurchase.purchaseId,
        vendorId: selectedPurchase.vendorId,
        currencyId: selectedPurchase.currencyId,
        amount: amount,
        paymentDate: _formatDate(_paymentDate),
      );
    } else {
      success = await paymentProvider.createPurchasePayment(
        purchaseId: selectedPurchase.purchaseId,
        vendorId: selectedPurchase.vendorId,
        currencyId: selectedPurchase.currencyId,
        amount: amount,
        paymentDate: _formatDate(_paymentDate),
      );
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentProvider.errorMessage ??
              (loc.getString('operation_failed') ?? 'Operation failed.')),
        ),
      );
    }
  }

  dynamic _findSelectedPurchase(PurchaseProvider provider) {
    for (final purchase in provider.purchases) {
      if (purchase.purchaseId == _selectedPurchaseId) {
        return purchase;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final purchaseProvider = context.watch<PurchaseProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          isEditing
              ? (loc.getString('edit_purchase_payment') ??
                  'Edit Purchase Payment')
              : (loc.getString('create_purchase_payment') ??
                  'Create Purchase Payment'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // PURCHASE
            DropdownButtonFormField<int>(
              value: _selectedPurchaseId,
              dropdownColor: theme.cardColor,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText:
                    loc.getString('purchase_label') ?? 'Purchase',
                labelStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.receipt_long, color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: purchaseProvider.purchases.map((purchase) {
                return DropdownMenuItem<int>(
                  value: purchase.purchaseId,
                  child: Text(
                    purchase.invoiceNo.toString().isEmpty
                        ? (loc.getString('purchase_num') ?? 'Purchase #{id}')
                            .replaceAll('{id}', '${purchase.purchaseId}')
                        : purchase.invoiceNo.toString(),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _selectedPurchaseId = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return loc.getString('please_select_purchase') ??
                      'Please select a purchase.';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            if (_selectedPurchaseId != null)
              _buildPurchaseInformation(theme, purchaseProvider),

            const SizedBox(height: 18),

            // AMOUNT
            TextFormField(
              controller: _amountController,
              enabled: !_isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText:
                    loc.getString('payment_amount') ?? 'Payment Amount',
                labelStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.money, color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.getString('payment_amount_required') ??
                      'Payment amount is required.';
                }

                final amount = double.tryParse(value.trim());

                if (amount == null || amount <= 0) {
                  return loc.getString('please_enter_valid_amount') ??
                      'Enter a valid amount.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // DATE
            InkWell(
              onTap: _isSubmitting ? null : _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: loc.getString('payment_date_label') ??
                      'Payment Date',
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
                child: Text(
                  _formatDate(_paymentDate),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // QIAMUDDIN SAVE BUTTON
            QiamuddinDesign.primaryButton(
              context: context,
              text: _isSubmitting
                  ? (loc.getString('saving') ?? 'Saving...')
                  : isEditing
                      ? (loc.getString('update_payment') ??
                          'Update Payment')
                      : (loc.getString('save_payment') ?? 'Save Payment'),
              icon: isEditing ? Icons.save_rounded : Icons.add_card_rounded,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseInformation(
    ThemeData theme,
    PurchaseProvider provider,
  ) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final purchase = _findSelectedPurchase(provider);

    if (purchase == null) {
      return const SizedBox();
    }

    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.getString('purchase_information') ??
                  'Purchase Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Divider(color: theme.dividerColor),
            _informationRow(
              theme,
              loc.getString('vendor') ?? 'Vendor',
              purchase.vendorName.toString(),
            ),
            _informationRow(
              theme,
              loc.getString('currency') ?? 'Currency',
              '${purchase.currencyName} (${purchase.currencyCode})',
            ),
          ],
        ),
      ),
    );
  }

  Widget _informationRow(
    ThemeData theme,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
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
}