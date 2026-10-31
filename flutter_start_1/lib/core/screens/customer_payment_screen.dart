import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer_payment_model.dart';
import '../providers/customer_payment_provider.dart';
import '../localization/app_localizations.dart';
import '../screens/qiamuddin_design.dart';
import 'customer_payment_form_screen.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});

  @override
  State<CustomerPaymentScreen> createState() =>
      _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState
    extends State<CustomerPaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CustomerPaymentProvider>().loadCustomerPayments();
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

  void _openAddPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerPaymentFormScreen(),
      ),
    );
  }

  void _openEditPayment(CustomerPaymentModel payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerPaymentFormScreen(payment: payment),
      ),
    );
  }

  Future<void> _deletePayment(CustomerPaymentModel payment) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final shouldDelete = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_payment') ?? "Delete Payment",
      content: (loc.getString('delete_payment_confirm') ??
              "Are you sure you want to delete this payment of {amount} {currency}?")
          .replaceAll('{amount}', payment.amount.toString())
          .replaceAll('{currency}', payment.currencyCode),
      cancelText: loc.getString('cancel') ?? "Cancel",
      deleteText: loc.getString('delete') ?? "Delete",
    );

    if (shouldDelete != true) return;
    if (!mounted) return;

    final provider = context.read<CustomerPaymentProvider>();
    final success = await provider.deleteCustomerPayment(
      payment.customerPaymentId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.getString('customer_payment_deleted') ??
              "Customer payment deleted successfully."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ??
              loc.getString('unable_to_delete_payment') ??
              "Unable to delete payment."),
        ),
      );
    }
  }

  List<CustomerPaymentModel> _filteredPayments(
      List<CustomerPaymentModel> payments) {
    if (_searchQuery.isEmpty) return payments;

    return payments.where((payment) {
      return payment.customerName.toLowerCase().contains(_searchQuery) ||
          payment.invoiceNo.toLowerCase().contains(_searchQuery) ||
          payment.currencyName.toLowerCase().contains(_searchQuery) ||
          payment.currencyCode.toLowerCase().contains(_searchQuery) ||
          payment.saleId.toString().contains(_searchQuery) ||
          payment.customerId.toString().contains(_searchQuery);
    }).toList();
  }

  Future<void> _refresh() async {
    await context.read<CustomerPaymentProvider>().loadCustomerPayments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.watch<CustomerPaymentProvider>();
    final payments = _filteredPayments(provider.payments);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('customer_payments') ?? "Customer Payments",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // ✅ QIAMUDDIN ADD BUTTON (only one action — no refresh)
          QiamuddinDesign.addIconButton(
            onPressed: _openAddPayment,
            tooltip:
                loc.getString('add_customer_payment') ?? "Add Payment",
          ),
        ],
      ),
      body: Column(
        children: [
          // ============================================
          // ✅ FIXED: SEARCH BAR NOW MATCHES OTHER SCREENS
          //    (cardColor fill, radius 12, RTL)
          // ============================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              textDirection: Directionality.of(context),
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: loc.getString('search_payments_hint') ??
                    "Search payments...",
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon:
                    Icon(Icons.search_rounded, color: theme.hintColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: Icon(Icons.clear_rounded,
                            color: theme.hintColor),
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

          // ============================================
          // LIST BODY
          // ============================================
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildBody(provider, payments, theme, loc),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    CustomerPaymentProvider provider,
    List<CustomerPaymentModel> payments,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    // LOADING
    if (provider.isLoading && provider.payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // ERROR
    if (provider.errorMessage != null && provider.payments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
            ),
          ),
        ],
      );
    }

    // SEARCH EMPTY
    if (payments.isEmpty && _searchQuery.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Center(
              child: Text(
                loc.getString('no_matching_payments') ??
                    "No matching payments.",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // NO PAYMENTS
    if (provider.payments.isEmpty) {
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
                    Icons.payments_outlined,
                    size: 70,
                    color: theme.hintColor,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.getString('no_customer_payments') ??
                        "No customer payments yet.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.getString('tap_plus_to_record_payment') ??
                        "Tap + to record a customer payment.",
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ============================================
    // QIAMUDDIN LIST CARDS
    // ============================================
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: QiamuddinDesign.listCard(
            context: context,
            theme: theme,
            avatarText: payment.currencyCode.isNotEmpty
                ? payment.currencyCode.substring(0, 1)
                : "P",
            title: payment.customerName.isNotEmpty
                ? payment.customerName
                : "Customer #${payment.customerId}",
            subtitle:
                "${payment.invoiceNo.isNotEmpty ? payment.invoiceNo : 'Sale #${payment.saleId}'} • "
                "${payment.symbol}${payment.amount.toStringAsFixed(2)} • ${payment.paymentDate}",
            avatarBgColor: const Color(0xFF2E6F95),
            onTap: () => _openEditPayment(payment),
            onDelete: () => _deletePayment(payment),
          ),
        );
      },
    );
  }
}