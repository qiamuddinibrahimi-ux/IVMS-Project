
import '../models/inventory_model.dart';
import '../models/inventory_movement_model.dart';
import '../models/inventory_summary_model.dart';
import '../services/inventory_service.dart';

class InventoryRepository {
  final InventoryService inventoryService;

  InventoryRepository({
    required this.inventoryService,
  });

  Future<List<InventoryModel>> getInventory({
    required String token,
  }) async {
    final response = await inventoryService.getInventory(
      token: token,
    );

    final rows = response['data'] as List? ?? [];

    return rows
        .map(
          (row) => InventoryModel.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<InventoryModel> getInventoryByItem({
    required int itemId,
    required String token,
  }) async {
    final response = await inventoryService.getInventoryByItem(
      itemId: itemId,
      token: token,
    );

    final data = Map<String, dynamic>.from(
      response['data'] as Map,
    );

    final item = Map<String, dynamic>.from(
      data['item'] as Map,
    );

    final stock = Map<String, dynamic>.from(
      data['stock'] as Map,
    );

    return InventoryModel.fromJson({
      ...item,
      ...stock,
    });
  }

  Future<InventorySummaryModel> getInventorySummary({
    required String token,
  }) async {
    final response =
        await inventoryService.getInventorySummary(
      token: token,
    );

    return InventorySummaryModel.fromJson(
      Map<String, dynamic>.from(
        response['data'] as Map,
      ),
    );
  }

  Future<List<InventoryModel>> getLowStockItems({
    required String token,
    double threshold = 5,
  }) async {
    final response = await inventoryService.getLowStockItems(
      token: token,
      threshold: threshold,
    );

    final rows = response['data'] as List? ?? [];

    return rows
        .map(
          (row) => InventoryModel.fromLowStockJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<List<InventoryMovementModel>> getMovementHistory({
    required String token,
    int? itemId,
    String? movementType,
    String? sourceType,
  }) async {
    final response =
        await inventoryService.getMovementHistory(
      token: token,
      itemId: itemId,
      movementType: movementType,
      sourceType: sourceType,
    );

    final rows = response['data'] as List? ?? [];

    return rows
        .map(
          (row) => InventoryMovementModel.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<void> createAdjustment({
    required String token,
    required int itemId,
    required String movementType,
    required double quantity,
  }) async {
    await inventoryService.createAdjustment(
      token: token,
      itemId: itemId,
      movementType: movementType,
      quantity: quantity,
    );
  }

  Future<void> updateAdjustment({
    required String token,
    required int movementId,
    required int itemId,
    required String movementType,
    required double quantity,
  }) async {
    await inventoryService.updateAdjustment(
      token: token,
      movementId: movementId,
      itemId: itemId,
      movementType: movementType,
      quantity: quantity,
    );
  }

  Future<void> deleteAdjustment({
    required String token,
    required int movementId,
  }) async {
    await inventoryService.deleteAdjustment(
      token: token,
      movementId: movementId,
    );
  }
}
