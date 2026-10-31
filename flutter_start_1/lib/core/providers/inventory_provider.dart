
import 'package:flutter/foundation.dart';

import '../models/inventory_model.dart';
import '../models/inventory_movement_model.dart';
import '../models/inventory_summary_model.dart';
import '../repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository repository;

  InventoryProvider({
    required this.repository,
  });

  List<InventoryModel> _inventory = [];
  List<InventoryModel> _lowStockItems = [];
  List<InventoryMovementModel> _movements = [];
  InventorySummaryModel? _summary;

  bool _isLoading = false;
  String? _errorMessage;

  List<InventoryModel> get inventory => _inventory;
  List<InventoryModel> get lowStockItems => _lowStockItems;
  List<InventoryMovementModel> get movements => _movements;
  InventorySummaryModel? get summary => _summary;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst(
        'Exception: ',
        '',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInventory({
    required String token,
  }) {
    return _run(() async {
      _inventory = await repository.getInventory(
        token: token,
      );
    });
  }

  Future<InventoryModel?> loadInventoryByItem({
    required String token,
    required int itemId,
  }) async {
    InventoryModel? result;

    await _run(() async {
      result = await repository.getInventoryByItem(
        token: token,
        itemId: itemId,
      );
    });

    return result;
  }

  Future<void> loadSummary({
    required String token,
  }) {
    return _run(() async {
      _summary = await repository.getInventorySummary(
        token: token,
      );
    });
  }

  Future<void> loadLowStockItems({
    required String token,
    double threshold = 5,
  }) {
    return _run(() async {
      _lowStockItems = await repository.getLowStockItems(
        token: token,
        threshold: threshold,
      );
    });
  }

  Future<void> loadMovementHistory({
    required String token,
    int? itemId,
    String? movementType,
    String? sourceType,
  }) {
    return _run(() async {
      _movements = await repository.getMovementHistory(
        token: token,
        itemId: itemId,
        movementType: movementType,
        sourceType: sourceType,
      );
    });
  }

  Future<bool> createAdjustment({
    required String token,
    required int itemId,
    required String movementType,
    required double quantity,
  }) async {
    var success = false;

    await _run(() async {
      await repository.createAdjustment(
        token: token,
        itemId: itemId,
        movementType: movementType,
        quantity: quantity,
      );

      success = true;
    });

    return success;
  }

  Future<bool> updateAdjustment({
    required String token,
    required int movementId,
    required int itemId,
    required String movementType,
    required double quantity,
  }) async {
    var success = false;

    await _run(() async {
      await repository.updateAdjustment(
        token: token,
        movementId: movementId,
        itemId: itemId,
        movementType: movementType,
        quantity: quantity,
      );

      success = true;
    });

    return success;
  }

  Future<bool> deleteAdjustment({
    required String token,
    required int movementId,
  }) async {
    var success = false;

    await _run(() async {
      await repository.deleteAdjustment(
        token: token,
        movementId: movementId,
      );

      success = true;
    });

    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
