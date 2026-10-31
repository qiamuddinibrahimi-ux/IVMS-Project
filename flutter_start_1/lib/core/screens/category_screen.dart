import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../localization/app_localizations.dart';
import '../screens/qiamuddin_design.dart'; // IMPORTED THE NEW DESIGN
import 'category_form_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });

    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> _filteredCategories(List<CategoryModel> categories) {
    if (_searchText.isEmpty) return categories;
    return categories.where((category) {
      return category.categoryName.toLowerCase().contains(_searchText);
    }).toList();
  }

  Future<void> _openAddCategory() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryFormScreen()));
  }

  Future<void> _openEditCategory(CategoryModel category) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryFormScreen(category: category)));
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // QIAMUDDIN DELETE CONFIRMATION DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_category') ?? "Delete Category",
      content: '${loc.getString('delete_category_confirm') ?? "Are you sure you want to delete"} "${category.categoryName}"?',
      cancelText: loc.getString('cancel') ?? "Cancel",
      deleteText: loc.getString('delete') ?? "Delete",
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<CategoryProvider>();
    final success = await provider.deleteCategory(category.categoryId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.getString('category_deleted') ?? "Category deleted successfully.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? loc.getString('could_not_delete') ?? "Could not delete category.")),
      );
    }
  }

  Future<void> _refresh() async {
    await context.read<CategoryProvider>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        // QIAMUDDIN SEARCH BAR
        title: QiamuddinDesign.searchBar(
          context: context,
          controller: _searchController,
          hintText: loc.getString('search_categories') ?? "Search categories...",
          hasText: _searchText.isNotEmpty,
          onClear: () => _searchController.clear(),
        ),
        actions: [
          // QIAMUDDIN ADD BUTTON
          QiamuddinDesign.addIconButton(
            onPressed: _openAddCategory,
            tooltip: loc.getString('add_category') ?? "Add Category",
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 60, color: theme.hintColor),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _refresh, child: Text(loc.getString('retry') ?? "Retry")),
                  ],
                ),
              ),
            );
          }

          final categories = _filteredCategories(provider.categories);

          if (categories.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  Icon(Icons.category_outlined, size: 80, color: theme.hintColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _searchText.isEmpty 
                          ? loc.getString('no_categories') ?? "No categories found." 
                          : loc.getString('no_matching_categories') ?? "No matching categories found.",
                      style: TextStyle(fontSize: 16, color: theme.hintColor),
                    ),
                  ),
                  if (_searchText.isEmpty) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _openAddCategory,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(loc.getString('add_category') ?? "Add Category"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF102C4A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                
                // QIAMUDDIN LIST CARD
               return QiamuddinDesign.listCard(
  context: context, // ✅ ADD THIS
  theme: theme,
  avatarText: category.categoryName.trim().isEmpty ? "?" : category.categoryName.trim().substring(0, 1).toUpperCase(),
  title: category.categoryName,
  subtitle: "ID: ${category.categoryId}",
  onTap: () => _openEditCategory(category),
  onDelete: () => _deleteCategory(category),
  avatarBgColor: const Color(0xFF174A7E),
);
              },
            ),
          );
        },
      ),
    );
  }
}