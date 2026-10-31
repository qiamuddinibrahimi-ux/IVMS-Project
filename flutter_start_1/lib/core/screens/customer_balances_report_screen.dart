import 'package:flutter/material.dart';
import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class CustomerBalancesReportScreen extends StatelessWidget {
  const CustomerBalancesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get localization
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('customer_balances') ?? 'Customer Balances', // ✅ Translated Title
      columns: const [
        'customer_name',
        'currency_code',
        'total_sales',
        'total_payments',
        'balance',
        'calculation_status',
      ],
      records: (p) => p.customerBalances,
      load: (p) => p.loadCustomerBalances(),
      statusField: 'calculation_status',
    );
  }
}