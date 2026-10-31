
import 'package:flutter/foundation.dart';

import '../models/stock_movement_model.dart';
import '../repositories/stock_movement_repository.dart';

class StockMovementProvider extends ChangeNotifier {
  final StockMovementRepository repository;

  StockMovementProvider({
    required this.repository,
  });

  List<StockMovementModel> _movements = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<StockMovementModel> get movements =>
      List.unmodifiable(_movements);

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadMovements({
    String? token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _movements =
          await repository.getStockMovements(
        token: token,
      );
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<StockMovementModel?> loadMovementById({
    required int movementId,
    String? token,
  }) async {
    try {
      _errorMessage = null;

      return await repository.getStockMovementById(
        movementId: movementId,
        token: token,
      );
    } catch (error) {
      _errorMessage = _cleanError(error);
      notifyListeners();
      return null;
    }
  }

  Future<bool> createMovement({
    required int itemId,
    required String movementType,
    required double quantity,
    required String sourceType,
    int? sourceId,
    String? token,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created =
          await repository.createStockMovement(
        itemId: itemId,
        movementType: movementType,
        quantity: quantity,
        sourceType: sourceType,
        sourceId: sourceId,
        token: token,
      );

      _movements = [
        created,
        ..._movements.where(
          (movement) =>
              movement.movementId != created.movementId,
        ),
      ];

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateMovement({
    required int movementId,
    required int itemId,
    required String movementType,
    required double quantity,
    required String sourceType,
    int? sourceId,
    String? token,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated =
          await repository.updateStockMovement(
        movementId: movementId,
        itemId: itemId,
        movementType: movementType,
        quantity: quantity,
        sourceType: sourceType,
        sourceId: sourceId,
        token: token,
      );

      _movements = _movements.map((movement) {
        return movement.movementId == movementId
            ? updated
            : movement;
      }).toList();

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMovement({
    required int movementId,
    String? token,
  }) async {
    _errorMessage = null;

    try {
      await repository.deleteStockMovement(
        movementId: movementId,
        token: token,
      );

      _movements.removeWhere(
        (movement) =>
            movement.movementId == movementId,
      );

      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      notifyListeners();
      return false;
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}
