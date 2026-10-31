import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sales_purchase_allocation_model.dart';
import '../providers/sales_purchase_allocation_provider.dart';
import '../localization/app_localizations.dart'; // ADDED
import '../screens/qiamuddin_design.dart'; // ADDED
import 'sales_purchase_allocation_form.dart';

class SalesPurchaseAllocationScreen extends StatefulWidget {
  const SalesPurchaseAllocationScreen({super.key});

  @override
  State<SalesPurchaseAllocationScreen> createState() =>
      _SalesPurchaseAllocationScreenState();
}

class _SalesPurchaseAllocationScreenState
    extends State<SalesPurchaseAllocationScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider =
          context.read<SalesPurchaseAllocationProvider>();

      provider.loadAllocations();
      provider.loadDetailOptions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  List<SalesPurchaseAllocationModel> _filteredAllocations(
    List<SalesPurchaseAllocationModel> allocations,
  ) {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) return allocations;

    return allocations.where((allocation) {
      return allocation.itemName.toLowerCase().contains(query) ||
          allocation.saleInvoiceNo.toLowerCase().contains(query) ||
          allocation.purchaseInvoiceNo.toLowerCase().contains(query) ||
          allocation.allocationId.toString().contains(query);
    }).toList();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _runAllocation(
    SalesPurchaseAllocationProvider provider,
  ) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
            loc.getString('run_fifo_allocation') ?? 'Run FIFO Allocation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.getString('allocation_run_confirm') ??
                  'This will match every unallocated sale line to the '
                      'oldest available purchase lines. Existing allocations '
                      'in the chosen date range will be replaced.',
            ),
            const SizedBox(height: 14),
            Row(
              textDirection: Directionality.of(context),
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(dialogContext, false);
                      await _pickDate(isFrom: true);
                      if (!mounted) return;
                      _runAllocation(provider);
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _fromDate == null
                          ? (loc.getString('from_date') ?? 'From date')
                          : _fmtDate(_fromDate!),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(dialogContext, false);
                      await _pickDate(isFrom: false);
                      if (!mounted) return;
                      _runAllocation(provider);
                    },
                    icon: const Icon(Icons.event, size: 16),
                    label: Text(
                      _toDate == null
                          ? (loc.getString('to_date') ?? 'To date')
                          : _fmtDate(_toDate!),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _fromDate == null && _toDate == null
                  ? (loc.getString('no_range_selected_all_sales') ??
                      'No range selected — all sales will be processed.')
                  : (loc.getString('range_label') ??
                          'Range: {from} → {to}')
                      .replaceAll(
                          '{from}',
                          _fromDate == null
                              ? '…'
                              : _fmtDate(_fromDate!))
                      .replaceAll(
                          '{to}',
                          _toDate == null
                              ? '…'
                              : _fmtDate(_toDate!)),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(loc.getString('cancel') ?? 'Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: () => Navigator.pop(dialogContext, true),
            label: Text(
                loc.getString('run_allocation') ?? 'Run Allocation'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await provider.runAllocation(
      fromDate: _fromDate == null ? null : _fmtDate(_fromDate!),
      toDate: _toDate == null ? null : _fmtDate(_toDate!),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (loc.getString('allocation_completed') ??
                  'Allocation completed. Allocations refreshed.')
              : (provider.errorMessage ??
                  (loc.getString('allocation_failed') ??
                      'Allocation failed.')),
        ),
      ),
    );
  }

  Future<void> _openForm({
    SalesPurchaseAllocationModel? allocation,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalesPurchaseAllocationFormScreen(
          allocation: allocation,
        ),
      ),
    );

    if (!mounted) return;

    await context
        .read<SalesPurchaseAllocationProvider>()
        .loadAllocations(forceRefresh: true);
  }

  Future<void> _deleteAllocation(
    SalesPurchaseAllocationModel allocation,
  ) async {
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    // ✅ QIAMUDDIN DELETE DIALOG
    final confirmed = await QiamuddinDesign.deleteConfirmationDialog(
      context: context,
      title: loc.getString('delete_allocation') ?? 'Delete Allocation',
      content: (loc.getString('delete_allocation_confirm') ??
              'Delete allocation #{id} for {item}?')
          .replaceAll('{id}', '${allocation.allocationId}')
          .replaceAll('{item}', allocation.itemName),
      cancelText: loc.getString('cancel') ?? 'Cancel',
      deleteText: loc.getString('delete') ?? 'Delete',
    );

    if (confirmed != true || !mounted) return;

    final provider =
        context.read<SalesPurchaseAllocationProvider>();

    final success = await provider.deleteAllocation(
      allocation.allocationId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (loc.getString('allocation_deleted') ??
                  'Allocation deleted successfully.')
              : (provider.errorMessage ??
                  (loc.getString('failed_to_delete_allocation') ??
                      'Failed to delete allocation.')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final provider =
        context.watch<SalesPurchaseAllocationProvider>();

    final allocations =
        _filteredAllocations(provider.allocations);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('sales_purchase_allocations') ??
              'Sales-Purchase Allocations',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip:
                loc.getString('run_fifo_allocation') ?? 'Run FIFO Allocation',
            onPressed: provider.isSaving
                ? null
                : () => _runAllocation(provider),
            icon: provider.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_fix_high_rounded),
          ),
          IconButton(
            tooltip: loc.getString('refresh_report') ?? 'Refresh',
            onPressed: provider.isLoading
                ? null
                : () async {
                    await provider.loadAllocations(
                      forceRefresh: true,
                    );
                    await provider.loadDetailOptions(
                      forceRefresh: true,
                    );
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_fromDate != null || _toDate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                textDirection: Directionality.of(context),
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2C2C2C)
                            : Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        textDirection: Directionality.of(context),
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 16,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (loc.getString('next_run_range') ??
                                      'Next run range: {from} → {to}')
                                  .replaceAll(
                                      '{from}',
                                      _fromDate == null
                                          ? '…'
                                          : _fmtDate(_fromDate!))
                                  .replaceAll(
                                      '{to}',
                                      _toDate == null
                                          ? '…'
                                          : _fmtDate(_toDate!)),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _fromDate = null;
                                _toDate = null;
                              });
                            },
                            child: Text(
                                loc.getString('clear_range') ?? 'Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textDirection: Directionality.of(context),
              keyboardType: TextInputType.text,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: loc.getString('search_allocations_hint') ??
                    'Search invoice, item or allocation ID...',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
              },
            ),
          ),

          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: theme.brightness == Brightness.dark
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    textDirection: Directionality.of(context),
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        onPressed: provider.clearError,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Expanded(
            child: provider.isLoading && provider.allocations.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : allocations.isEmpty
                    ? _buildEmpty(provider)
                    : RefreshIndicator(
                        onRefresh: () => provider.loadAllocations(
                          forceRefresh: true,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            90,
                          ),
                          itemCount: allocations.length,
                          itemBuilder: (context, index) {
                            return _buildCard(allocations[index]);
                          },
                        ),
                      ),
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
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(
            loc.getString('new_allocation') ?? 'New Allocation'),
      ),
    );
  }

  Widget _buildCard(
    SalesPurchaseAllocationModel allocation,
  ) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    return Card(
      color: theme.cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: Directionality.of(context),
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF102C4A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    allocation.itemName.isEmpty
                        ? (loc.getString('item_num') ?? 'Item #{id}')
                            .replaceAll('{id}', '${allocation.itemId}')
                        : allocation.itemName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openForm(allocation: allocation);
                    } else if (value == 'delete') {
                      _deleteAllocation(allocation);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(loc.getString('edit') ?? 'Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(loc.getString('delete') ?? 'Delete'),
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: theme.dividerColor),
            _infoRow(
              theme,
              loc.getString('allocation_id') ?? 'Allocation ID',
              allocation.allocationId.toString(),
            ),
            _infoRow(
              theme,
              loc.getString('sale_invoice') ?? 'Sale Invoice',
              allocation.saleInvoiceNo.isEmpty
                  ? (loc.getString('sale_num_short') ?? 'Sale #{id}')
                      .replaceAll('{id}', '${allocation.saleId ?? '-'}')
                  : allocation.saleInvoiceNo,
            ),
            _infoRow(
              theme,
              loc.getString('purchase_invoice') ?? 'Purchase Invoice',
              allocation.purchaseInvoiceNo.isEmpty
                  ? (loc.getString('purchase_num_short') ?? 'Purchase #{id}')
                      .replaceAll('{id}', '${allocation.purchaseId ?? '-'}')
                  : allocation.purchaseInvoiceNo,
            ),
            _infoRow(
              theme,
              loc.getString('allocated_quantity_short') ??
                  'Allocated Quantity',
              _formatQuantity(allocation.allocatedQuantity),
              bold: true,
            ),
            _infoRow(
              theme,
              loc.getString('sale_quantity') ?? 'Sale Quantity',
              _formatQuantity(allocation.saleQuantity),
            ),
            _infoRow(
              theme,
              loc.getString('purchase_quantity') ?? 'Purchase Quantity',
              _formatQuantity(allocation.purchaseQuantity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    ThemeData theme,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              '$label:',
              style: TextStyle(
                color: theme.hintColor,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(
    SalesPurchaseAllocationProvider provider,
  ) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    if (provider.errorMessage != null &&
        provider.allocations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                loc.getString('could_not_load_allocations') ??
                    'Could not load allocations.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => provider.loadAllocations(
                  forceRefresh: true,
                ),
                child: Text(loc.getString('retry') ?? 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 64,
              color: theme.hintColor,
            ),
            const SizedBox(height: 12),
            Text(
              _searchText.isEmpty
                  ? (loc.getString('no_allocations_found') ??
                      'No allocations found.')
                  : (loc.getString('no_matching_allocations') ??
                      'No matching allocations found.'),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            if (_searchText.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  loc.getString('run_fifo_hint') ??
                      'Tap the auto-fix icon in the top bar to run FIFO '
                          'allocation across your sales and purchases.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.hintColor),
                ),
              ),
            const SizedBox(height: 16),
            if (_searchText.isEmpty)
              ElevatedButton.icon(
                onPressed: provider.isSaving
                    ? null
                    : () => _runAllocation(provider),
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: Text(loc.getString('run_fifo_allocation') ??
                    'Run FIFO Allocation'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatQuantity(double value) {
    return value.toStringAsFixed(4)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }
}