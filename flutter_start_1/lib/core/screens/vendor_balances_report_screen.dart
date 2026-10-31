import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class VendorBalancesReportScreen extends StatelessWidget {
  const VendorBalancesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('vendor_balances_report') ?? 'Vendor Balances',
      columns: const [
        'vendor_name',
        'currency_code',
        'total_purchases',
        'total_payments',
        'balance',
        'calculation_status',
      ],
      records: (p) => p.vendorBalances,
      load: (p) => p.loadVendorBalances(),
      statusField: 'calculation_status',
    );
  }
}