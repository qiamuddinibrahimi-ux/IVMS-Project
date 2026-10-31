import 'package:flutter/material.dart';

import '../models/stock_movement_model.dart';
import '../localization/app_localizations.dart'; // ADDED

class StockMovementDetailsScreen extends StatelessWidget {
  final StockMovementModel movement;

  const StockMovementDetailsScreen({
    super.key,
    required this.movement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final isIn = movement.isStockIn;
    final color = isIn ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('stock_movement_details') ??
              'Stock Movement Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.cardColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(
                      isIn ? Icons.south_west : Icons.north_east,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movement.movementType,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.quantity.toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    loc.getString('movement_quantity') ??
                        'Movement quantity',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _detail(theme, loc.getString('movement_id') ?? 'Movement ID',
              movement.movementId),
          _detail(theme, loc.getString('item') ?? 'Item', movement.itemName),
          _detail(theme, loc.getString('item_id') ?? 'Item ID',
              movement.itemId),
          _detail(theme, loc.getString('movement_type') ?? 'Movement type',
              movement.movementType),
          _detail(theme, loc.getString('quantity_short') ?? 'Quantity',
              movement.quantity),
          _detail(theme, loc.getString('source_type') ?? 'Source type',
              movement.sourceType),
          _detail(
            theme,
            loc.getString('source_id') ?? 'Source ID',
            movement.sourceId?.toString() ??
                (loc.getString('source_not_specified') ?? 'Not specified'),
          ),
          _detail(
            theme,
            loc.getString('created_at') ?? 'Created at',
            movement.createdAt ??
                (loc.getString('source_not_available') ?? 'Not available'),
          ),
        ],
      ),
    );
  }

  Widget _detail(ThemeData theme, String label, Object value) {
    return Card(
      color: theme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.hintColor,
          ),
        ),
        subtitle: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}