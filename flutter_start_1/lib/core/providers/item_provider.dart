import 'package:flutter/foundation.dart';

import '../models/item_model.dart';
import '../repositories/item_repository.dart';

class ItemProvider extends ChangeNotifier {
  final ItemRepository repository;

  ItemProvider({
    required this.repository,
  });

  // ======================================================
  // STATE
  // ======================================================

  List<ItemModel> _items = [];

  bool _isLoading = false;

  String? _errorMessage;

  bool _isLoadingItems = false;

  // ======================================================
  // GETTERS
  // ======================================================

  List<ItemModel> get items => _items;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ======================================================
  // LOADING
  // ======================================================

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }

  // ======================================================
  // LOAD ITEMS
  // ======================================================

  Future<void> loadItems({
    bool forceRefresh = false,
  }) async {
    if (_isLoadingItems) {
      return;
    }

    if (_items.isNotEmpty &&
        !forceRefresh) {
      return;
    }

    _isLoadingItems = true;

    _errorMessage = null;

    _setLoading(true);

    try {
      final items =
          await repository.getItems();

      _items = items;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingItems = false;

      _setLoading(false);
    }
  }

  // ======================================================
  // CREATE
  // ======================================================

  Future<bool> createItem({
    required String itemName,
    required int categoryId,
    required int unitId,
    String? barcode,
    String? description,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final item =
          await repository.createItem(
        itemName: itemName,
        categoryId: categoryId,
        unitId: unitId,
        barcode: barcode,
        description: description,
      );

      _items.insert(0, item);

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<bool> updateItem({
    required int itemId,
    required String itemName,
    required int categoryId,
    required int unitId,
    String? barcode,
    String? description,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final updatedItem =
          await repository.updateItem(
        itemId: itemId,
        itemName: itemName,
        categoryId: categoryId,
        unitId: unitId,
        barcode: barcode,
        description: description,
      );

      final index =
          _items.indexWhere(
        (item) =>
            item.itemId == itemId,
      );

      if (index != -1) {
        _items[index] = updatedItem;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<bool> deleteItem(
    int itemId,
  ) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.deleteItem(
        itemId,
      );

      _items.removeWhere(
        (item) =>
            item.itemId == itemId,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // CLEAR ERROR
  // ======================================================

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }
}