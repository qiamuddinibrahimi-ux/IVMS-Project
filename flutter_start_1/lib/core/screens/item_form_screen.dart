import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../providers/unit_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class ItemFormScreen extends StatefulWidget {
  final ItemModel? item;

  const ItemFormScreen({
    super.key,
    this.item,
  });

  bool get isEditing => item != null;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _descriptionController;

  int? _categoryId;
  int? _unitId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.item?.itemName ?? '',
    );

    _barcodeController = TextEditingController(
      text: widget.item?.barcode ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );

    _categoryId = widget.item?.categoryId;
    _unitId = widget.item?.unitId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDependencies();
    });
  }

  Future<void> _loadDependencies() async {
    final categoryProvider = context.read<CategoryProvider>();
    final unitProvider = context.read<UnitProvider>();

    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.loadCategories();
    }

    if (unitProvider.units.isEmpty) {
      await unitProvider.loadUnits();
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoryId == null) {
      _showError(
          loc.getString('please_select_category') ?? 'Please select a category.');
      return;
    }

    if (_unitId == null) {
      _showError(loc.getString('please_select_unit') ?? 'Please select a unit.');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    final itemProvider = context.read<ItemProvider>();

    final barcode =
        _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim();

    final description =
        _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    bool success;

    if (widget.isEditing) {
      success = await itemProvider.updateItem(
        itemId: widget.item!.itemId,
        itemName: _nameController.text.trim(),
        categoryId: _categoryId!,
        unitId: _unitId!,
        barcode: barcode,
        description: description,
      );
    } else {
      success = await itemProvider.createItem(
        itemName: _nameController.text.trim(),
        categoryId: _categoryId!,
        unitId: _unitId!,
        barcode: barcode,
        description: description,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      _showError(itemProvider.errorMessage ??
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final categoryProvider = context.watch<CategoryProvider>();
    final unitProvider = context.watch<UnitProvider>();

    final categories = categoryProvider.categories;
    final units = unitProvider.units;

    final dependenciesLoading =
        categoryProvider.isLoading || unitProvider.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          widget.isEditing
              ? (loc.getString('edit_item') ?? 'Edit Item')
              : (loc.getString('add_item') ?? 'Add Item'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: dependenciesLoading && (categories.isEmpty || units.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // ITEM ICON
                    // ==================================================
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF102C4A)
                              : const Color(0xFFE8F0F7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          size: 48,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF174A7E),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // ITEM NAME
                    // ==================================================
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text, // RTL keyboard fix
                      textDirection: Directionality.of(context),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText:
                            loc.getString('item_name') ?? 'Item Name',
                        labelStyle: TextStyle(color: theme.hintColor),
                        hintText: loc.getString('enter_item_name_example') ??
                            'Example: Rice 25kg',
                        hintStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: Icon(
                          Icons.inventory_2_outlined,
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
                              color: Color(0xFF174A7E), width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.getString('item_name_required') ??
                              'Item name is required.';
                        }

                        if (value.trim().length < 2) {
                          return loc.getString('item_name_min') ??
                              'Item name must contain at least 2 characters.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // CATEGORY
                    // ==================================================
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      dropdownColor: theme.cardColor,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText:
                            loc.getString('category') ?? 'Category',
                        labelStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: Icon(
                          Icons.category_outlined,
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
                              color: Color(0xFF174A7E), width: 1.5),
                        ),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.categoryId,
                          child: Text(
                            category.categoryName,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _categoryId = value;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return loc.getString('please_select_category') ??
                              'Please select a category.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // UNIT
                    // ==================================================
                    DropdownButtonFormField<int>(
                      initialValue: _unitId,
                      dropdownColor: theme.cardColor,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: loc.getString('unit') ?? 'Unit',
                        labelStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: Icon(
                          Icons.straighten_outlined,
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
                              color: Color(0xFF174A7E), width: 1.5),
                        ),
                      ),
                      items: units.map((unit) {
                        return DropdownMenuItem<int>(
                          value: unit.unitId,
                          child: Text(
                            unit.unitName,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _unitId = value;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return loc.getString('please_select_unit') ??
                              'Please select a unit.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // BARCODE
                    // ==================================================
                    TextFormField(
                      controller: _barcodeController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      textDirection: Directionality.of(context),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: loc.getString('barcode') ?? 'Barcode',
                        labelStyle: TextStyle(color: theme.hintColor),
                        hintText: loc.getString('optional') ?? 'Optional',
                        hintStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: Icon(
                          Icons.qr_code_scanner_rounded,
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
                              color: Color(0xFF174A7E), width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      textDirection: Directionality.of(context),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText:
                            loc.getString('description') ?? 'Description',
                        labelStyle: TextStyle(color: theme.hintColor),
                        hintText: loc.getString('enter_item_description') ??
                            'Optional item description',
                        hintStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 55),
                          child: Icon(
                            Icons.description_outlined,
                            color: theme.hintColor,
                          ),
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
                              color: Color(0xFF174A7E), width: 1.5),
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
                          ? (loc.getString('saving') ?? 'Saving...')
                          : widget.isEditing
                              ? (loc.getString('update_item') ??
                                  'Update Item')
                              : (loc.getString('create_item') ??
                                  'Create Item'),
                      icon: widget.isEditing
                          ? Icons.save_rounded
                          : Icons.add_rounded,
                      isLoading: _isSaving,
                      onPressed: _saveItem,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}