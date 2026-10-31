import 'package:flutter/material.dart';

import '../localization/app_localizations.dart'; // ADDED
import 'report_list_screen.dart';

class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return ReportListScreen(
      title: loc.getString('inventory_report') ?? 'Inventory Report',
      columns: const [
        'item_name',
        'category_name',
        'unit_name',
        'total_in',
        'total_out',
        'current_stock',
      ],
      records: (p) => p.inventory,
      load: (p) => p.loadInventory(),
    );
  }
}