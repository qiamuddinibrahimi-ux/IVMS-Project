import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/exchange_rate_model.dart';
import '../providers/currency_provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class ExchangeRateFormScreen extends StatefulWidget {
  final ExchangeRateModel? exchangeRate;

  const ExchangeRateFormScreen({
    super.key,
    this.exchangeRate,
  });

  bool get isEditing => exchangeRate != null;

  @override
  State<ExchangeRateFormScreen> createState() => _ExchangeRateFormScreenState();
}

class _ExchangeRateFormScreenState extends State<ExchangeRateFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _rateController = TextEditingController();

  DateTime? _effectiveDate;

  int? _fromCurrencyId;
  int? _toCurrencyId;

  bool _isSaving = false;

  // ======================================================
  // INIT
  // ======================================================

  @override
  void initState() {
    super.initState();

    final exchangeRate = widget.exchangeRate;

    if (exchangeRate != null) {
      _fromCurrencyId = exchangeRate.fromCurrencyId;
      _toCurrencyId = exchangeRate.toCurrencyId;
      _rateController.text = exchangeRate.rate.toString();
      _effectiveDate = DateTime.tryParse(exchangeRate.effectiveDate);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCurrencies();
    });
  }

  Future<void> _loadCurrencies() async {
    if (!mounted) return;

    final provider = context.read<CurrencyProvider>();

    if (provider.currencies.isEmpty) {
      await provider.loadCurrencies();
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  // ======================================================
  // SELECT DATE
  // ======================================================

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _effectiveDate = picked;
      });
    }
  }

  // ======================================================
  // FORMAT DATE
  // ======================================================

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, "0");
    final month = date.month.toString().padLeft(2, "0");
    final day = date.day.toString().padLeft(2, "0");

    return "$year-$month-$day";
  }

  // ======================================================
  // SAVE
  // ======================================================

  Future<void> _save() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromCurrencyId == null) {
      _showError(
          loc.getString('please_select_from_currency') ??
              "Please select the from currency.");
      return;
    }

    if (_toCurrencyId == null) {
      _showError(
          loc.getString('please_select_to_currency') ??
              "Please select the to currency.");
      return;
    }

    if (_fromCurrencyId == _toCurrencyId) {
      _showError(
          loc.getString('currencies_must_differ') ??
              "From currency and to currency must be different.");
      return;
    }

    if (_effectiveDate == null) {
      _showError(
          loc.getString('please_select_effective_date') ??
              "Please select the effective date.");
      return;
    }

    final rate = double.tryParse(_rateController.text.trim());

    if (rate == null || rate <= 0) {
      _showError(
          loc.getString('rate_must_be_positive') ??
              "Exchange rate must be greater than zero.");
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<ExchangeRateProvider>();
    final date = _formatDate(_effectiveDate!);

    bool success;

    if (widget.isEditing) {
      success = await provider.updateExchangeRate(
        id: widget.exchangeRate!.exchangeRateId,
        fromCurrencyId: _fromCurrencyId!,
        toCurrencyId: _toCurrencyId!,
        rate: rate,
        effectiveDate: date,
      );
    } else {
      success = await provider.createExchangeRate(
        fromCurrencyId: _fromCurrencyId!,
        toCurrencyId: _toCurrencyId!,
        rate: rate,
        effectiveDate: date,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    _showError(
        provider.errorMessage ??
        loc.getString('something_wrong') ??
        "Something went wrong.");
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

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final currencyProvider = context.watch<CurrencyProvider>();
    final currencies = currencyProvider.currencies;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          widget.isEditing
              ? (loc.getString('edit_exchange_rate') ??
                  "Edit Exchange Rate")
              : (loc.getString('add_exchange_rate') ?? "Add Exchange Rate"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: currencyProvider.isLoading && currencies.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : currencies.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.currency_exchange,
                          size: 60,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.getString('no_currencies_available') ??
                              "No currencies available.",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyProvider.errorMessage ??
                              (loc.getString('create_currencies_first') ??
                                  "Please create currencies first."),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.hintColor),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<CurrencyProvider>()
                                .loadCurrencies(forceRefresh: true);
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(loc.getString('retry') ?? "Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==================================================
                        // FROM CURRENCY
                        // ==================================================

                        DropdownButtonFormField<int>(
                          value: _fromCurrencyId,
                          dropdownColor: theme.cardColor,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: loc.getString('from_currency') ??
                                "From Currency",
                            labelStyle: TextStyle(color: theme.hintColor),
                            prefixIcon: Icon(
                              Icons.arrow_upward_rounded,
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
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2E6F95), width: 1.5),
                            ),
                          ),
                          items: currencies
                              .map(
                                (currency) => DropdownMenuItem<int>(
                                  value: currency.currencyId,
                                  child: Text(
                                    "${currency.currencyName} "
                                    "(${currency.currencyCode})",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    _fromCurrencyId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return loc.getString('select_from_currency') ??
                                  "Select from currency";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // TO CURRENCY
                        // ==================================================

                        DropdownButtonFormField<int>(
                          value: _toCurrencyId,
                          dropdownColor: theme.cardColor,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: loc.getString('to_currency') ??
                                "To Currency",
                            labelStyle: TextStyle(color: theme.hintColor),
                            prefixIcon: Icon(
                              Icons.arrow_downward_rounded,
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
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2E6F95), width: 1.5),
                            ),
                          ),
                          items: currencies
                              .map(
                                (currency) => DropdownMenuItem<int>(
                                  value: currency.currencyId,
                                  child: Text(
                                    "${currency.currencyName} "
                                    "(${currency.currencyCode})",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    _toCurrencyId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return loc.getString('select_to_currency') ??
                                  "Select to currency";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // RATE
                        // ==================================================

                        TextFormField(
                          controller: _rateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textDirection: Directionality.of(context),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,8}'),
                            ),
                          ],
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: loc.getString('exchange_rate') ??
                                "Exchange Rate",
                            labelStyle: TextStyle(color: theme.hintColor),
                            hintText:
                                loc.getString('rate_example') ?? "Example: 0.0125",
                            hintStyle: TextStyle(color: theme.hintColor),
                            prefixIcon: Icon(
                              Icons.currency_exchange,
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
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2E6F95), width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return loc.getString('exchange_rate_required') ??
                                  "Exchange rate is required";
                            }

                            final number = double.tryParse(value.trim());

                            if (number == null || number <= 0) {
                              return loc.getString('invalid_rate_positive') ??
                                  "Enter a valid rate greater than zero";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // EFFECTIVE DATE
                        // ==================================================

                        InkWell(
                          onTap: _isSaving ? null : _selectDate,
                          borderRadius: BorderRadius.circular(16),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: loc.getString('effective_date') ??
                                  "Effective Date",
                              labelStyle: TextStyle(color: theme.hintColor),
                              prefixIcon: Icon(
                                Icons.calendar_month,
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
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.2)),
                              ),
                            ),
                            child: Text(
                              _effectiveDate == null
                                  ? (loc.getString('select_date_hint') ??
                                      "Select date")
                                  : _formatDate(_effectiveDate!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _effectiveDate == null
                                    ? theme.hintColor
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // QIAMUDDIN SAVE BUTTON
                        // ==================================================

                        QiamuddinDesign.primaryButton(
                          context: context,
                          text: _isSaving
                              ? (loc.getString('saving') ?? "Saving...")
                              : widget.isEditing
                                  ? (loc.getString('update_exchange_rate') ??
                                      "Update Exchange Rate")
                                  : (loc.getString('create_exchange_rate') ??
                                      "Create Exchange Rate"),
                          icon: widget.isEditing
                              ? Icons.save_rounded
                              : Icons.add_rounded,
                          isLoading: _isSaving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}