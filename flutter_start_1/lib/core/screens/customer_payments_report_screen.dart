import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class CustomerPaymentsReportScreen extends StatelessWidget {
  const CustomerPaymentsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('customer_payments_report') ?? 'Customer Payments',
      dateFilter: true,
      chartAmountField: 'amount',
      columns: const [
        'payment_date',
        'customer_name',
        'invoice_no',
        'currency_code',
        'amount',
      ],
      records: (p) => p.customerPayments,
      load: (p) => p.loadCustomerPayments(),
    );
  }
}