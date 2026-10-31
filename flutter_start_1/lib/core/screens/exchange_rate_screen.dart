import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exchange_rate_model.dart';
import '../providers/exchange_rate_provider.dart';
import '../localization/app_localizations.dart';
import '../screens/qiamuddin_design.dart';

import 'exchange_rate_form_screen.dart';

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() =>
      _ExchangeRateScreenState();
}

class _ExchangeRateScreenState
    extends State<ExchangeRateScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context
            .read<ExchangeRateProvider>()
            .loadExchangeRates();
      },
    );

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ======================================================
  // FILTER
  // ======================================================

  List<ExchangeRateModel> _filteredRates(
    List<ExchangeRateModel> rates,
  ) {
    if (_searchQuery.isEmpty) {
      return rates;
    }

    return rates.where((rate) {
      final from = rate.fromCurrencyName.toLowerCase();
      final fromCode = rate.fromCurrencyCode.toLowerCase();
      final to = rate.toCurrencyName.toLowerCase();
      final toCode = rate.toCurrencyCode.toLowerCase();
      final date = rate.effectiveDate.toLowerCase();

      return from.contains(_searchQuery) ||
          fromCode.contains(_searchQuery) ||
          to.contains(_searchQuery) ||
          toCode.contains(_searchQuery) ||
          date.contains(_searchQuery) ||
          rate.rate.toString().contains(_searchQuery);
    }).toList();
  }

  // ======================================================
  // ADD
  // ======================================================

  Future<void> _addExchangeRate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExchangeRateFormScreen(),
      ),
    );
  }

  // ======================================================
  // EDIT
  // ======================================================

  Future<void> _editExchangeRate(
    ExchangeRateModel exchangeRate,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExchangeRateFormScreen(
          exchangeRate: exchangeRate,
        ),
      ),
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> _deleteExchangeRate(
    ExchangeRateModel exchangeRate,
  ) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_exchange_rate') ??
          "Delete Exchange Rate?",
      content: (loc.getString('delete_exchange_rate_confirm') ??
              "Are you sure you want to delete the exchange rate {from} → {to}?")
          .replaceAll('{from}', exchangeRate.fromCurrencyCode)
          .replaceAll('{to}', exchangeRate.toCurrencyCode),
      cancelText: loc.getString('cancel') ?? "Cancel",
      deleteText: loc.getString('delete') ?? "Delete",
    );

    if (confirmed != true) {
      return;
    }

    final provider = context.read<ExchangeRateProvider>();

    final success = await provider.deleteExchangeRate(
      exchangeRate.exchangeRateId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.getString('exchange_rate_deleted') ??
              "Exchange rate deleted successfully."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                (loc.getString('failed_to_delete_exchange_rate') ??
                    "Failed to delete exchange rate."),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ======================================================
  // REFRESH
  // ======================================================

  Future<void> _refresh() async {
    await context
        .read<ExchangeRateProvider>()
        .loadExchangeRates();
  }

  // ======================================================
  // DETAILS
  // ======================================================

  void _showDetails(
    ExchangeRateModel exchangeRate,
  ) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.getString('exchange_rate_details') ??
              "Exchange Rate Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  loc.getString('id') ?? "ID",
                  exchangeRate.exchangeRateId.toString(),
                ),
                _detailRow(
                  loc.getString('from_currency') ?? "From Currency",
                  "${exchangeRate.fromCurrencyName} "
                      "(${exchangeRate.fromCurrencyCode})",
                ),
                _detailRow(
                  loc.getString('to_currency') ?? "To Currency",
                  "${exchangeRate.toCurrencyName} "
                      "(${exchangeRate.toCurrencyCode})",
                ),
                _detailRow(
                  loc.getString('rate') ?? "Rate",
                  exchangeRate.rate.toString(),
                ),
                _detailRow(
                  loc.getString('effective_date') ?? "Effective Date",
                  exchangeRate.effectiveDate,
                ),
                _detailRow(
                  loc.getString('created_at') ?? "Created At",
                  exchangeRate.createdAt,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(loc.getString('close') ?? "Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final provider = context.watch<ExchangeRateProvider>();
    final rates = _filteredRates(provider.exchangeRates);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.getString('exchange_rates') ?? "Exchange Rates",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            theme.brightness == Brightness.dark
                ? theme.cardColor
                : const Color(0xFF102C4A),
        foregroundColor: Colors.white,
        actions: [
        
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExchangeRate,
        backgroundColor:
            theme.brightness == Brightness.dark
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF102C4A),
        foregroundColor:
            theme.brightness == Brightness.dark ? Colors.black : Colors.white,
        icon: const Icon(Icons.add),
        label: Text(loc.getString('add_rate') ?? "Add Rate"),
      ),
      body: Column(
        children: [
          // ==================================================
          // ✅ FIXED: SEARCH BAR NOW MATCHES OTHER SCREENS
          //    (uses theme.cardColor fill, radius 12, RTL)
          // ==================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              textDirection: Directionality.of(context),
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: loc.getString('search_exchange_rates') ??
                    "Search exchange rates...",
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search_rounded, color: theme.hintColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: Icon(Icons.clear_rounded, color: theme.hintColor),
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,           // ← matches other screens
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ==================================================
          // LOADING
          // ==================================================
          if (provider.isLoading && provider.exchangeRates.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )

          // ==================================================
          // ERROR
          // ==================================================
          else if (provider.errorMessage != null &&
              provider.exchangeRates.isEmpty)
            Expanded(
              child: _ErrorView(
                message: provider.errorMessage!,
                onRetry: _refresh,
              ),
            )

          // ==================================================
          // EMPTY
          // ==================================================
          else if (rates.isEmpty)
            Expanded(
              child: _EmptyView(
                isSearching: _searchQuery.isNotEmpty,
                onAdd: _addExchangeRate,
              ),
            )

          // ==================================================
          // LIST
          // ==================================================
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                  itemCount: rates.length,
                  itemBuilder: (context, index) {
                    final rate = rates[index];

                    return _ExchangeRateCard(
                      exchangeRate: rate,
                      onTap: () {
                        _showDetails(rate);
                      },
                      onEdit: () {
                        _editExchangeRate(rate);
                      },
                      onDelete: () {
                        _deleteExchangeRate(rate);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// EXCHANGE RATE CARD (kept; only translated labels)
// ============================================================

class _ExchangeRateCard extends StatelessWidget {
  final ExchangeRateModel exchangeRate;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExchangeRateCard({
    required this.exchangeRate,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                textDirection: Directionality.of(context),
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exchangeRate.fromCurrencyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          exchangeRate.fromCurrencyCode,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF2E6F95),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          exchangeRate.toCurrencyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          exchangeRate.toCurrencyCode,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              Row(
                textDirection: Directionality.of(context),
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.getString('exchange_rate') ?? "Exchange Rate",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          exchangeRate.rate.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF102C4A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        loc.getString('effective_date') ?? "Effective Date",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        exchangeRate.effectiveDate,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    tooltip: loc.getString('edit') ?? "Edit",
                    icon: const Icon(Icons.edit_rounded, size: 21),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: loc.getString('delete') ?? "Delete",
                    color: Colors.red,
                    icon: const Icon(Icons.delete_outline_rounded, size: 21),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY VIEW
// ============================================================

class _EmptyView extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onAdd;

  const _EmptyView({
    required this.isSearching,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.currency_exchange_rounded,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? (loc.getString('no_exchange_rates_found') ??
                      "No exchange rates found")
                  : (loc.getString('no_exchange_rates_yet') ??
                      "No exchange rates yet"),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (!isSearching)
              Text(
                loc.getString('create_first_exchange_rate') ??
                    "Create your first exchange rate.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            if (!isSearching) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(loc.getString('add_exchange_rate') ??
                    "Add Exchange Rate"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              loc.getString('failed_to_load_exchange_rates') ??
                  "Failed to load exchange rates",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.getString('try_again') ?? "Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}