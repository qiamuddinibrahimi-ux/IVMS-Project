import 'package:flutter/material.dart';

import '../models/purchase_payment_model.dart';
import '../repositories/purchase_payment_repository.dart';

class PurchasePaymentProvider
    extends ChangeNotifier {
  final PurchasePaymentRepository repository;

  PurchasePaymentProvider({
    required this.repository,
  });

  List<PurchasePaymentModel> _payments = [];

  bool _isLoading = false;
  bool _isLoadingPayments = false;

  String? _errorMessage;

  List<PurchasePaymentModel> get payments =>
      _payments;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

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
  // LOAD
  // ======================================================

  Future<void> loadPurchasePayments({
    bool forceRefresh = false,
  }) async {
    if (_isLoadingPayments) {
      return;
    }

    if (
      _payments.isNotEmpty &&
      !forceRefresh
    ) {
      return;
    }

    _isLoadingPayments = true;
    _errorMessage = null;

    _setLoading(true);

    try {
      final payments =
          await repository.getPurchasePayments();

      _payments = payments;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingPayments = false;
      _setLoading(false);
    }
  }

  // ======================================================
  // CREATE
  // ======================================================

  Future<bool> createPurchasePayment({
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.createPurchasePayment(
        purchaseId: purchaseId,
        vendorId: vendorId,
        currencyId: currencyId,
        amount: amount,
        paymentDate: paymentDate,
      );

      await loadPurchasePayments(
        forceRefresh: true,
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
  // UPDATE
  // ======================================================

  Future<bool> updatePurchasePayment({
    required int paymentId,
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final updated =
          await repository.updatePurchasePayment(
        paymentId: paymentId,
        purchaseId: purchaseId,
        vendorId: vendorId,
        currencyId: currencyId,
        amount: amount,
        paymentDate: paymentDate,
      );

      final index =
          _payments.indexWhere(
        (payment) =>
            payment.paymentId ==
            paymentId,
      );

      if (index != -1) {
        _payments[index] = updated;
      }

      notifyListeners();

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

  Future<bool> deletePurchasePayment(
    int paymentId,
  ) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.deletePurchasePayment(
        paymentId,
      );

      _payments.removeWhere(
        (payment) =>
            payment.paymentId ==
            paymentId,
      );

      notifyListeners();

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
    void clear() {
    _payments.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}