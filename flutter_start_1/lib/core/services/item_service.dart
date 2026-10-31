import '../network/api_client.dart';
import '../constants/api_constants.dart';

class ItemService {
  final ApiClient apiClient;

  ItemService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE ITEM
  // ======================================================

  Future<Map<String, dynamic>> createItem({
    required String itemName,
    required int categoryId,
    required int unitId,
    String? barcode,
    String? description,
    String? token,
  }) async {
    final response =
        await apiClient.post(
      ApiConstants.items,
      token: token,
      body: {
        "item_name": itemName,
        "category_id": categoryId,
        "unit_id": unitId,
        "barcode": barcode,
        "description": description,
      },
    );

    return response;
  }

  // ======================================================
  // GET ALL ITEMS
  // ======================================================

  Future<Map<String, dynamic>> getItems({
    String? token,
  }) async {
    final response =
        await apiClient.get(
      ApiConstants.items,
      token: token,
    );

    return response;
  }

  // ======================================================
  // GET ITEM BY ID
  // ======================================================

  Future<Map<String, dynamic>> getItemById({
    required int itemId,
    String? token,
  }) async {
    final response =
        await apiClient.get(
      "${ApiConstants.items}/$itemId",
      token: token,
    );

    return response;
  }

  // ======================================================
  // UPDATE ITEM
  // ======================================================

  Future<Map<String, dynamic>> updateItem({
    required int itemId,
    required String itemName,
    required int categoryId,
    required int unitId,
    String? barcode,
    String? description,
    String? token,
  }) async {
    final response =
        await apiClient.put(
      "${ApiConstants.items}/$itemId",
      token: token,
      body: {
        "item_name": itemName,
        "category_id": categoryId,
        "unit_id": unitId,
        "barcode": barcode,
        "description": description,
      },
    );

    return response;
  }

  // ======================================================
  // DELETE ITEM
  // ======================================================

  Future<Map<String, dynamic>> deleteItem({
    required int itemId,
    String? token,
  }) async {
    final response =
        await apiClient.delete(
      "${ApiConstants.items}/$itemId",
      token: token,
    );

    return response;
  }
}