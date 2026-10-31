import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer_model.dart';
import '../providers/customer_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // IMPORTED QIAMUDDIN DESIGN

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customer;

  const CustomerFormScreen({
    super.key,
    this.customer,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.customer?.customerName ?? "",
    );

    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? "",
    );

    _emailController = TextEditingController(
      text: widget.customer?.email ?? "",
    );

    _addressController = TextEditingController(
      text: widget.customer?.address ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  // ======================================================
  // SAVE CUSTOMER
  // ======================================================

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<CustomerProvider>();
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    bool success;

    if (isEditing) {
      success = await provider.updateCustomer(
        customerId: widget.customer!.customerId,
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
      );
    } else {
      success = await provider.createCustomer(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? loc.getString('customer_updated') ?? "Customer updated successfully."
                : loc.getString('customer_created') ?? "Customer created successfully.",
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? loc.getString('something_wrong') ?? "Something went wrong.",
          ),
        ),
      );
    }
  }

  // ======================================================
  // EMAIL VALIDATION
  // ======================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? "";

    if (email.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!emailRegex.hasMatch(email)) {
      return loc.getString('invalid_email') ?? "Please enter a valid email address.";
    }

    return null;
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<CustomerProvider>().isLoading;
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          isEditing 
              ? loc.getString('edit_customer') ?? "Edit Customer" 
              : loc.getString('add_customer') ?? "Add Customer",
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
                // CUSTOMER AVATAR (Modern Gradient)
                // ==================================================

                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: theme.brightness == Brightness.dark
                            ? [const Color(0xFF5D3A1A), const Color(0xFF3E2510)]
                            : [const Color(0xFF8B5A2B), const Color(0xFFB87B4A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5A2B).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ]
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.trim().isNotEmpty
                            ? _nameController.text.trim()[0].toUpperCase()
                            : "C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // CUSTOMER NAME
                // ==================================================

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text, // ✅ For RTL support
                  textDirection: Directionality.of(context), // ✅ For RTL support
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: loc.getString('customer_name') ?? "Customer Name",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('enter_customer_name') ?? "Enter customer name",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(Icons.person_outline, color: theme.hintColor),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? "";

                    if (name.isEmpty) {
                      return loc.getString('customer_name_required') ?? "Customer name is required.";
                    }

                    if (name.length < 2) {
                      return loc.getString('customer_name_min') ?? "Name must contain at least 2 characters.";
                    }

                    return null;
                  },
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PHONE
                // ==================================================

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  textDirection: Directionality.of(context),
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: loc.getString('phone') ?? "Phone",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('enter_phone') ?? "Enter phone number",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(Icons.phone_outlined, color: theme.hintColor),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // EMAIL
                // ==================================================

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textDirection: Directionality.of(context),
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: loc.getString('email') ?? "Email",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('enter_email') ?? "Enter email address",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(Icons.email_outlined, color: theme.hintColor),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5),
                    ),
                  ),
                  validator: _validateEmail,
                ),

                const SizedBox(height: 16),

                // ==================================================
                // ADDRESS
                // ==================================================

                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text, // ✅ For RTL support
                  textDirection: Directionality.of(context), // ✅ For RTL support
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: loc.getString('address') ?? "Address",
                    labelStyle: TextStyle(color: theme.hintColor),
                    hintText: loc.getString('enter_address') ?? "Enter customer address",
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.location_on_outlined, color: theme.hintColor),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5),
                    ),
                  ),
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
                          ? loc.getString('update_customer') ?? "Update Customer"
                          : loc.getString('create_customer') ?? "Create Customer",
                  icon: isEditing ? Icons.save_rounded : Icons.person_add_rounded,
                  isLoading: isLoading,
                  onPressed: _saveCustomer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}