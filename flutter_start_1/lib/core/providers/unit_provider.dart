import 'package:flutter/foundation.dart';

import '../models/unit_model.dart';
import '../repositories/unit_repository.dart';

class UnitProvider extends ChangeNotifier {
  final UnitRepository repository;

  UnitProvider({
    required this.repository,
  });

  List<UnitModel> _units = [];

  bool _isLoading = false;

  String? _errorMessage;

  bool _isLoadingUnits = false;

  // ======================================================
  // GETTERS
  // ======================================================

  List<UnitModel> get units => _units;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ======================================================
  // LOADING
  // ======================================================

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;

    notifyListeners();
  }

  // ======================================================
  // LOAD UNITS
  // ======================================================

  Future<void> loadUnits({
    bool forceRefresh = false,
  }) async {
    if (_isLoadingUnits) return;

    // Don't request the API again if data already exists.
    if (_units.isNotEmpty && !forceRefresh) return;

    _isLoadingUnits = true;

    _errorMessage = null;

    _setLoading(true);

    try {
      final units = await repository.getUnits();

      _units = units;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingUnits = false;

      _setLoading(false);
    }
  }

  // ======================================================
  // CREATE UNIT
  // ======================================================

  Future<bool> createUnit({
    required String unitName,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final unit = await repository.createUnit(
        unitName: unitName,
      );

      // Add newest unit at the beginning.
      _units.insert(0, unit);

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // UPDATE UNIT
  // ======================================================

  Future<bool> updateUnit({
    required int unitId,
    required String unitName,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final updatedUnit = await repository.updateUnit(
        unitId: unitId,
        unitName: unitName,
      );

      final index = _units.indexWhere(
        (unit) => unit.unitId == unitId,
      );

      if (index != -1) {
        _units[index] = updatedUnit;
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
  // DELETE UNIT
  // ======================================================

  Future<bool> deleteUnit(int unitId) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.deleteUnit(unitId);

      _units.removeWhere(
        (unit) => unit.unitId == unitId,
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
    _units.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}