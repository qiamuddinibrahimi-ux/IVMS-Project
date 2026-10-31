import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class ItemSalesReportScreen extends StatelessWidget {
  const ItemSalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('item_sales_report') ?? 'Item Sales Report',
      dateFilter: true,
      chartAmountField: 'total_sales',
      columns: const [
        'item_name',
        'unit_name',
        'currency_code',
        'quantity_sold',
        'total_sales',
      ],
      records: (p) => p.itemSales,
      load: (p) => p.loadItemSales(),
    );
  }
}