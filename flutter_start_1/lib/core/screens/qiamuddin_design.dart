import 'package:flutter/material.dart';

class QiamuddinDesign {
  // ============================================================
  // COLORS (single source of truth)
  // ============================================================
  static const Color navyStart = Color(0xFF102C4A);
  static const Color navyEnd = Color(0xFF1E4A7A);
  static const Color gold = Color(0xFFE5C77A);
  static const Color danger = Color(0xFFD32F2F);

  // ============================================================
  // 1. SEARCH BAR
  // ============================================================
  static Widget searchBar({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onClear,
    required bool hasText,
  }) {
    final theme = Theme.of(context);
    final isSmall = MediaQuery.of(context).size.width < 360;
    final radius = isSmall ? 10.0 : 14.0;

    return TextField(
      controller: controller,
      textDirection: Directionality.of(context),
      keyboardType: TextInputType.text,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: isSmall ? 13 : 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: theme.hintColor,
          fontSize: isSmall ? 13 : 15,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: theme.hintColor,
          size: isSmall ? 20 : 24,
        ),
        suffixIcon: hasText
            ? IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.clear_rounded,
                  color: theme.hintColor,
                  size: isSmall ? 20 : 24,
                ),
              )
            : null,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: radius,
        ),
      ),
    );
  }

  // ============================================================
  // 2. ADD ICON BUTTON
  // ============================================================
  static Widget addIconButton({
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: const Icon(Icons.add_circle_outline_rounded),
      ),
    );
  }

  // ============================================================
  // 3. PRIMARY BUTTON
  // ============================================================
  static Widget primaryButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final isSmall = MediaQuery.of(context).size.width < 360;
    final radius = isSmall ? 12.0 : 16.0;

    return SizedBox(
      height: isSmall ? 48 : 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: isLoading ? null : onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.brightness == Brightness.dark
                  ? [const Color(0xFFE0E0E0), const Color(0xFFB0B0B0)]
                  : [navyStart, navyEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: (theme.brightness == Brightness.dark
                        ? Colors.white
                        : navyStart)
                    .withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: isSmall ? 18 : 22,
                    height: isSmall ? 18 : 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: Directionality.of(context),
                    children: [
                      Icon(
                        icon,
                        size: isSmall ? 18 : 22,
                        color: theme.brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 4. DANGER BUTTON
  // ============================================================
  static Widget dangerButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: danger,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  // ============================================================
  // 5. DELETE CONFIRMATION DIALOG
  // ============================================================
  static Future<bool?> deleteConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String cancelText,
    required String deleteText,
  }) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width < 360 ? 14 : 20,
            ),
          ),
          title: Text(
            title,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            content,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: TextStyle(color: theme.hintColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(cancelText, style: TextStyle(color: theme.hintColor)),
            ),
            dangerButton(
              text: deleteText,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // 6. MODERN LIST CARD
  // ============================================================
  static Widget listCard({
    required BuildContext context,
    required ThemeData theme,
    required String avatarText,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    Color avatarBgColor = const Color(0xFF174A7E),
  }) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    final avatarSize = isSmall ? 44.0 : 54.0;

    return Card(
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmall ? 14 : 18),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(isSmall ? 14 : 18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isSmall ? 12.0 : 16.0),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? navyStart
                      : avatarBgColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(isSmall ? 10 : 14),
                ),
                child: Center(
                  child: Text(
                    avatarText,
                    style: TextStyle(
                      fontSize: isSmall ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : avatarBgColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 14 : 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: isSmall ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: isSmall ? 20 : 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 7. ⭐ SEARCHABLE DROPDOWN (FIXED)
  // ------------------------------------------------------------
  // A dropdown whose menu contains a live search field. Good for
  // 20+ items. Keeps the same visual style as the rest of the app.
  //
  // Usage:
  //   QiamuddinDesign.searchableDropdown<Customer>(
  //     context: context,
  //     label: 'Customer',
  //     hintText: 'Select customer',
  //     searchHintText: 'Search customers...',
  //     items: customers,
  //     selectedItem: _selectedCustomer,
  //     itemAsString: (c) => c.name,
  //     onChanged: (c) => setState(() => _selectedCustomer = c),
  //     validator: (c) => c == null ? 'Required' : null,
  //   )
  // ============================================================
  static Widget searchableDropdown<T>({
    required BuildContext context,
    required String label,
    required List<T> items,
    required T? selectedItem,
    required String Function(T item) itemAsString,
    required void Function(T? value) onChanged,
    String? hintText,
    String searchHintText = 'Search...',
    String noResultsText = 'No matches found',
    IconData? prefixIcon,
    String? Function(T?)? validator,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isSmall = MediaQuery.of(context).size.width < 360;

    final displayText =
        selectedItem == null ? '' : itemAsString(selectedItem);

    Future<void> openPicker() async {
      if (!enabled) {
        debugPrint('searchableDropdown: disabled, ignoring tap');
        return;
      }

      debugPrint(
          'searchableDropdown tapped → "$label" (${items.length} items)');

      final picked = await showDialog<T?>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return _SearchablePickerDialog<T>(
            items: items,
            itemAsString: itemAsString,
            searchHintText: searchHintText,
            noResultsText: noResultsText,
            title: label,
            initialSelected: selectedItem,
          );
        },
      );

      debugPrint('searchableDropdown picked: $picked');

      if (picked != null) {
        onChanged(picked);
      }
    }

    final decoration = InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: TextStyle(color: theme.hintColor),
      hintStyle: TextStyle(color: theme.hintColor),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: theme.hintColor),
      suffixIcon: Icon(Icons.arrow_drop_down_rounded,
          color: theme.hintColor),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 14 : 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : navyStart,
          width: 1.4,
        ),
      ),
    );

    // Use a FormField<T> so `validator` behaves like other form inputs.
    // The KEY is what makes this update when `selectedItem` changes.
    return FormField<T>(
      key: ValueKey(
        '${label}_${displayText}_${items.length}',
      ),
      initialValue: selectedItem,
      validator: (value) => validator == null ? null : validator(value),
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? openPicker : null,
          child: InputDecorator(
            decoration: decoration.copyWith(
              errorText: state.errorText,
            ),
            child: Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Expanded(
                  child: Text(
                    displayText.isEmpty
                        ? (hintText ?? '')
                        : displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 15,
                      color: displayText.isEmpty
                          ? theme.hintColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 8. ⭐ EMPTY VIEW
  // ============================================================
  static Widget emptyView({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    String? actionLabel,
    IconData actionIcon = Icons.add_rounded,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 68, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 9. ⭐ ERROR VIEW
  // ============================================================
  static Widget errorView({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    String? title,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 14),
            if (title != null)
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            if (title != null) const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 10. ⭐ SECTION HEADER
  // ============================================================
  static Widget sectionHeader({
    required BuildContext context,
    required String title,
    String? trailingText,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(color: theme.hintColor),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// PRIVATE: SEARCHABLE PICKER DIALOG (FIXED)
// ============================================================
//
// A dialog with a search bar on top and a scrollable list below.
// Live-filters as the user types. RTL-safe. Theme-aware.
//
class _SearchablePickerDialog<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) itemAsString;
  final String searchHintText;
  final String noResultsText;
  final String title;
  final T? initialSelected;

  const _SearchablePickerDialog({
    required this.items,
    required this.itemAsString,
    required this.searchHintText,
    required this.noResultsText,
    required this.title,
    this.initialSelected,
  });

  @override
  State<_SearchablePickerDialog<T>> createState() =>
      _SearchablePickerDialogState<T>();
}

class _SearchablePickerDialogState<T>
    extends State<_SearchablePickerDialog<T>> {
  late final TextEditingController _searchController;
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filtered = List<T>.from(widget.items);

    _searchController.addListener(_onSearchChanged);

    debugPrint(
        'SearchablePickerDialog opened → "${widget.title}" (${widget.items.length} items)');
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();

    setState(() {
      if (q.isEmpty) {
        _filtered = List<T>.from(widget.items);
      } else {
        _filtered = widget.items
            .where((item) =>
                widget.itemAsString(item).toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Compare by value — `identical` fails when the list is rebuilt.
  bool _isSelected(T item) {
    if (widget.initialSelected == null) return false;

    // Prefer string comparison — works even after rebuild.
    return widget.itemAsString(item) ==
        widget.itemAsString(widget.initialSelected as T);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final maxHeight = MediaQuery.of(context).size.height * 0.72;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      contentPadding: EdgeInsets.zero,
      title: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: theme.hintColor),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: maxHeight,
        child: Column(
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textDirection:
                    isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: widget.searchHintText,
                  hintStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: theme.hintColor),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => _searchController.clear(),
                          icon: Icon(Icons.clear_rounded,
                              color: theme.hintColor),
                        ),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 0),
                ),
              ),
            ),

            // --- LIST ---
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          widget.noResultsText,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.25),
                      ),
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        final isSelected = _isSelected(item);

                        return ListTile(
                          title: Text(
                            widget.itemAsString(item),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.green)
                              : null,
                          onTap: () {
                            debugPrint(
                                'SearchablePickerDialog picked: ${widget.itemAsString(item)}');
                            Navigator.pop(context, item);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}