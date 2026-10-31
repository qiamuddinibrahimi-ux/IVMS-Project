import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class ItemPurchasesReportScreen extends StatelessWidget {
  const ItemPurchasesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('item_purchases_report') ??
          'Item Purchases Report',
      dateFilter: true,
      chartAmountField: 'total_purchase',
      columns: const [
        'item_name',
        'unit_name',
        'currency_code',
        'quantity_purchased',
        'total_purchase',
      ],
      records: (p) => p.itemPurchases,
      load: (p) => p.loadItemPurchases(),
    );
  }
}