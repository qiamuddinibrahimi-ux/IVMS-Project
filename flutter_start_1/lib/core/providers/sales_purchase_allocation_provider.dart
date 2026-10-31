
import 'package:flutter/material.dart';

import '../models/sales_purchase_allocation_model.dart';
import '../repositories/sales_purchase_allocation_repository.dart';

class SalesPurchaseAllocationProvider extends ChangeNotifier {
  final SalesPurchaseAllocationRepository repository;

  SalesPurchaseAllocationProvider(this.repository);

  List<SalesPurchaseAllocationModel> _allocations = [];
  List<SaleDetailOptionModel> _saleDetails = [];
  List<PurchaseDetailOptionModel> _purchaseDetails = [];

  bool _isLoading = false;
  bool _isLoadingOptions = false;
  bool _isSaving = false;

  String? _errorMessage;

  List<SalesPurchaseAllocationModel> get allocations => _allocations;
  List<SaleDetailOptionModel> get saleDetails => _saleDetails;
  List<PurchaseDetailOptionModel> get purchaseDetails => _purchaseDetails;

  bool get isLoading => _isLoading;
  bool get isLoadingOptions => _isLoadingOptions;
  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // LOAD ALLOCATIONS
Future<bool> runAllocation({
  String? fromDate,
  String? toDate,
}) async {
  _isSaving = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final ok = await repository.runAllocation(
      fromDate: fromDate,
      toDate: toDate,
    );
    if (ok) {
      await loadAllocations(forceRefresh: true);
      await loadDetailOptions(forceRefresh: true);
    }
    return ok;
  } catch (e) {
    _errorMessage = _cleanError(e);
    return false;
  } finally {
    _isSaving = false;
    notifyListeners();
  }
}
  Future<void> loadAllocations({
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;

    _errorMessage = null;
    _setLoading(true);

    try {
      _allocations = await repository.getAllocations();
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _setLoading(false);
    }
  }

  // LOAD SALES AND PURCHASE DETAIL OPTIONS

  Future<void> loadDetailOptions({
    bool forceRefresh = false,
  }) async {
    if (_isLoadingOptions) return;

    if (!forceRefresh &&
        _saleDetails.isNotEmpty &&
        _purchaseDetails.isNotEmpty) {
      return;
    }

    _isLoadingOptions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getSaleDetails(),
        repository.getPurchaseDetails(),
      ]);

      _saleDetails = results[0] as List<SaleDetailOptionModel>;
      _purchaseDetails = results[1] as List<PurchaseDetailOptionModel>;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoadingOptions = false;
      notifyListeners();
    }
  }

  // CREATE ALLOCATION

  Future<bool> createAllocation({
    required int saleDetailId,
    required int purchaseDetailId,
    required int itemId,
    required double allocatedQuantity,
  }) async {
    if (!_validateQuantity(allocatedQuantity)) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.createAllocation(
        saleDetailId: saleDetailId,
        purchaseDetailId: purchaseDetailId,
        itemId: itemId,
        allocatedQuantity: allocatedQuantity,
      );

      await _reloadAfterSave();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // UPDATE ALLOCATION

  Future<bool> updateAllocation({
    required int allocationId,
    required int saleDetailId,
    required int purchaseDetailId,
    required int itemId,
    required double allocatedQuantity,
  }) async {
    if (!_validateQuantity(allocatedQuantity)) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateAllocation(
        allocationId: allocationId,
        saleDetailId: saleDetailId,
        purchaseDetailId: purchaseDetailId,
        itemId: itemId,
        allocatedQuantity: allocatedQuantity,
      );

      await _reloadAfterSave();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // DELETE ALLOCATION

  Future<bool> deleteAllocation(int allocationId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteAllocation(allocationId);

      _allocations.removeWhere(
        (allocation) => allocation.allocationId == allocationId,
      );

      await loadDetailOptions(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // REFRESH AFTER CREATE OR UPDATE

  Future<void> _reloadAfterSave() async {
    _allocations = await repository.getAllocations();

    await loadDetailOptions(forceRefresh: true);
  }

  // VALIDATE QUANTITY

  bool _validateQuantity(double quantity) {
    if (!quantity.isFinite || quantity <= 0) {
      _errorMessage = 'Quantity must be greater than zero.';
      notifyListeners();
      return false;
    }

    return true;
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
