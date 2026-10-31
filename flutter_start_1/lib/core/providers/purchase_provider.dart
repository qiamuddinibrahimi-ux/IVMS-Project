import 'package:flutter/foundation.dart';

import '../models/purchase_model.dart';
import '../repositories/purchase_repository.dart';

class PurchaseProvider extends ChangeNotifier {
  final PurchaseRepository repository;

  PurchaseProvider({
    required this.repository,
  });

  List<PurchaseModel> _purchases = [];

  bool _isLoading = false;

  String? _errorMessage;

  bool _isLoadingPurchases = false;

  List<PurchaseModel> get purchases => _purchases;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ======================================================
  // SET LOADING
  // ======================================================

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }

  // ======================================================
  // LOAD PURCHASES
  // ======================================================

  Future<void> loadPurchases({
    bool forceRefresh = false,
  }) async {
    if (_isLoadingPurchases) return;

    if (_purchases.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingPurchases = true;

    _errorMessage = null;

    _setLoading(true);

    try {
      final purchases =
          await repository.getPurchases();

      _purchases = purchases;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingPurchases = false;

      _setLoading(false);
    }
  }

  // ======================================================
  // CREATE PURCHASE
  // ======================================================

  Future<bool> createPurchase({
    required int vendorId,
    required int currencyId,
    required String purchaseDate,
    required String invoiceNo,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final purchase =
          await repository.createPurchase(
        vendorId: vendorId,
        currencyId: currencyId,
        purchaseDate: purchaseDate,
        invoiceNo: invoiceNo,
      );

      _purchases.insert(0, purchase);

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // UPDATE PURCHASE
  // ======================================================

  Future<bool> updatePurchase({
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required String purchaseDate,
    required String invoiceNo,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final updatedPurchase =
          await repository.updatePurchase(
        purchaseId: purchaseId,
        vendorId: vendorId,
        currencyId: currencyId,
        purchaseDate: purchaseDate,
        invoiceNo: invoiceNo,
      );

      final index = _purchases.indexWhere(
        (purchase) =>
            purchase.purchaseId == purchaseId,
      );

      if (index != -1) {
        _purchases[index] = updatedPurchase;
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
  // DELETE PURCHASE
  // ======================================================

  Future<bool> deletePurchase(
    int purchaseId,
  ) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.deletePurchase(
        purchaseId,
      );

      _purchases.removeWhere(
        (purchase) =>
            purchase.purchaseId == purchaseId,
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
    if (_errorMessage == null) return;

    _errorMessage = null;

    notifyListeners();
  }
}