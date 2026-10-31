import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('sales_report_title') ?? 'Sales Report',
      dateFilter: true,
      chartAmountField: 'total_sales',
      columns: const [
        'invoice_no',
        'sale_date',
        'customer_name',
        'currency_code',
        'line_count',
        'total_sales',
      ],
      records: (p) => p.sales,
      load: (p) => p.loadSales(),
    );
  }
}