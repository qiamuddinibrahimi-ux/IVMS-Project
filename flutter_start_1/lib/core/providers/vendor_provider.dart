import 'package:flutter/foundation.dart';

import '../models/vendor_model.dart';
import '../repositories/vendor_repository.dart';

class VendorProvider extends ChangeNotifier {
  final VendorRepository repository;

  VendorProvider({
    required this.repository,
  });

  List<VendorModel> _vendors = [];

  bool _isLoading = false;

  String? _errorMessage;

  bool _isLoadingVendors = false;

  List<VendorModel> get vendors => _vendors;

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
  // LOAD VENDORS
  // ======================================================

  Future<void> loadVendors({
    bool forceRefresh = false,
  }) async {
    if (_isLoadingVendors) return;

    if (_vendors.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingVendors = true;

    _errorMessage = null;

    _setLoading(true);

    try {
      final vendors =
          await repository.getVendors();

      _vendors = vendors;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingVendors = false;

      _setLoading(false);
    }
  }

  // ======================================================
  // CREATE VENDOR
  // ======================================================

  Future<bool> createVendor({
    required String vendorName,
    String? phone,
    String? email,
    String? address,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final vendor =
          await repository.createVendor(
        vendorName: vendorName,
        phone: phone,
        email: email,
        address: address,
      );

      _vendors.insert(0, vendor);

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // UPDATE VENDOR
  // ======================================================

  Future<bool> updateVendor({
    required int vendorId,
    required String vendorName,
    String? phone,
    String? email,
    String? address,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final updatedVendor =
          await repository.updateVendor(
        vendorId: vendorId,
        vendorName: vendorName,
        phone: phone,
        email: email,
        address: address,
      );

      final index = _vendors.indexWhere(
        (vendor) =>
            vendor.vendorId == vendorId,
      );

      if (index != -1) {
        _vendors[index] = updatedVendor;
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
  // DELETE VENDOR
  // ======================================================

  Future<bool> deleteVendor(
    int vendorId,
  ) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.deleteVendor(
        vendorId,
      );

      _vendors.removeWhere(
        (vendor) =>
            vendor.vendorId == vendorId,
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

  void clear() {
    _vendors.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}