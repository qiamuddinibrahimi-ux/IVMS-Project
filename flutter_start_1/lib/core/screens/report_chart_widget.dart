import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../localization/app_localizations.dart'; // ADDED

class ReportChartWidget extends StatelessWidget {
  final List<ReportModel> records;
  final String amountField;
  final String title;
  final String labelField;

  const ReportChartWidget({
    super.key,
    required this.records,
    required this.amountField,
    required this.title,
    this.labelField = 'currency_code',
  });

  Map<String, double> _groupAmounts(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final fallback =
        loc.getString('unknown_currency') ?? 'Unknown currency';

    final totals = <String, double>{};

    for (final record in records) {
      final currency = record.getString(
        labelField,
        fallback: fallback,
      );

      final amount = record.getDouble(amountField);

      if (amount == null || !amount.isFinite) {
        continue;
      }

      totals[currency] = (totals[currency] ?? 0) + amount;
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final isDark = theme.brightness == Brightness.dark;

    final totals = _groupAmounts(context);
    debugPrint('Report chart: $title');
    debugPrint('Amount field: $amountField');
    debugPrint('Number of records: ${records.length}');

    for (final record in records) {
      debugPrint(
        'Currency: ${record.getString('currency_code')} | '
        'Sales: ${record.getString('total_sales', fallback: 'MISSING')} | '
        'Purchases: ${record.getString('total_purchase', fallback: 'MISSING')}',
      );
    }

    debugPrint('Calculated chart totals: $totals');

    final entries = totals.entries.toList();

    final maxAmount = entries.isEmpty
        ? 0.0
        : entries.map((entry) => entry.value.abs()).reduce(math.max);

    final chartMaxY = maxAmount > 0 ? maxAmount * 1.25 : 1.0;
    final interval = chartMaxY / 4;

    final axisColor = theme.hintColor;

    final grandTotal = entries.fold<double>(
      0,
      (prev, e) => prev + e.value,
    );

    const List<Color> barPalette = [
      Color(0xFF2E7D32),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFFE65100),
      Color(0xFF00838F),
      Color(0xFFAD3434),
      Color(0xFF558B2F),
      Color(0xFF3F51B5),
    ];

    int highlightIndex = -1;
    if (entries.isNotEmpty) {
      double best = -1;
      for (int i = 0; i < entries.length; i++) {
        final v = entries[i].value.abs();
        if (v > best) {
          best = v;
          highlightIndex = i;
        }
      }
    }

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.35),
          width: 0.6,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: Directionality.of(context),
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (entries.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      grandTotal.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            if (entries.isEmpty || maxAmount == 0)
              SizedBox(
                height: 140,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        size: 44,
                        color: theme.hintColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.getString('no_non_zero_amounts') ??
                            'No non-zero amounts available to chart.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: chartMaxY,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: interval,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withValues(alpha: 0.35),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 72,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: axisColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= entries.length) {
                              return const SizedBox.shrink();
                            }

                            return SideTitleWidget(
                              meta: meta,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  entries[index].key,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: axisColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      entries.length,
                      (index) {
                        final amount = entries[index].value;
                        final color =
                            barPalette[index % barPalette.length];
                        final isHighlight = index == highlightIndex;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: amount > 0 ? amount : 0,
                              width: 26,
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isHighlight
                                    ? [
                                        color,
                                        color.withValues(alpha: 0.75),
                                      ]
                                    : [
                                        color.withValues(alpha: 0.85),
                                        color.withValues(alpha: 0.55),
                                      ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: chartMaxY,
                                color: theme.dividerColor
                                    .withValues(alpha: 0.10),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (entries.isNotEmpty) ...[
              Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              ...List.generate(entries.length, (index) {
                final entry = entries[index];
                final color = barPalette[index % barPalette.length];
                final isHighlight = index == highlightIndex;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    textDirection: Directionality.of(context),
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isHighlight
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        entry.value.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? color.withValues(alpha: 0.95)
                              : color,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}