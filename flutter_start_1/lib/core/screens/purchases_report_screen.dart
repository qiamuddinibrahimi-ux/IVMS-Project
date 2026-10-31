import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class PurchasesReportScreen extends StatelessWidget {
  const PurchasesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('purchases_report') ?? 'Purchases Report',
      dateFilter: true,
      chartAmountField: 'total_purchase',
      columns: const [
        'invoice_no',
        'purchase_date',
        'vendor_name',
        'currency_code',
        'line_count',
        'total_purchase',
      ],
      records: (p) => p.purchases,
      load: (p) => p.loadPurchases(),
    );
  }
}