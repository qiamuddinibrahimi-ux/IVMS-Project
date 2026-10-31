
import '../constants/api_constants.dart';
import '../network/api_client.dart';

class InventoryService {
  final ApiClient apiClient;

  InventoryService({
    required this.apiClient,
  });

  Future<Map<String, dynamic>> getInventory({
    required String token,
  }) {
    return apiClient.get(
      ApiConstants.inventory,
      token: token,
    );
  }

  Future<Map<String, dynamic>> getInventoryByItem({
    required int itemId,
    required String token,
  }) {
    return apiClient.get(
      '${ApiConstants.inventory}/$itemId',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getInventorySummary({
    required String token,
  }) {
    return apiClient.get(
      '${ApiConstants.inventory}/summary',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getLowStockItems({
    required String token,
    double threshold = 5,
  }) {
    return apiClient.get(
      '${ApiConstants.inventory}/low-stock'
      '?threshold=$threshold',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getMovementHistory({
    required String token,
    int? itemId,
    String? movementType,
    String? sourceType,
  }) {
    final queryParameters = <String, String>{};

    if (itemId != null) {
      queryParameters['item_id'] = itemId.toString();
    }

    if (movementType != null && movementType.isNotEmpty) {
      queryParameters['movement_type'] = movementType;
    }

    if (sourceType != null && sourceType.isNotEmpty) {
      queryParameters['source_type'] = sourceType;
    }

    final query = queryParameters.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');

    final endpoint = query.isEmpty
        ? '${ApiConstants.inventory}/movements'
        : '${ApiConstants.inventory}/movements?$query';

    return apiClient.get(
      endpoint,
      token: token,
    );
  }

  Future<Map<String, dynamic>> createAdjustment({
    required String token,
    required int itemId,
    required String movementType,
    required double quantity,
  }) {
    return apiClient.post(
      '${ApiConstants.inventory}/adjustment',
      token: token,
      body: {
        'item_id': itemId,
        'movement_type': movementType,
        'quantity': quantity,
      },
    );
  }

  Future<Map<String, dynamic>> updateAdjustment({
    required String token,
    required int movementId,
    required int itemId,
    required String movementType,
    required double quantity,
  }) {
    return apiClient.put(
      '${ApiConstants.inventory}/adjustment/$movementId',
      token: token,
      body: {
        'item_id': itemId,
        'movement_type': movementType,
        'quantity': quantity,
      },
    );
  }

  Future<Map<String, dynamic>> deleteAdjustment({
    required String token,
    required int movementId,
  }) {
    return apiClient.delete(
      '${ApiConstants.inventory}/adjustment/$movementId',
      token: token,
    );
  }
}
