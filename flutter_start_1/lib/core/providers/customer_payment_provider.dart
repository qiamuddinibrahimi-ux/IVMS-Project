import 'package:flutter/foundation.dart';

import '../models/customer_payment_model.dart';
import '../repositories/customer_payment_repository.dart';

class CustomerPaymentProvider
    extends ChangeNotifier {
  final CustomerPaymentRepository repository;

  CustomerPaymentProvider({
    required this.repository,
  });

  // ======================================================
  // STATE
  // ======================================================

  List<CustomerPaymentModel> _payments = [];

  bool _isLoading = false;

  String? _errorMessage;

  // ======================================================
  // GETTERS
  // ======================================================

  List<CustomerPaymentModel> get payments =>
      _payments;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

  // ======================================================
  // LOADING
  // ======================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ======================================================
  // LOAD PAYMENTS
  // ======================================================

  Future<void> loadCustomerPayments() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _payments =
          await repository.getCustomerPayments();
    } catch (error) {
      _errorMessage =
          error.toString().replaceFirst(
                "Exception: ",
                "",
              );
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // GET PAYMENT BY ID
  // ======================================================

  Future<CustomerPaymentModel?>
      getCustomerPaymentById(
    int paymentId,
  ) async {
    try {
      return await repository
          .getCustomerPaymentById(
        paymentId,
      );
    } catch (error) {
      _errorMessage =
          error.toString().replaceFirst(
                "Exception: ",
                "",
              );

      notifyListeners();

      return null;
    }
  }

  // ======================================================
  // CREATE
  // ======================================================

  Future<bool> createCustomerPayment({
    required int customerId,
    required int saleId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      final payment =
          await repository
              .createCustomerPayment(
        customerId: customerId,
        saleId: saleId,
        currencyId: currencyId,
        amount: amount,
        paymentDate: paymentDate,
      );

      _payments.insert(
        0,
        payment,
      );

      return true;
    } catch (error) {
      _errorMessage =
          error.toString().replaceFirst(
                "Exception: ",
                "",
              );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<bool> updateCustomerPayment({
    required int paymentId,
    required int customerId,
    required int saleId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      final updatedPayment =
          await repository
              .updateCustomerPayment(
        paymentId: paymentId,
        customerId: customerId,
        saleId: saleId,
        currencyId: currencyId,
        amount: amount,
        paymentDate: paymentDate,
      );

      final index =
          _payments.indexWhere(
        (payment) =>
            payment.customerPaymentId ==
            paymentId,
      );

      if (index != -1) {
        _payments[index] =
            updatedPayment;
      }

      return true;
    } catch (error) {
      _errorMessage =
          error.toString().replaceFirst(
                "Exception: ",
                "",
              );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<bool> deleteCustomerPayment(
    int paymentId,
  ) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      await repository
          .deleteCustomerPayment(
        paymentId,
      );

      _payments.removeWhere(
        (payment) =>
            payment.customerPaymentId ==
            paymentId,
      );

      return true;
    } catch (error) {
      _errorMessage =
          error.toString().replaceFirst(
                "Exception: ",
                "",
              );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // CLEAR ERROR
  // ======================================================

  void clearError() {
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