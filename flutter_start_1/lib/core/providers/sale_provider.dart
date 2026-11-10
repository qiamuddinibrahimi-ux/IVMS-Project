import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../repositories/sale_repository.dart';

class SaleProvider extends ChangeNotifier {
  final SaleRepository repository;

  SaleProvider({
    required this.repository,
  });

  // ======================================================
  // STATE
  // ======================================================

  List<SaleModel> _sales = [];

  bool _isLoading = false;

  bool _isLoadingSales = false;

  String? _errorMessage;

  // ======================================================
  // GETTERS
  // ======================================================

  List<SaleModel> get sales => _sales;

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
  // LOAD SALES
  // ======================================================

  Future<void> loadSales({
    bool forceRefresh = false,
  }) async {
    if (_isLoadingSales) {
      return;
    }

    if (_sales.isNotEmpty &&
        !forceRefresh) {
      return;
    }

    _isLoadingSales = true;

    _errorMessage = null;

    _setLoading(true);

    try {
      final sales =
          await repository.getSales();

      _sales = sales;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingSales = false;

      _setLoading(false);
    }
  }

  // ======================================================
  // CREATE
  // ======================================================

  Future<bool> createSale({
    required int customerId,
    required int currencyId,
    required String saleDate,
    required String invoiceNo,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.createSale(
        customerId: customerId,
        currencyId: currencyId,
        saleDate: saleDate,
        invoiceNo: invoiceNo,
      );

      // Reload because backend returns only sale_id.
      await _reloadSales();

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

  Future<bool> updateSale({
    required int saleId,
    required int customerId,
    required int currencyId,
    required String saleDate,
    required String invoiceNo,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final updatedSale =
          await repository.updateSale(
        saleId: saleId,
        customerId: customerId,
        currencyId: currencyId,
        saleDate: saleDate,
        invoiceNo: invoiceNo,
      );

      final index =
          _sales.indexWhere(
        (sale) =>
            sale.saleId == saleId,
      );

      if (index != -1) {
        _sales[index] = updatedSale;
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

  Future<bool> deleteSale(
    int saleId,
  ) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.deleteSale(
        saleId,
      );

      _sales.removeWhere(
        (sale) =>
            sale.saleId == saleId,
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
  // RELOAD
  // ======================================================

  Future<void> _reloadSales() async {
    final sales =
        await repository.getSales();

    _sales = sales;
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

  void clear() {
  _sales.clear();
  _errorMessage = null;
  _isLoading = false;
  notifyListeners();
}
}