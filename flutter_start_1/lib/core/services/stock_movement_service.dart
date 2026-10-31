
import '../network/api_client.dart';
import '../constants/api_constants.dart';

class StockMovementService {
  final ApiClient apiClient;

  StockMovementService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE STOCK MOVEMENT
  // POST /api/stock-movements
  // ======================================================

  Future<Map<String, dynamic>> createStockMovement({
    required int itemId,
    required String movementType,
    required double quantity,
    required String sourceType,
    int? sourceId,
    String? token,
  }) async {
    final response = await apiClient.post(
      ApiConstants.stockMovements,
      token: token,
      body: {
        'item_id': itemId,
        'movement_type': movementType,
        'quantity': quantity,
        'source_type': sourceType,
        'source_id': sourceId,
      },
    );

    return response;
  }

  // ======================================================
  // GET ALL STOCK MOVEMENTS
  // GET /api/stock-movements
  // ======================================================

  Future<Map<String, dynamic>> getStockMovements({
    String? token,
  }) async {
    final response = await apiClient.get(
      ApiConstants.stockMovements,
      token: token,
    );

    return response;
  }

  // ======================================================
  // GET STOCK MOVEMENT BY ID
  // GET /api/stock-movements/:id
  // ======================================================

  Future<Map<String, dynamic>> getStockMovementById({
    required int movementId,
    String? token,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.stockMovements}/$movementId',
      token: token,
    );

    return response;
  }

  // ======================================================
  // UPDATE STOCK MOVEMENT
  // PUT /api/stock-movements/:id
  // ======================================================

  Future<Map<String, dynamic>> updateStockMovement({
    required int movementId,
    required int itemId,
    required String movementType,
    required double quantity,
    required String sourceType,
    int? sourceId,
    String? token,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.stockMovements}/$movementId',
      token: token,
      body: {
        'item_id': itemId,
        'movement_type': movementType,
        'quantity': quantity,
        'source_type': sourceType,
        'source_id': sourceId,
      },
    );

    return response;
  }

  // ======================================================
  // DELETE STOCK MOVEMENT
  // DELETE /api/stock-movements/:id
  // ======================================================

  Future<Map<String, dynamic>> deleteStockMovement({
    required int movementId,
    String? token,
  }) async {
    final response = await apiClient.delete(
      '${ApiConstants.stockMovements}/$movementId',
      token: token,
    );

    return response;
  }
}
