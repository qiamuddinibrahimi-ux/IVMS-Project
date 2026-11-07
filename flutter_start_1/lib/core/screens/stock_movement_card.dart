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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // ============================================
              // LEADING ICON
              // ============================================
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(
                  isIn ? Icons.south_west : Icons.north_east,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // ============================================
              // TITLE + SUBTITLE
              // ============================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
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
                    const SizedBox(height: 4),
                    Text(
                      '${movement.movementType} • ${movement.sourceType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${loc.getString('id') ?? 'ID'}: ${movement.movementId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ============================================
              // TRAILING: QUANTITY + ACTIONS
              // ============================================
              Column(
                crossAxisAlignment: isRtl
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movement.quantity.toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            tooltip: loc.getString('edit') ?? 'Edit',
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: onEdit,
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      if (onDelete != null)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            tooltip: loc.getString('delete') ?? 'Delete',
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
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