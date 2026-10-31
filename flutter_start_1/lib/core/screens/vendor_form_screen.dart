import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vendor_model.dart';
import '../providers/vendor_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class VendorFormScreen extends StatefulWidget {
  final VendorModel? vendor;

  const VendorFormScreen({
    super.key,
    this.vendor,
  });

  @override
  State<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends State<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditing => widget.vendor != null;

  @override
  void initState() {
    super.initState();

    if (widget.vendor != null) {
      final vendor = widget.vendor!;
      _nameController.text = vendor.vendorName;
      _phoneController.text = vendor.phone ?? '';
      _emailController.text = vendor.email ?? '';
      _addressController.text = vendor.address ?? '';
    }
  }

  Future<void> _saveVendor() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<VendorProvider>();

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    bool success;

    if (_isEditing) {
      success = await provider.updateVendor(
        vendorId: widget.vendor!.vendorId,
        vendorName: name,
        phone: phone.isEmpty ? null : phone,
        email: email.isEmpty ? null : email,
        address: address.isEmpty ? null : address,
      );
    } else {
      success = await provider.createVendor(
        vendorName: name,
        phone: phone.isEmpty ? null : phone,
        email: email.isEmpty ? null : email,
        address: address.isEmpty ? null : address,
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
                ? (loc.getString('vendor_updated') ??
                    'Vendor updated successfully.')
                : (loc.getString('vendor_created') ??
                    'Vendor created successfully.'),
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
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
          _isEditing
              ? (loc.getString('edit_vendor') ?? 'Edit Vendor')
              : (loc.getString('add_vendor') ?? 'Add Vendor'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // VENDOR NAME
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText:
                    loc.getString('vendor_name') ?? 'Vendor Name',
                labelStyle: TextStyle(color: theme.hintColor),
                hintText:
                    loc.getString('enter_vendor_name') ??
                        'Enter vendor name',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.business, color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.getString('vendor_name_required') ??
                      'Vendor name is required.';
                }
                if (value.trim().length < 2) {
                  return loc.getString('vendor_name_min') ??
                      'Vendor name must contain at least 2 characters.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // PHONE
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('phone') ?? 'Phone',
                labelStyle: TextStyle(color: theme.hintColor),
                hintText:
                    loc.getString('enter_vendor_phone') ??
                        'Enter phone number',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.phone, color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // EMAIL
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('email') ?? 'Email',
                labelStyle: TextStyle(color: theme.hintColor),
                hintText:
                    loc.getString('enter_vendor_email') ??
                        'Enter email address',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.email, color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null;
                }

                final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

                if (!emailRegex.hasMatch(value.trim())) {
                  return loc.getString('invalid_email') ??
                      'Please enter a valid email address.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // ADDRESS
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              textDirection: Directionality.of(context),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: loc.getString('address') ?? 'Address',
                labelStyle: TextStyle(color: theme.hintColor),
                hintText:
                    loc.getString('enter_vendor_address') ??
                        'Enter vendor address',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.location_on, color: theme.hintColor),
                alignLabelWithHint: true,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // QIAMUDDIN SAVE BUTTON
            QiamuddinDesign.primaryButton(
              context: context,
              text: _isSaving
                  ? (loc.getString('saving') ?? 'Saving...')
                  : _isEditing
                      ? (loc.getString('update_vendor') ??
                          'Update Vendor')
                      : (loc.getString('create_vendor') ??
                          'Create Vendor'),
              icon: _isEditing ? Icons.save_rounded : Icons.person_add_rounded,
              isLoading: _isSaving,
              onPressed: _saveVendor,
            ),
          ],
        ),
      ),
    );
  }
}