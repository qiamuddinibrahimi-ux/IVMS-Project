import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../localization/app_localizations.dart'; // ADDED

class ReportDataTable extends StatelessWidget {
  final List<ReportModel> records;
  final List<String> columns;
  final String? emptyMessage;

  const ReportDataTable({
    super.key,
    required this.records,
    required this.columns,
    this.emptyMessage,
  });

  String _formatValue(ReportModel record, String key) {
    final value = record.data[key];

    if (value == null) return '—';

    if (value is num) {
      return value.toString();
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final isDark = theme.brightness == Brightness.dark;

    if (records.isEmpty) {
      return Card(
        color: theme.cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 46,
                  color: theme.hintColor,
                ),
                const SizedBox(height: 10),
                Text(
                  emptyMessage ??
                      (loc.getString('no_records_found') ??
                          'No records found.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final headerColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFF102C4A);

    final headerTextColor = isDark ? Colors.white : Colors.white;

    final rowEvenColor = theme.cardColor;
    final rowOddColor = isDark
        ? const Color(0xFF242424)
        : const Color(0xFFF7F9FC);

    final borderColor = theme.dividerColor.withValues(alpha: 0.4);

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Theme(
            data: theme.copyWith(
              dividerColor: Colors.transparent,
            ),
            child: DataTable(
              columnSpacing: 26,
              horizontalMargin: 16,
              headingRowHeight: 48,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 56,
              headingRowColor: WidgetStateProperty.all(headerColor),
              dataRowColor: WidgetStateProperty.resolveWith(
                (states) {
                  final index = records.indexWhere(
                    (r) => r.hashCode == states.hashCode,
                  );
                  return index.isEven ? rowEvenColor : rowOddColor;
                },
              ),
              dividerThickness: 0.4,
              columns: columns
                  .map(
                    (column) => DataColumn(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          column.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.6,
                            color: headerTextColor,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              rows: List.generate(records.length, (i) {
                final record = records[i];
                final isEven = i.isEven;

                return DataRow(
                  color: WidgetStateProperty.all(
                    isEven ? rowEvenColor : rowOddColor,
                  ),
                  cells: columns.map((column) {
                    return DataCell(
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: Text(
                          _formatValue(record, column),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}