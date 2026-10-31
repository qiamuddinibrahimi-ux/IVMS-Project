import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class ProfitReportScreen extends StatelessWidget {
  const ProfitReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('gross_profit_report') ?? 'Gross Profit Report',
      dateFilter: true,
      chartAmountField: 'gross_profit',
      chartSeries: const [
        'revenue',
        'allocated_cost',
        'gross_profit',
      ],
      columns: const [
        'item_name',
        'currency_code',
        'quantity_sold',
        'revenue',
        'allocated_quantity',
        'allocated_cost',
        'gross_profit',
        'calculation_status',
      ],
      records: (p) => p.profits,
      load: (p) => p.loadProfit(),
      statusField: 'calculation_status',
    );
  }
}