import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/report_model.dart';
import '../providers/report_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED
import 'report_chart_widget.dart';
import 'report_data_table.dart';

class ReportListScreen extends StatefulWidget {
  final String title;
  final List<String> columns;
  final List<ReportModel> Function(ReportProvider) records;
  final Future<void> Function(ReportProvider) load;
  final bool dateFilter;
  final String? chartAmountField;
  final String? statusField;
  final List<String>? chartSeries;

  const ReportListScreen({
    super.key,
    required this.title,
    required this.columns,
    required this.records,
    required this.load,
    this.dateFilter = false,
    this.chartAmountField,
    this.statusField,
    this.chartSeries,
  });

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.load(context.read<ReportProvider>());
      }
    });
  }

  Future<void> _chooseDate({required bool isFromDate}) async {
    final provider = context.read<ReportProvider>();
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final current = isFromDate ? provider.fromDate : provider.toDate;

    final initialDate = DateTime.tryParse(current ?? '') ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    final value = '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';

    final from = isFromDate ? value : provider.fromDate;
    final to = isFromDate ? provider.toDate : value;

    if (from != null && to != null && from.compareTo(to) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('start_date_after_end') ?? 'The start date cannot be after the end date.',
          ),
        ),
      );
      return;
    }

    provider.setDateRange(from: from, to: to);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: loc.getString('refresh_report') ?? 'Refresh report',
            onPressed: () => widget.load(context.read<ReportProvider>()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          final records = widget.records(provider);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ============================================
              // DATE FILTER
              // ============================================
              if (widget.dateFilter) ...[
                Text(
                  loc.getString('report_date_range') ?? 'Date range',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _chooseDate(isFromDate: true),
                        icon: Icon(
                          Icons.calendar_today,
                          color: theme.hintColor,
                          size: 16,
                        ),
                        label: Text(
                          provider.fromDate ?? loc.getString('from_date') ?? 'From date',
                          style: TextStyle(color: theme.hintColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _chooseDate(isFromDate: false),
                        icon: Icon(
                          Icons.event,
                          color: theme.hintColor,
                          size: 16,
                        ),
                        label: Text(
                          provider.toDate ?? loc.getString('to_date') ?? 'To date',
                          style: TextStyle(color: theme.hintColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      provider.setDateRange();
                      widget.load(provider);
                    },
                    child: Text(
                      loc.getString('clear_dates') ?? 'Clear dates and reload',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  // ✅ QIAMUDDIN BUTTON
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.brightness == Brightness.dark
                            ? const Color(0xFFE0E0E0)
                            : const Color(0xFF102C4A),
                        foregroundColor: theme.brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => widget.load(provider),
                      child: Text(loc.getString('apply_date_range') ?? 'Apply date range'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ============================================
              // LOADING
              // ============================================
              if (provider.isLoading) const LinearProgressIndicator(),

              // ============================================
              // ERROR
              // ============================================
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => widget.load(provider),
                    icon: Icon(Icons.refresh, color: theme.hintColor),
                    label: Text(
                      loc.getString('retry') ?? 'Try again',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
              ],

              // ============================================
              // CHART
              // ============================================
              if (widget.chartAmountField != null && records.isNotEmpty)
                ReportChartWidget(
                  records: records,
                  amountField: widget.chartAmountField!,
                  title: '${widget.title} by Currency',
                  // seriesFields: widget.chartSeries, // Removed as requested
                ),

              // ============================================
              // STATUS WARNINGS (grouped, friendly)
              // ============================================
              if (widget.statusField != null)
                _buildStatusBanner(records, theme, loc),

              const SizedBox(height: 12),

              // ============================================
              // RECORDS COUNT
              // ============================================
              Text(
                '${loc.getString('records') ?? 'Records'}: ${records.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // ============================================
              // DATA TABLE
              // ============================================
              ReportDataTable(
                records: records,
                columns: widget.columns,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // STATUS BANNER
  // Groups all non-OK statuses into one friendly card.
  // ============================================================

  Widget _buildStatusBanner(
    List<ReportModel> records,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    final field = widget.statusField!;

    // Group by status
    final problematic = <String, int>{};

    for (final record in records) {
      final status = record.getString(field);
      if (status.isEmpty || status == 'OK') continue;
      problematic[status] = (problematic[status] ?? 0) + 1;
    }

    if (problematic.isEmpty) return const SizedBox.shrink();

    String friendlyReason(String status) {
      switch (status) {
        case 'INCOMPLETE_ALLOCATION':
          return loc.getString('reason_incomplete_allocation') ??
              'cost not fully allocated — open Sales/Purchase Allocation and run FIFO allocation.';
        case 'MISSING_EXCHANGE_RATE':
          return loc.getString('reason_missing_exchange_rate') ??
              'no applicable exchange rate — add the missing rate under Exchange Rates.';
        case 'COST_UNAVAILABLE':
          return loc.getString('reason_cost_unavailable') ??
              'cost cannot be computed yet.';
        default:
          return status.toLowerCase().replaceAll('_', ' ');
      }
    }

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: isDark ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.getString('incomplete_data') ?? 'Incomplete data in this report',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.orange.shade200
                        : Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                ...problematic.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '• ${entry.value} ${loc.getString('record') ?? 'record'}'
                      '${entry.value == 1 ? '' : 's'} — '
                      '${friendlyReason(entry.key)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? Colors.orange.shade200
                            : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}