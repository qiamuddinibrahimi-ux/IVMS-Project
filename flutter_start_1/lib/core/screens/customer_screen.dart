import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer_model.dart';
import '../providers/customer_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

import 'customer_form_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });

    _searchController.addListener(() {
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

  // ======================================================
  // OPEN ADD CUSTOMER
  // ======================================================

  void _openAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerFormScreen(),
      ),
    );
  }

  // ======================================================
  // OPEN EDIT CUSTOMER
  // ======================================================

  void _openEditCustomer(CustomerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerFormScreen(
          customer: customer,
        ),
      ),
    );
  }

  // ======================================================
  // DELETE CUSTOMER  (now uses QiamuddinDesign dialog)
  // ======================================================

  Future<void> _deleteCustomer(CustomerModel customer) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE CONFIRMATION DIALOG
    final shouldDelete = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_customer') ?? "Delete Customer",
      content: (loc.getString('delete_customer_confirm') ??
              'Are you sure you want to delete "{name}"?')
          .replaceAll('{name}', customer.customerName),
      cancelText: loc.getString('cancel') ?? "Cancel",
      deleteText: loc.getString('delete') ?? "Delete",
    );

    if (shouldDelete != true) {
      return;
    }

    if (!mounted) return;

    final provider = context.read<CustomerProvider>();

    final success = await provider.deleteCustomer(customer.customerId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('customer_deleted') ??
                "Customer deleted successfully.",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                loc.getString('unable_to_delete_customer') ??
                "Unable to delete customer.",
          ),
        ),
      );
    }
  }

  // ======================================================
  // FILTER CUSTOMERS
  // ======================================================

  List<CustomerModel> _filteredCustomers(List<CustomerModel> customers) {
    if (_searchQuery.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      return customer.customerName.toLowerCase().contains(_searchQuery) ||
          customer.phone.toLowerCase().contains(_searchQuery) ||
          customer.email.toLowerCase().contains(_searchQuery) ||
          customer.address.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // ======================================================
  // REFRESH
  // ======================================================

  Future<void> _refresh() async {
    await context.read<CustomerProvider>().loadCustomers();
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<CustomerProvider>();

    final customers = _filteredCustomers(provider.customers);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('customers') ?? "Customers",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: loc.getString('search') ?? "Search",
            onPressed: () {
              showSearch(
                context: context,
                delegate: _CustomerSearchDelegate(
                  provider.customers,
                  theme,
                ),
              );
            },
          ),

          // ✅ QIAMUDDIN ADD BUTTON
          QiamuddinDesign.addIconButton(
            onPressed: _openAddCustomer,
            tooltip: loc.getString('add_customer') ?? "Add Customer",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(provider, customers, theme, loc),
      ),
    );
  }

  // ======================================================
  // BUILD BODY
  // ======================================================

  Widget _buildBody(
    CustomerProvider provider,
    List<CustomerModel> customers,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    if (provider.isLoading && provider.customers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null && provider.customers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                child: Text(loc.getString('retry') ?? "Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.customers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 70,
                    color: theme.hintColor,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.getString('no_customers') ?? "No customers yet.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.getString('tap_plus_to_add_customer') ??
                        "Tap + to add your first customer.",
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (customers.isEmpty && _searchQuery.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 60,
                    color: theme.hintColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.getString('no_matching_customers') ??
                        "No matching customers.",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];

        return _CustomerCard(
          theme: theme,
          customer: customer,
          onTap: () {
            _openEditCustomer(customer);
          },
          onDelete: () {
            _deleteCustomer(customer);
          },
        );
      },
    );
  }
}

// ============================================================
// CUSTOMER CARD  (kept as-is; only delete tooltip translated)
// ============================================================

class _CustomerCard extends StatelessWidget {
  final ThemeData theme;
  final CustomerModel customer;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.theme,
    required this.customer,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = customer.customerName.trim().isNotEmpty
        ? customer.customerName.trim()[0].toUpperCase()
        : "C";

    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              // ==================================================
              // AVATAR
              // ==================================================

              CircleAvatar(
                radius: 28,
                backgroundColor: theme.brightness == Brightness.dark
                    ? const Color(0xFF5D3A1A)
                    : const Color(0xFF8B5A2B),
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // CUSTOMER INFORMATION
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 15,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              customer.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (customer.email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 15,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              customer.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ==================================================
              // DELETE
              // ==================================================

              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                tooltip: loc.getString('delete_customer') ?? "Delete Customer",
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER SEARCH DELEGATE  (kept as-is)
// ============================================================

class _CustomerSearchDelegate extends SearchDelegate<CustomerModel?> {
  final List<CustomerModel> customers;
  final ThemeData theme;

  _CustomerSearchDelegate(this.customers, this.theme);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: theme.hintColor),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults(context);
  }

  Widget _buildResults(BuildContext context) {
    final search = query.trim().toLowerCase();

    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final results = customers.where((customer) {
      return customer.customerName.toLowerCase().contains(search) ||
          customer.phone.toLowerCase().contains(search) ||
          customer.email.toLowerCase().contains(search) ||
          customer.address.toLowerCase().contains(search);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          loc.getString('no_customers_found') ?? "No customers found.",
          style: TextStyle(color: theme.hintColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final customer = results[index];

        final firstLetter = customer.customerName.trim().isNotEmpty
            ? customer.customerName.trim()[0].toUpperCase()
            : "C";

        return Card(
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF5D3A1A)
                  : const Color(0xFF8B5A2B),
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              customer.customerName,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            subtitle: Text(
              customer.phone.isNotEmpty ? customer.phone : customer.email,
              style: TextStyle(color: theme.hintColor),
            ),
            onTap: () {
              close(context, customer);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerFormScreen(
                    customer: customer,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}