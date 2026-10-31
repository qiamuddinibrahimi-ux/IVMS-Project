import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class VendorPaymentsReportScreen extends StatelessWidget {
  const VendorPaymentsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('vendor_payments_report') ?? 'Vendor Payments',
      dateFilter: true,
      chartAmountField: 'amount',
      columns: const [
        'payment_date',
        'vendor_name',
        'invoice_no',
        'currency_code',
        'amount',
      ],
      records: (p) => p.vendorPayments,
      load: (p) => p.loadVendorPayments(),
    );
  }
}