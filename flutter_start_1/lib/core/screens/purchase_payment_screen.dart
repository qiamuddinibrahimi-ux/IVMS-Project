import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purchase_payment_model.dart';
import '../providers/purchase_payment_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED
import 'purchase_payment_form_screen.dart';

class PurchasePaymentScreen extends StatefulWidget {
  const PurchasePaymentScreen({
    super.key,
  });

  @override
  State<PurchasePaymentScreen> createState() => _PurchasePaymentScreenState();
}

class _PurchasePaymentScreenState extends State<PurchasePaymentScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PurchasePaymentProvider>().loadPurchasePayments();
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

  List<PurchasePaymentModel> _filteredPayments(
    List<PurchasePaymentModel> payments,
  ) {
    if (_searchQuery.isEmpty) {
      return payments;
    }

    return payments.where((payment) {
      return payment.invoiceNo.toLowerCase().contains(_searchQuery) ||
          payment.vendorName.toLowerCase().contains(_searchQuery) ||
          payment.currencyName.toLowerCase().contains(_searchQuery) ||
          payment.currencyCode.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _addPayment() async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PurchasePaymentFormScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('purchase_payment_created') ??
                'Purchase payment created successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _editPayment(PurchasePaymentModel payment) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PurchasePaymentFormScreen(
          payment: payment,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('purchase_payment_updated') ??
                'Purchase payment updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _deletePayment(PurchasePaymentModel payment) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_purchase_payment') ??
          'Delete Purchase Payment',
      content: loc.getString('delete_purchase_payment_confirm') ??
          'Are you sure you want to delete this payment?',
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final provider = context.read<PurchasePaymentProvider>();
    final success = await provider.deletePurchasePayment(payment.paymentId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (loc.getString('purchase_payment_deleted') ??
                  'Purchase payment deleted successfully.')
              : (provider.errorMessage ??
                  (loc.getString('failed_to_delete_payment') ??
                      'Failed to delete payment.')),
        ),
      ),
    );
  }

  void _showDetails(PurchasePaymentModel payment) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            loc.getString('payment_details') ?? 'Payment Details',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detail(theme, loc.getString('payment_id') ?? 'Payment ID',
                    payment.paymentId.toString()),
                _detail(theme, loc.getString('purchase_id') ?? 'Purchase ID',
                    payment.purchaseId.toString()),
                _detail(theme, loc.getString('invoice') ?? 'Invoice',
                    payment.invoiceNo),
                _detail(theme, loc.getString('purchase_date') ?? 'Purchase Date',
                    payment.purchaseDate),
                _detail(theme, loc.getString('vendor') ?? 'Vendor',
                    payment.vendorName),
                _detail(
                  theme,
                  loc.getString('currency') ?? 'Currency',
                  '${payment.currencyName} (${payment.currencyCode})',
                ),
                _detail(
                  theme,
                  loc.getString('amount') ?? 'Amount',
                  '${payment.symbol}${payment.amount.toStringAsFixed(2)}',
                ),
                _detail(theme, loc.getString('payment_date_label') ?? 'Payment Date',
                    payment.paymentDate),
              ],
            ),
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

  Widget _detail(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
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
          loc.getString('purchase_payments') ?? 'Purchase Payments',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<PurchasePaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.payments.isEmpty) {
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
                        provider.loadPurchasePayments(forceRefresh: true);
                      },
                      child: Text(loc.getString('retry') ?? 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final payments = _filteredPayments(provider.payments);

          return RefreshIndicator(
            onRefresh: () {
              return provider.loadPurchasePayments(forceRefresh: true);
            },
            child: Column(
              children: [
                // SEARCH
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    textDirection: Directionality.of(context),
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: loc.getString('search_purchase_payments') ??
                          'Search purchase payments...',
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(Icons.search, color: theme.hintColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: Icon(
                                Icons.clear,
                                color: theme.hintColor,
                              ),
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
                  child: payments.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * .25,
                            ),
                            Icon(
                              Icons.payment,
                              size: 60,
                              color: theme.hintColor,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                _searchQuery.isNotEmpty
                                    ? (loc.getString('no_payments_found') ??
                                        'No payments found.')
                                    : (loc.getString(
                                            'no_purchase_payments_yet') ??
                                        'No purchase payments yet.'),
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            90,
                          ),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            return _paymentCard(theme, payments[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPayment,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _paymentCard(ThemeData theme, PurchasePaymentModel payment) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF102C4A),
          child: Icon(
            Icons.payment,
            color: theme.brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
        ),
        title: Text(
          payment.invoiceNo.isEmpty
              ? (loc.getString('purchase_num') ?? 'Purchase #{id}')
                  .replaceAll('{id}', '${payment.purchaseId}')
              : payment.invoiceNo,
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
              Text(
                payment.vendorName,
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 3),
              Text(
                '${payment.symbol}${payment.amount.toStringAsFixed(2)} • ${payment.paymentDate}',
                style: TextStyle(color: theme.hintColor),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.hintColor),
          onSelected: (value) {
            switch (value) {
              case 'details':
                _showDetails(payment);
                break;
              case 'edit':
                _editPayment(payment);
                break;
              case 'delete':
                _deletePayment(payment);
                break;
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    const Icon(Icons.visibility),
                    const SizedBox(width: 8),
                    Text(loc.getString('details') ?? 'Details'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(loc.getString('edit') ?? 'Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete),
                    const SizedBox(width: 8),
                    Text(loc.getString('delete') ?? 'Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}