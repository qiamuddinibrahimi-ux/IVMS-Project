import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inventory_movement_model.dart';
import '../providers/inventory_provider.dart';
import '../storage/storage_service.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED

class InventoryAdjustmentScreen extends StatefulWidget {
  final String? token;

  const InventoryAdjustmentScreen({
    super.key,
    this.token,
  });

  @override
  State<InventoryAdjustmentScreen> createState() =>
      _InventoryAdjustmentScreenState();
}

class _InventoryAdjustmentScreenState extends State<InventoryAdjustmentScreen> {
  String? _accessToken;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = widget.token ?? await StorageService.getUserAccessToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _initializing = false;
      });
      return;
    }

    _accessToken = token;

    await context.read<InventoryProvider>().loadInventory(token: token);

    if (!mounted) return;

    await _loadAdjustments();
    if (!mounted) return;

    setState(() => _initializing = false);
  }

  Future<void> _loadAdjustments() async {
    final token = _accessToken;
    if (token == null) return;

    await context.read<InventoryProvider>().loadMovementHistory(
      token: token,
      sourceType: 'ADJUSTMENT',
    );
  }

  Future<void> _openForm({
    InventoryMovementModel? movement,
  }) async {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider = context.read<InventoryProvider>();
    final items = provider.inventory;
    final token = _accessToken;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('auth_token_required') ??
                'Authorization token is required. Please log in.',
          ),
        ),
      );
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.getString('no_items_available') ??
                'No items are available. Create an item first.',
          ),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();

    final quantityController = TextEditingController(
      text: movement == null ? '' : _format(movement.quantity),
    );

    int selectedItemId = items.any(
      (item) => item.itemId == movement?.itemId,
    )
        ? movement!.itemId
        : items.first.itemId;

    String selectedType = movement?.movementType == 'OUT' ? 'OUT' : 'IN';

    bool saving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                backgroundColor: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: Text(
                  movement == null
                      ? (loc.getString('create_adjustment') ??
                          'Create Adjustment')
                      : (loc.getString('edit_adjustment') ??
                          'Edit Adjustment'),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                          value: selectedItemId,
                          isExpanded: true,
                          dropdownColor: theme.cardColor,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: loc.getString('item') ?? 'Item',
                            labelStyle: TextStyle(color: theme.hintColor),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: items.map((item) {
                            return DropdownMenuItem<int>(
                              value: item.itemId,
                              child: Text(
                                item.itemName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      selectedItemId = value;
                                    });
                                  }
                                },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          dropdownColor: theme.cardColor,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                loc.getString('movement_type') ??
                                    'Movement type',
                            labelStyle: TextStyle(color: theme.hintColor),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'IN',
                              child: Text(
                                loc.getString('movement_in') ??
                                    'IN — Add stock',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'OUT',
                              child: Text(
                                loc.getString('movement_out') ??
                                    'OUT — Remove stock',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                          onChanged: saving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      selectedType = value;
                                    });
                                  }
                                },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: quantityController,
                          enabled: !saving,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textDirection: Directionality.of(context),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                loc.getString('quantity') ?? 'Quantity',
                            labelStyle: TextStyle(color: theme.hintColor),
                            hintText: loc.getString('enter_quantity_positive') ??
                                'Enter a quantity greater than zero',
                            hintStyle: TextStyle(color: theme.hintColor),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            final quantity = double.tryParse(
                              value?.trim() ?? '',
                            );

                            if (quantity == null ||
                                !quantity.isFinite ||
                                quantity <= 0) {
                              return loc.getString(
                                      'invalid_quantity_positive') ??
                                  'Enter a valid quantity greater than zero.';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      loc.getString('cancel') ?? 'Cancel',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.brightness == Brightness.dark
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFF102C4A),
                      foregroundColor:
                          theme.brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            final quantity = double.tryParse(
                              quantityController.text.trim(),
                            );

                            if (quantity == null ||
                                !quantity.isFinite ||
                                quantity <= 0) {
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              final bool success;

                              if (movement == null) {
                                success = await provider.createAdjustment(
                                  token: token,
                                  itemId: selectedItemId,
                                  movementType: selectedType,
                                  quantity: quantity,
                                );
                              } else {
                                success = await provider.updateAdjustment(
                                  token: token,
                                  movementId: movement.movementId,
                                  itemId: selectedItemId,
                                  movementType: selectedType,
                                  quantity: quantity,
                                );
                              }

                              if (!mounted || !dialogContext.mounted) {
                                return;
                              }

                              if (!success) {
                                setDialogState(() {
                                  saving = false;
                                });

                                ScaffoldMessenger.of(this.context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.errorMessage ??
                                            (loc.getString(
                                                    'could_not_save_adjustment') ??
                                                'Could not save the adjustment.'),
                                      ),
                                    ),
                                  );

                                return;
                              }

                              Navigator.of(dialogContext).pop();

                              ScaffoldMessenger.of(this.context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      movement == null
                                          ? (loc.getString(
                                                  'adjustment_created') ??
                                              'Adjustment created successfully.')
                                          : (loc.getString(
                                                  'adjustment_updated') ??
                                              'Adjustment updated successfully.'),
                                    ),
                                  ),
                                );

                              await _refreshData();
                            } catch (error, stackTrace) {
                              debugPrint(
                                'Inventory adjustment save error: $error',
                              );
                              debugPrintStack(stackTrace: stackTrace);

                              if (!mounted || !dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger.of(this.context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      (loc.getString(
                                                  'failed_to_save_adjustment') ??
                                              'Failed to save adjustment: {error}')
                                          .replaceAll('{error}', '$error'),
                                    ),
                                    duration: const Duration(seconds: 6),
                                  ),
                                );
                            }
                          },
                    child: saving
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          )
                        : Text(
                            movement == null
                                ? (loc.getString('create') ?? 'Create')
                                : (loc.getString('save') ?? 'Save'),
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      quantityController.dispose();
    }
  }

  Future<void> _deleteAdjustment(InventoryMovementModel movement) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_adjustment') ?? 'Delete Adjustment',
      content: (loc.getString('delete_adjustment_confirm') ??
              'Delete adjustment #{id}? This will change the calculated stock.')
          .replaceAll('{id}', '${movement.movementId}'),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || _accessToken == null) return;

    final provider = context.read<InventoryProvider>();

    final success = await provider.deleteAdjustment(
      token: _accessToken!,
      movementId: movement.movementId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (loc.getString('adjustment_deleted') ??
                  'Adjustment deleted successfully.')
              : (provider.errorMessage ??
                  (loc.getString('could_not_delete_adjustment') ??
                      'Could not delete adjustment.')),
        ),
      ),
    );

    if (success) await _refreshData();
  }

  Future<void> _refreshData() async {
    final token = _accessToken;
    if (token == null) return;

    await context.read<InventoryProvider>().loadInventory(token: token);

    if (!mounted) return;

    await _loadAdjustments();
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
          loc.getString('inventory_adjustments') ?? 'Inventory Adjustments',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: loc.getString('refresh_report') ?? 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF102C4A),
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        onPressed: _initializing || _accessToken == null
            ? null
            : () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(loc.getString('new_adjustment') ?? 'New Adjustment'),
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _accessToken == null
              ? Center(
                  child: Text(
                    loc.getString('auth_token_required') ??
                        'Authorization token is required. Please log in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.hintColor),
                  ),
                )
              : Consumer<InventoryProvider>(
                  builder: (context, provider, _) {
                    final adjustments = provider.movements
                        .where((m) => m.isAdjustment)
                        .toList();

                    if (provider.isLoading && adjustments.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (provider.errorMessage != null &&
                        adjustments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                provider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.hintColor),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _refreshData,
                                child: Text(
                                  loc.getString('retry') ?? 'Retry',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (adjustments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            loc.getString('no_adjustment_records') ??
                                'No adjustment records found.\n'
                                    'Tap New Adjustment to create one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.hintColor),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 90,
                          top: 8,
                        ),
                        itemCount: adjustments.length,
                        itemBuilder: (context, index) {
                          final movement = adjustments[index];

                          return Card(
                            color: theme.cardColor,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: Icon(
                                movement.isStockIn
                                    ? Icons.add_circle_outline
                                    : Icons.remove_circle_outline,
                                color: movement.isStockIn
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              title: Text(
                                movement.itemName,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                (loc.getString('adjustment_id') ??
                                        'Adjustment #{id}')
                                    .replaceAll(
                                        '{id}', '${movement.movementId}') +
                                    '\n${loc.getString('type') ?? 'Type'}: ${movement.movementType}'
                                    '\n${loc.getString('date') ?? 'Date'}: ${movement.createdAt?.toLocal().toString() ?? (loc.getString('na') ?? 'N/A')}',
                                style: TextStyle(color: theme.hintColor),
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: theme.hintColor,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _openForm(movement: movement);
                                  } else if (value == 'delete') {
                                    _deleteAdjustment(movement);
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(
                                      loc.getString('edit') ?? 'Edit',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      loc.getString('delete') ?? 'Delete',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}