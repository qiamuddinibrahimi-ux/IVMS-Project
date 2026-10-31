import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vendor_model.dart';
import '../providers/vendor_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED
import 'vendor_form_screen.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VendorProvider>().loadVendors();
    });

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VendorModel> _filteredVendors(List<VendorModel> vendors) {
    if (_searchText.isEmpty) {
      return vendors;
    }

    return vendors.where((vendor) {
      return vendor.vendorName.toLowerCase().contains(_searchText) ||
          (vendor.phone ?? '').toLowerCase().contains(_searchText) ||
          (vendor.email ?? '').toLowerCase().contains(_searchText) ||
          (vendor.address ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  Future<void> _addVendor() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VendorFormScreen(),
      ),
    );
  }

  Future<void> _editVendor(VendorModel vendor) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VendorFormScreen(vendor: vendor),
      ),
    );
  }

  void _showDetails(VendorModel vendor) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            loc.getString('vendor_details') ?? 'Vendor Details',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(theme, loc.getString('name') ?? 'Name',
                  vendor.vendorName),
              _detailRow(
                theme,
                loc.getString('phone') ?? 'Phone',
                vendor.phone?.isNotEmpty == true
                    ? vendor.phone!
                    : (loc.getString('not_provided') ?? 'Not provided'),
              ),
              _detailRow(
                theme,
                loc.getString('email') ?? 'Email',
                vendor.email?.isNotEmpty == true
                    ? vendor.email!
                    : (loc.getString('not_provided') ?? 'Not provided'),
              ),
              _detailRow(
                theme,
                loc.getString('address') ?? 'Address',
                vendor.address?.isNotEmpty == true
                    ? vendor.address!
                    : (loc.getString('not_provided') ?? 'Not provided'),
              ),
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

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
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

  Future<void> _deleteVendor(VendorModel vendor) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_vendor') ?? 'Delete Vendor',
      content: (loc.getString('delete_vendor_confirm') ??
              'Are you sure you want to delete "{name}"?')
          .replaceAll('{name}', vendor.vendorName),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<VendorProvider>();
    final success = await provider.deleteVendor(vendor.vendorId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('vendor_deleted') ??
                'Vendor deleted successfully.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                (loc.getString('failed_to_delete_vendor') ??
                    'Failed to delete vendor.'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<VendorProvider>();
    final vendors = _filteredVendors(provider.vendors);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('vendors') ?? 'Vendors',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // ✅ QIAMUDDIN ADD BUTTON
          QiamuddinDesign.addIconButton(
            onPressed: _addVendor,
            tooltip: loc.getString('add_vendor') ?? 'Add Vendor',
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              textDirection: Directionality.of(context),
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: loc.getString('search_vendors_hint') ??
                    'Search vendors...',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
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

          // LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                return provider.loadVendors(forceRefresh: true);
              },
              child: _buildContent(theme, provider, vendors),
            ),
          ),
        ],
      ),

      // ADD FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVendor,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        icon: const Icon(Icons.person_add),
        label: Text(loc.getString('add_vendor') ?? 'Add Vendor'),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    VendorProvider provider,
    List<VendorModel> vendors,
  ) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (provider.isLoading && provider.vendors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.vendors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  provider.loadVendors(forceRefresh: true);
                },
                child: Text(loc.getString('try_again') ?? 'Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.vendors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 60,
                  color: theme.hintColor,
                ),
                const SizedBox(height: 12),
                Text(
                  loc.getString('no_vendors_found') ?? 'No vendors found.',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (vendors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          Center(
            child: Text(
              loc.getString('no_matching_vendors') ??
                  'No matching vendors found.',
              style: TextStyle(color: theme.hintColor),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];

        return Card(
          color: theme.cardColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            leading: CircleAvatar(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFF102C4A),
              foregroundColor: theme.brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              child: Text(
                vendor.vendorName.isNotEmpty
                    ? vendor.vendorName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            title: Text(
              vendor.vendorName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vendor.phone != null && vendor.phone!.isNotEmpty)
                    Text(
                      '${loc.getString('phone') ?? 'Phone'}: ${vendor.phone}',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  if (vendor.email != null && vendor.email!.isNotEmpty)
                    Text(
                      '${loc.getString('email') ?? 'Email'}: ${vendor.email}',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  if (vendor.address != null &&
                      vendor.address!.isNotEmpty)
                    Text(
                      '${loc.getString('address') ?? 'Address'}: ${vendor.address}',
                      style: TextStyle(color: theme.hintColor),
                    ),
                ],
              ),
            ),

            isThreeLine: true,

            onTap: () => _showDetails(vendor),

            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: theme.hintColor),
              onSelected: (value) {
                if (value == 'edit') {
                  _editVendor(vendor);
                }
                if (value == 'delete') {
                  _deleteVendor(vendor);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 10),
                        Text(loc.getString('edit') ?? 'Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 10),
                        Text(loc.getString('delete') ?? 'Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        );
      },
    );
  }
}