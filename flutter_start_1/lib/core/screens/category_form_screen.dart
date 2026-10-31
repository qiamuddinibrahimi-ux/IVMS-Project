import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../localization/app_localizations.dart';
import '../screens/qiamuddin_design.dart'; // IMPORTED THE NEW DESIGN

class CategoryFormScreen extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormScreen({
    super.key,
    this.category,
  });

  bool get isEditing => category != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?.categoryName ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    setState(() => _saving = true);

    final provider = context.read<CategoryProvider>();
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    bool success;
    if (widget.isEditing) {
      success = await provider.updateCategory(
        categoryId: widget.category!.categoryId,
        categoryName: name,
      );
    } else {
      success = await provider.createCategory(categoryName: name);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? loc.getString('category_updated') ?? "Category updated successfully."
                : loc.getString('category_created') ?? "Category created successfully.",
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
          isEditing 
            ? loc.getString('edit_category') ?? "Edit Category" 
            : loc.getString('add_category') ?? "Add Category",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // MODERN AVATAR PREVIEW
              Center(
                child: Container(
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
                        color: const Color(0xFF102C4A).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  ),
                  child: Center(
                    child: Text(
                      _nameController.text.trim().isEmpty
                          ? "C"
                          : _nameController.text.trim().substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF102C4A),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // INPUT FIELD
              TextFormField(
                controller: _nameController,
                 textInputAction: TextInputAction.done,
  // ✅ FIX 1: Allow any text (prevents RTL blocking)
  keyboardType: TextInputType.text, 
  // ✅ FIX 2: Auto-flip text direction based on language
  textDirection: Directionality.of(context), 
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: loc.getString('category_name') ?? "Category Name",
                  labelStyle: TextStyle(color: theme.hintColor),
                  hintText: loc.getString('enter_category_name') ?? "Enter category name",
                  hintStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.category_outlined, color: theme.hintColor),
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
                    borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
                  ),
                ),
                validator: (value) {
                  final name = value?.trim() ?? "";
                  if (name.isEmpty) {
                    return loc.getString('category_required') ?? "Category name is required.";
                  }
                  if (name.length < 2) {
                    return loc.getString('category_min_chars') ?? "Category name must contain at least 2 characters.";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // QIAMUDDIN PRIMARY BUTTON
             QiamuddinDesign.primaryButton(
  context: context, // ✅ Ensure this is present
  text: _saving
      ? loc.getString('saving') ?? "Saving..."
      : isEditing
          ? loc.getString('update_category') ?? "Update Category"
          : loc.getString('create_category') ?? "Create Category",
  icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
  isLoading: _saving,
  onPressed: _saveCategory,
),
            ],
          ),
        ),
      ),
    );
  }
}