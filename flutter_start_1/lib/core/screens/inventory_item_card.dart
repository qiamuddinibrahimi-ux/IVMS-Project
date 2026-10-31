import 'package:flutter/material.dart';

import '../models/inventory_model.dart';
import '../localization/app_localizations.dart'; // ADDED

class InventoryItemCard extends StatelessWidget {
  final InventoryModel item;
  final VoidCallback? onTap;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final stockColor = item.currentStock <= 0
        ? Colors.red
        : item.currentStock <= 5
            ? Colors.orange
            : Colors.green;

    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: stockColor.withValues(alpha: 0.12),
          child: Icon(
            Icons.inventory_2_outlined,
            color: stockColor,
          ),
        ),
        title: Text(
          item.itemName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((item.categoryName ?? '').isNotEmpty)
                Text(
                  '${loc.getString('category') ?? 'Category'}: '
                  '${item.categoryName}',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
              Text(
                '${loc.getString('unit') ?? 'Unit'}: '
                '${item.unitName ?? (loc.getString('na') ?? 'N/A')}',
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
              if ((item.barcode ?? '').isNotEmpty)
                Text(
                  '${loc.getString('barcode') ?? 'Barcode'}: '
                  '${item.barcode}',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
              const SizedBox(height: 5),
              Text(
                '${loc.getString('stock_in') ?? 'Stock in'}: '
                '${item.totalStockIn}',
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
              Text(
                '${loc.getString('stock_out') ?? 'Stock out'}: '
                '${item.totalStockOut}',
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatStock(item.currentStock),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: stockColor,
              ),
            ),
            Text(
              loc.getString('current_stock') ?? 'Current stock',
              style: TextStyle(
                fontSize: 10,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatStock(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}