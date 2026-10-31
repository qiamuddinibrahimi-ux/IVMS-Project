import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/currency_model.dart';
import '../providers/currency_provider.dart';
import '../localization/app_localizations.dart';
import '../screens/qiamuddin_design.dart'; // IMPORTED QIAMUDDIN DESIGN

class CurrencyFormScreen extends StatefulWidget {
  final CurrencyModel? currency;

  const CurrencyFormScreen({
    super.key,
    this.currency,
  });

  bool get isEditing => currency != null;

  @override
  State<CurrencyFormScreen> createState() => _CurrencyFormScreenState();
}

class _CurrencyFormScreenState extends State<CurrencyFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _symbolController;

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currency?.currencyName ?? "");
    _codeController = TextEditingController(text: widget.currency?.currencyCode ?? "");
    _symbolController = TextEditingController(text: widget.currency?.symbol ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrency() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<CurrencyProvider>();
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    bool success;
    if (widget.isEditing) {
      success = await provider.updateCurrency(
        currencyId: widget.currency!.currencyId,
        currencyName: _nameController.text.trim(),
        currencyCode: _codeController.text.trim().toUpperCase(),
        symbol: _symbolController.text.trim(),
      );
    } else {
      success = await provider.createCurrency(
        currencyName: _nameController.text.trim(),
        currencyCode: _codeController.text.trim().toUpperCase(),
        symbol: _symbolController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? loc.getString('something_wrong') ?? "Something went wrong."),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.isEditing;
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          isEditing ? loc.getString('edit_currency') ?? "Edit Currency" : loc.getString('add_currency') ?? "Add Currency",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MODERN PREVIEW (Matching Category Form)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: theme.brightness == Brightness.dark
                                ? [const Color(0xFF1E3A5F), const Color(0xFF102C4A)]
                                : [const Color(0xFFE8EEF5), const Color(0xFFD0E0F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF174A7E).withValues(alpha: 0.3), 
                              blurRadius: 20, 
                              offset: const Offset(0, 8)
                            )
                          ]
                        ),
                        child: Center(
                          child: Text(
                            _symbolController.text.trim().isNotEmpty ? _symbolController.text.trim() : "?",
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF102C4A), 
                              fontSize: 32, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : loc.getString('currency') ?? "Currency",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _codeController.text.trim().isNotEmpty ? _codeController.text.trim().toUpperCase() : "---",
                        style: TextStyle(fontSize: 14, color: theme.hintColor, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // INPUTS (Matching Category Form style)
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text, // ✅ For RTL support
                  textDirection: Directionality.of(context), // ✅ For RTL support
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(theme, loc.getString('currency_name') ?? "Currency Name", loc.getString('example_afn') ?? "Example: Afghan Afghani", Icons.currency_exchange_rounded),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return loc.getString('currency_name_required') ?? "Currency name is required.";
                    if (value.trim().length < 2) return loc.getString('currency_name_min') ?? "Currency name must contain at least 2 characters.";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text, // ✅ For RTL support
                  textDirection: Directionality.of(context), // ✅ For RTL support
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                  onChanged: (value) {
                    final upper = value.toUpperCase();
                    if (value != upper) {
                      _codeController.value = _codeController.value.copyWith(text: upper, selection: TextSelection.collapsed(offset: upper.length));
                    }
                    setState(() {});
                  },
                  decoration: _inputDecoration(theme, loc.getString('currency_code') ?? "Currency Code", loc.getString('example_code') ?? "Example: AFN", Icons.code_rounded, showCounter: false),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return loc.getString('currency_code_required') ?? "Currency code is required.";
                    if (value.trim().length != 3) return loc.getString('currency_code_exact') ?? "Currency code must contain exactly 3 characters.";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _symbolController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text, // ✅ For RTL support
                  textDirection: Directionality.of(context), // ✅ For RTL support
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(theme, loc.getString('currency_symbol') ?? "Currency Symbol", loc.getString('example_symbol') ?? "Example: ؋", Icons.attach_money_rounded),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return loc.getString('currency_symbol_required') ?? "Currency symbol is required.";
                    return null;
                  },
                  onFieldSubmitted: (_) => _saveCurrency(),
                ),

                const SizedBox(height: 30),

                // QIAMUDDIN PRIMARY BUTTON
                QiamuddinDesign.primaryButton(
                  context: context,
                  text: _isSaving
                      ? loc.getString('saving') ?? "Saving..."
                      : isEditing
                          ? loc.getString('update_currency') ?? "Update Currency"
                          : loc.getString('create_currency') ?? "Create Currency",
                  icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
                  isLoading: _isSaving,
                  onPressed: _saveCurrency,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label, String hint, IconData icon, {bool showCounter = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.hintColor),
      hintText: hint,
      hintStyle: TextStyle(color: theme.hintColor),
      prefixIcon: Icon(icon, color: theme.hintColor),
      counterText: showCounter ? null : "",
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF174A7E), width: 1.5)),
    );
  }
}