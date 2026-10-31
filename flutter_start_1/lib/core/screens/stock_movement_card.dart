import 'package:flutter/material.dart';

import '../models/stock_movement_model.dart';
import '../localization/app_localizations.dart'; // ADDED

class StockMovementCard extends StatelessWidget {
  final StockMovementModel movement;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StockMovementCard({
    super.key,
    required this.movement,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final isIn = movement.isStockIn;
    final color = isIn ? Colors.green : Colors.red;

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
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isIn ? Icons.south_west : Icons.north_east,
            color: color,
          ),
        ),
        title: Text(
          movement.itemName.isEmpty
              ? (loc.getString('item_num') ?? 'Item #{id}')
                  .replaceAll('{id}', '${movement.itemId}')
              : movement.itemName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${movement.movementType} • '
          '${movement.sourceType}\n'
          '${loc.getString('id') ?? 'ID'}: ${movement.movementId}',
          style: TextStyle(color: theme.hintColor),
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                movement.quantity.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButton(
                      tooltip: loc.getString('edit') ?? 'Edit',
                      visualDensity: VisualDensity.compact,
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: theme.hintColor,
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: loc.getString('delete') ?? 'Delete',
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}