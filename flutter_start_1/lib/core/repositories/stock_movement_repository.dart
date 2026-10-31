
import '../models/stock_movement_model.dart';
import '../services/stock_movement_service.dart';

class StockMovementRepository {
  final StockMovementService stockMovementService;

  StockMovementRepository({
    required this.stockMovementService,
  });

  // GET ALL
  Future<List<StockMovementModel>> getStockMovements({
    String? token,
  }) async {
    final response =
        await stockMovementService.getStockMovements(
      token: token,
    );

    final data = response['data'];

    if (data is! List) {
      throw Exception(
        'Invalid stock movements response.',
      );
    }

    return data
        .map(
          (json) => StockMovementModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  // GET BY ID
  Future<StockMovementModel> getStockMovementById({
    required int movementId,
    String? token,
  }) async {
    final response =
        await stockMovementService.getStockMovementById(
      movementId: movementId,
      token: token,
    );

    final data = response['data'];

    if (data is! Map) {
      throw Exception(
        'Invalid stock movement details response.',
      );
    }

    return StockMovementModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // CREATE
  Future<StockMovementModel> createStockMovement({
    required int itemId,
    required String movementType,
    required double quantity,
    required String sourceType,
    int? sourceId,
    String? token,
  }) async {
    final response =
        await stockMovementService.createStockMovement(
      itemId: itemId,
      movementType: movementType,
      quantity: quantity,
      sourceType: sourceType,
      sourceId: sourceId,
      token: token,
    );

    final data = response['data'];

    if (data is! Map) {
      throw Exception(
        'Created movement was not returned by the server.',
      );
    }

    return StockMovementModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // UPDATE
  Future<StockMovementModel> updateStockMovement({
    required int movementId,
    required int itemId,
    required String movementType,
    required double quantity,
    required String sourceType,
    int? sourceId,
    String? token,
  }) async {
    final response =
        await stockMovementService.updateStockMovement(
      movementId: movementId,
      itemId: itemId,
      movementType: movementType,
      quantity: quantity,
      sourceType: sourceType,
      sourceId: sourceId,
      token: token,
    );

    final data = response['data'];

    if (data is! Map) {
      throw Exception(
        'Updated movement was not returned by the server.',
      );
    }

    return StockMovementModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // DELETE
  Future<void> deleteStockMovement({
    required int movementId,
    String? token,
  }) async {
    await stockMovementService.deleteStockMovement(
      movementId: movementId,
      token: token,
    );
  }
}
