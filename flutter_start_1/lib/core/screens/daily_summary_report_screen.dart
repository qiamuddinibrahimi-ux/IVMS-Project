import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/report_model.dart';
import '../providers/report_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/report_data_table.dart';

class DailySummaryReportScreen extends StatefulWidget {
  const DailySummaryReportScreen({super.key});

  @override
  State<DailySummaryReportScreen> createState() =>
      _DailySummaryReportScreenState();
}

class _DailySummaryReportScreenState extends State<DailySummaryReportScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportProvider>().loadDailySummary();
      }
    });
  }

  Future<void> _selectDate() async {
    final provider = context.read<ReportProvider>();
    final initial =
        DateTime.tryParse(provider.selectedDailyDate ?? '') ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    final formatted = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    await provider.loadDailySummary(date: formatted);
  }

  List<ReportModel> _records(dynamic value) {
    if (value is! List) return [];

    return value
        .where((item) => item is Map)
        .map((item) => ReportModel.fromAny(item))
        .toList();
  }

  Widget _section(
    ThemeData theme,
    AppLocalizations loc,
    String title,
    List<ReportModel> records,
    List<String> columns,
  ) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${records.length})',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ReportDataTable(
              records: records,
              columns: columns,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('daily_summary') ?? 'Daily Summary',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: loc.getString('select_date') ?? 'Select date',
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            tooltip: loc.getString('refresh_report') ?? 'Refresh',
            onPressed: () => context.read<ReportProvider>().loadDailySummary(
                  date: context.read<ReportProvider>().selectedDailyDate,
                ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          final data = provider.dailySummary;

          final sales = _records(data['sales']);
          final purchases = _records(data['purchases']);
          final customerPayments = _records(data['customer_payments']);
          final vendorPayments = _records(data['vendor_payments']);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // ============================================
              // SUMMARY DATE CARD
              // ============================================
              Card(
                color: theme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.today,
                    color: theme.hintColor,
                  ),
                  title: Text(
                    loc.getString('summary_date') ?? 'Summary date',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    data['date']?.toString() ??
                        provider.selectedDailyDate ??
                        (loc.getString('today') ?? 'Today'),
                    style: TextStyle(color: theme.hintColor),
                  ),
                  trailing: IconButton(
                    onPressed: _selectDate,
                    icon: Icon(
                      Icons.edit_calendar,
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ),

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),

              if (provider.errorMessage != null)
                Card(
                  color: theme.cardColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              _section(
                theme,
                loc,
                loc.getString('sales') ?? 'Sales',
                sales,
                const ['currency_code', 'total_sales'],
              ),
              _section(
                theme,
                loc,
                loc.getString('purchases') ?? 'Purchases',
                purchases,
                const ['currency_code', 'total_purchase'],
              ),
              _section(
                theme,
                loc,
                loc.getString('customer_payments') ?? 'Customer Payments',
                customerPayments,
                const ['currency_code', 'amount'],
              ),
              _section(
                theme,
                loc,
                loc.getString('vendor_payments') ?? 'Vendor Payments',
                vendorPayments,
                const ['currency_code', 'amount'],
              ),
            ],
          );
        },
      ),
    );
  }
}