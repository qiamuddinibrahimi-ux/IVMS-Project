import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer_payment_model.dart';
import '../providers/customer_payment_provider.dart';
import '../providers/sale_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class CustomerPaymentFormScreen extends StatefulWidget {
  final CustomerPaymentModel? payment;

  const CustomerPaymentFormScreen({
    super.key,
    this.payment,
  });

  @override
  State<CustomerPaymentFormScreen> createState() =>
      _CustomerPaymentFormScreenState();
}

class _CustomerPaymentFormScreenState
    extends State<CustomerPaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _paymentDateController;

  int? _selectedSaleId;

  bool get isEditing => widget.payment != null;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.payment != null
          ? widget.payment!.amount.toString()
          : "",
    );

    _paymentDateController = TextEditingController(
      text: widget.payment != null
          ? widget.payment!.paymentDate
          : _todayDate(),
    );

    if (widget.payment != null) {
      _selectedSaleId = widget.payment!.saleId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SaleProvider>().loadSales();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentDateController.dispose();
    super.dispose();
  }

  String _todayDate() {
    final now = DateTime.now();
    return "${now.year}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    try {
      if (_paymentDateController.text.isNotEmpty) {
        initialDate = DateTime.parse(_paymentDateController.text);
      }
    } catch (_) {}

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    _paymentDateController.text = "${selectedDate.year}-"
        "${selectedDate.month.toString().padLeft(2, '0')}-"
        "${selectedDate.day.toString().padLeft(2, '0')}";
    setState(() {});
  }

  String? _validateAmount(String? value) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (value == null || value.trim().isEmpty) {
      return loc.getString('payment_amount_required') ??
          "Payment amount is required.";
    }

    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return loc.getString('amount_must_be_positive') ??
          "Amount must be greater than zero.";
    }

    return null;
  }

  Future<void> _savePayment() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSaleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                loc.getString('please_select_sale') ??
                    "Please select a sale.")),
      );
      return;
    }

    final saleProvider = context.read<SaleProvider>();
    final saleIndex = saleProvider.sales
        .indexWhere((sale) => sale.saleId == _selectedSaleId);

    if (saleIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(loc.getString('selected_sale_not_found') ??
                "Selected sale could not be found.")),
      );
      return;
    }

    final sale = saleProvider.sales[saleIndex];
    final amount = double.parse(_amountController.text.trim());
    final paymentDate = _paymentDateController.text.trim();
    final provider = context.read<CustomerPaymentProvider>();

    bool success;
    if (isEditing) {
      success = await provider.updateCustomerPayment(
        paymentId: widget.payment!.customerPaymentId,
        customerId: sale.customerId,
        saleId: sale.saleId,
        currencyId: sale.currencyId,
        amount: amount,
        paymentDate: paymentDate,
      );
    } else {
      success = await provider.createCustomerPayment(
        customerId: sale.customerId,
        saleId: sale.saleId,
        currencyId: sale.currencyId,
        amount: amount,
        paymentDate: paymentDate,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? loc.getString('customer_payment_updated') ??
                  "Customer payment updated successfully."
              : loc.getString('customer_payment_created') ??
                  "Customer payment created successfully."),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ??
              loc.getString('something_wrong') ??
              "Something went wrong."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final paymentProvider = context.watch<CustomerPaymentProvider>();
    final saleProvider = context.watch<SaleProvider>();
    final isLoading = paymentProvider.isLoading || saleProvider.isLoading;

    dynamic selectedSale;
    if (_selectedSaleId != null) {
      try {
        selectedSale = saleProvider.sales
            .firstWhere((sale) => sale.saleId == _selectedSaleId);
      } catch (_) {
        selectedSale = null;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          isEditing
              ? loc.getString('edit_customer_payment') ??
                  "Edit Customer Payment"
              : loc.getString('add_customer_payment') ??
                  "Add Customer Payment",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // PAYMENT AVATAR (Modern Gradient)
                // ==================================================
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: theme.brightness == Brightness.dark
                            ? [const Color(0xFF1B4A63), const Color(0xFF0F2B3B)]
                            : [const Color(0xFF2E6F95), const Color(0xFF4A9BC9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E6F95)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // SALE / INVOICE DROPDOWN
                // ==================================================
                DropdownButtonFormField<int>(
                  value: _selectedSaleId,
                  isExpanded: true,
                  style:
                      TextStyle(color: theme.colorScheme.onSurface),
                  dropdownColor: theme.cardColor,
                  decoration: InputDecoration(
                    labelText: loc.getString('sale_invoice') ??
                        "Sale / Invoice",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText:
                        loc.getString('select_sale') ?? "Select sale",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(
                      Icons.receipt_long_outlined,
                      color: theme.hintColor,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2E6F95), width: 1.5),
                    ),
                  ),
                  items: saleProvider.sales.map((sale) {
                    return DropdownMenuItem<int>(
                      value: sale.saleId,
                      child: Text(
                        "${sale.invoiceNo} - ${sale.customerName}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: isEditing
                      ? null
                      : (value) {
                          setState(() {
                            _selectedSaleId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return loc.getString('please_select_sale') ??
                          "Please select a sale.";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // CUSTOMER (read-only)
                // ==================================================
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedSale?.customerName ?? "",
                  ),
                  textDirection: Directionality.of(context),
                  style:
                      TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText:
                        loc.getString('customer') ?? "Customer",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('customer_auto_selected') ??
                        "Customer will be selected automatically",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: theme.hintColor,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2E6F95), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // CURRENCY (read-only)
                // ==================================================
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedSale == null
                        ? ""
                        : "${selectedSale.currencyName} (${selectedSale.currencyCode})",
                  ),
                  textDirection: Directionality.of(context),
                  style:
                      TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText:
                        loc.getString('currency') ?? "Currency",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('currency_auto_selected') ??
                        "Currency will be selected automatically",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(
                      Icons.currency_exchange_rounded,
                      color: theme.hintColor,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2E6F95), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // AMOUNT
                // ==================================================
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  textDirection: Directionality.of(context),
                  style:
                      TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: loc.getString('payment_amount') ??
                        "Payment Amount",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('enter_payment_amount') ??
                        "Enter payment amount",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(
                      Icons.payments_outlined,
                      color: theme.hintColor,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2E6F95), width: 1.5),
                    ),
                  ),
                  validator: _validateAmount,
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PAYMENT DATE
                // ==================================================
                TextFormField(
                  controller: _paymentDateController,
                  readOnly: true,
                  textDirection: Directionality.of(context),
                  style:
                      TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: loc.getString('payment_date') ??
                        "Payment Date",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('select_payment_date') ??
                        "Select payment date",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(
                      Icons.calendar_today_outlined,
                      color: theme.hintColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.calendar_month_rounded,
                        color: theme.hintColor,
                      ),
                      onPressed: _selectDate,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2E6F95), width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.getString('payment_date_required') ??
                          "Payment date is required.";
                    }
                    return null;
                  },
                  onTap: _selectDate,
                ),

                const SizedBox(height: 32),

                // ==================================================
                // QIAMUDDIN SAVE BUTTON
                // ==================================================
                QiamuddinDesign.primaryButton(
                  context: context,
                  text: isLoading
                      ? loc.getString('saving') ?? "Saving..."
                      : isEditing
                          ? loc.getString('update_payment') ??
                              "Update Payment"
                          : loc.getString('create_payment') ??
                              "Create Payment",
                  icon: isEditing
                      ? Icons.save_rounded
                      : Icons.add_card_rounded,
                  isLoading: isLoading,
                  onPressed: _savePayment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}