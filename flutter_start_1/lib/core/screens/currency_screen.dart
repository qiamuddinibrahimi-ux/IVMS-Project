import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/currency_model.dart';
import '../providers/currency_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import 'currency_form_screen.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text.trim().toLowerCase());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CurrencyProvider>().loadCurrencies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurrencyModel> _filteredCurrencies(List<CurrencyModel> currencies) {
    if (_searchText.isEmpty) return currencies;
    return currencies.where((currency) {
      final name = currency.currencyName.toLowerCase();
      final code = currency.currencyCode.toLowerCase();
      final symbol = currency.symbol.toLowerCase();
      return name.contains(_searchText) || code.contains(_searchText) || symbol.contains(_searchText);
    }).toList();
  }

  Future<void> _openAddCurrency() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyFormScreen()));
  }

  Future<void> _openEditCurrency(CurrencyModel currency) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CurrencyFormScreen(currency: currency)));
  }

  Future<void> _deleteCurrency(CurrencyModel currency) async {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(loc.getString('delete_currency') ?? "Delete Currency", style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Text(
            '${loc.getString('delete_currency_confirm') ?? "Are you sure you want to delete"} "${currency.currencyName}"?',
            style: TextStyle(color: theme.hintColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(loc.getString('cancel') ?? "Cancel", style: TextStyle(color: theme.hintColor)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(loc.getString('delete') ?? "Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<CurrencyProvider>();
    final success = await provider.deleteCurrency(currency.currencyId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.getString('currency_deleted') ?? "Currency deleted successfully.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? loc.getString('could_not_delete') ?? "Unable to delete currency."), backgroundColor: Colors.red.shade700));
    }
  }

  Future<void> _refresh() async {
    await context.read<CurrencyProvider>().loadCurrencies();
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
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: loc.getString('search_currencies') ?? "Search currencies...",
            hintStyle: TextStyle(color: theme.hintColor),
            prefixIcon: Icon(Icons.search_rounded, color: theme.hintColor),
            suffixIcon: _searchText.isNotEmpty
                ? IconButton(
                    onPressed: () => _searchController.clear(),
                    icon: Icon(Icons.clear_rounded, color: theme.hintColor),
                  )
                : null,
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              tooltip: loc.getString('add_currency') ?? "Add Currency",
              onPressed: _openAddCurrency,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ),
        ],
      ),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currencies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.currencies.isEmpty) {
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
                    ElevatedButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh), label: Text(loc.getString('retry') ?? "Try Again")),
                  ],
                ),
              ),
            );
          }

          final currencies = _filteredCurrencies(provider.currencies);

          if (currencies.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Icon(_searchText.isEmpty ? Icons.currency_exchange_rounded : Icons.search_off_rounded, size: 80, color: theme.hintColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _searchText.isEmpty 
                          ? loc.getString('no_currencies') ?? "No currencies yet." 
                          : loc.getString('no_currencies_found') ?? "No currencies found.",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                    ),
                  ),
                  if (_searchText.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(child: Text(loc.getString('tap_add_currency') ?? "Tap + to add your first currency.", style: TextStyle(color: theme.hintColor))),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: currencies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final currency = currencies[index];
                return _CurrencyTile(
                  theme: theme,
                  currency: currency,
                  onTap: () => _openEditCurrency(currency),
                  onDelete: () => _deleteCurrency(currency),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final ThemeData theme;
  final CurrencyModel currency;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CurrencyTile({
    required this.theme,
    required this.currency,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF102C4A)
                      : const Color(0xFF174A7E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    currency.symbol.trim().isNotEmpty ? currency.symbol.trim() : currency.currencyCode.substring(0, 1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF174A7E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.currencyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2C2C2C)
                                : const Color(0xFFE8F0F7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currency.currencyCode,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF174A7E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(currency.symbol, style: TextStyle(fontSize: 14, color: theme.hintColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}