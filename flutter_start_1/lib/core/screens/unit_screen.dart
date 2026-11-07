import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/unit_model.dart';
import '../providers/unit_provider.dart';
import '../localization/app_localizations.dart';
import '../screens/qiamuddin_design.dart';
import 'unit_form_screen.dart';

class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UnitProvider>().loadUnits();
    });

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UnitModel> _filteredUnits(List<UnitModel> units) {
    if (_searchQuery.isEmpty) {
      return units;
    }

    return units.where((unit) {
      return unit.unitName.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _addUnit() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UnitFormScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('unit_created') ?? 'Unit created successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _editUnit(UnitModel unit) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UnitFormScreen(unit: unit),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('unit_updated') ?? 'Unit updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteUnit(UnitModel unit) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_unit') ?? 'Delete Unit',
      content: (loc.getString('delete_unit_confirm') ??
              'Are you sure you want to delete "{name}"?')
          .replaceAll('{name}', unit.unitName),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<UnitProvider>();
    final success = await provider.deleteUnit(unit.unitId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('unit_deleted') ?? 'Unit deleted successfully.',
          ),
        ),
      );
    } else {
      _showError(provider.errorMessage);
    }
  }

  void _showError(String? message) {
    if (!mounted) return;

    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ??
            (loc.getString('something_wrong') ?? 'Something went wrong.')),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _refreshUnits() async {
    await context.read<UnitProvider>().loadUnits(forceRefresh: true);
  }

  void _showUnitDetails(UnitModel unit) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            loc.getString('unit_details') ?? 'Unit Details',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.straighten,
                size: 60,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF102C4A),
              ),
              const SizedBox(height: 16),
              Text(
                unit.unitName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              // ✅ REMOVED: "Unit ID: {id}" text
              //    (the id still exists in the model & backend — just not shown)
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.getString('close') ?? 'Close',
                style: TextStyle(color: theme.hintColor),
              ),
            ),
          ],
        );
      },
    );
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
          loc.getString('units') ?? 'Units',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          QiamuddinDesign.addIconButton(
            onPressed: _addUnit,
            tooltip: loc.getString('add_unit') ?? 'Add Unit',
          ),
        ],
      ),
      body: Consumer<UnitProvider>(
        builder: (context, provider, child) {
          final filteredUnits = _filteredUnits(provider.units);

          if (provider.isLoading && provider.units.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.units.isEmpty) {
            return _buildErrorState(theme, provider);
          }

          if (provider.units.isEmpty) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: _refreshUnits,
            child: Column(
              children: [
                // SEARCH
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    textDirection: Directionality.of(context),
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: loc.getString('search_units_hint') ??
                          'Search units...',
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(Icons.search, color: theme.hintColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () => _searchController.clear(),
                              icon: Icon(Icons.clear, color: theme.hintColor),
                            )
                          : null,
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // COUNT
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Directionality.of(context) == TextDirection.rtl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      filteredUnits.length == 1
                          ? (loc.getString('unit_count') ?? '{count} unit')
                              .replaceAll('{count}', '${filteredUnits.length}')
                          : (loc.getString('unit_count_plural') ??
                                  '{count} units')
                              .replaceAll(
                                  '{count}', '${filteredUnits.length}'),
                      style: TextStyle(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // LIST
                Expanded(
                  child: filteredUnits.isEmpty
                      ? _buildNoSearchResults(theme)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: filteredUnits.length,
                          itemBuilder: (context, index) {
                            final unit = filteredUnits[index];
                            return _buildUnitCard(theme, unit);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        onPressed: _addUnit,
        icon: const Icon(Icons.add),
        label: Text(loc.getString('add_unit') ?? 'Add Unit'),
      ),
    );
  }

  Widget _buildUnitCard(ThemeData theme, UnitModel unit) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showUnitDetails(unit),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF102C4A)
                      : const Color(0xFF102C4A).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.straighten,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF102C4A),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      unit.unitName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    // ✅ REMOVED: "Unit ID: {id}" text
                    //    (the id is still used by edit/delete — not shown)
                  ],
                ),
              ),
              IconButton(
                tooltip: loc.getString('edit') ?? 'Edit',
                onPressed: () => _editUnit(unit),
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme.hintColor,
                ),
              ),
              IconButton(
                tooltip: loc.getString('delete') ?? 'Delete',
                onPressed: () => _deleteUnit(unit),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return RefreshIndicator(
      onRefresh: _refreshUnits,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.30),
          Icon(Icons.straighten, size: 80, color: theme.hintColor),
          const SizedBox(height: 20),
          Center(
            child: Text(
              loc.getString('no_units_found') ?? 'No units found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              loc.getString('create_first_unit_hint') ??
                  'Create your first unit to get started.',
              style: TextStyle(color: theme.hintColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(ThemeData theme) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.search_off, size: 70, color: theme.hintColor),
        const SizedBox(height: 16),
        Center(
          child: Text(
            loc.getString('no_matching_units') ?? 'No matching units',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme, UnitProvider provider) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return RefreshIndicator(
      onRefresh: _refreshUnits,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.error_outline, size: 70, color: Colors.red),
          const SizedBox(height: 20),
          Center(
            child: Text(
              loc.getString('failed_to_load_units') ??
                  'Failed to load units',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              provider.errorMessage ??
                  (loc.getString('something_wrong') ??
                      'Something went wrong.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _refreshUnits,
              icon: const Icon(Icons.refresh),
              label: Text(loc.getString('try_again') ?? 'Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}