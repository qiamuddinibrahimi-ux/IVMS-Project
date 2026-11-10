import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository repository;

  CustomerProvider({
    required this.repository,
  });

  // ======================================================
  // STATE
  // ======================================================

  List<CustomerModel> _customers = [];

  bool _isLoading = false;

  String? _errorMessage;

  // ======================================================
  // GETTERS
  // ======================================================

  List<CustomerModel> get customers => _customers;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ======================================================
  // SET LOADING
  // ======================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ======================================================
  // LOAD CUSTOMERS
  // ======================================================

  Future<void> loadCustomers() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _customers = await repository.getCustomers();
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
  // CREATE CUSTOMER
  // ======================================================

  Future<bool> createCustomer({
    required String customerName,
    required String phone,
    required String email,
    required String address,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      final customer =
          await repository.createCustomer(
        customerName: customerName,
        phone: phone,
        email: email,
        address: address,
      );

      _customers.insert(0, customer);

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
  // UPDATE CUSTOMER
  // ======================================================

  Future<bool> updateCustomer({
    required int customerId,
    required String customerName,
    required String phone,
    required String email,
    required String address,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      final updatedCustomer =
          await repository.updateCustomer(
        customerId: customerId,
        customerName: customerName,
        phone: phone,
        email: email,
        address: address,
      );

      final index = _customers.indexWhere(
        (customer) =>
            customer.customerId == customerId,
      );

      if (index != -1) {
        _customers[index] = updatedCustomer;
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
  // DELETE CUSTOMER
  // ======================================================

  Future<bool> deleteCustomer(
    int customerId,
  ) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      await repository.deleteCustomer(
        customerId,
      );

      _customers.removeWhere(
        (customer) =>
            customer.customerId == customerId,
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
  _customers.clear();
  _errorMessage = null;
  _isLoading = false;
  notifyListeners();
}
}