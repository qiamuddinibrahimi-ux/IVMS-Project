import '../models/item_model.dart';
import '../services/item_service.dart';
import '../storage/storage_service.dart';

class ItemRepository {
  final ItemService itemService;

  ItemRepository({
    required this.itemService,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<ItemModel> createItem({
    required String itemName,
    required int categoryId,
    required int unitId,
    String? barcode,
    String? description,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await itemService.createItem(
      itemName: itemName,
      categoryId: categoryId,
      unitId: unitId,
      barcode: barcode,
      description: description,
      token: token,
    );

    if (response["success"] != true) {
      throw Exception(
        response["message"] ??
            "Failed to create item.",
      );
    }

    // Backend create currently returns only item_id.
    // Fetch the complete item after creation.

    final itemId =
        int.parse(
      response["item_id"].toString(),
    );

    return getItemById(itemId);
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<List<ItemModel>> getItems() async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await itemService.getItems(
      token: token,
    );

    if (response["success"] != true) {
      throw Exception(
        response["message"] ??
            "Failed to load items.",
      );
    }

    final List data =
        response["data"] ?? [];

    return data
        .map(
          (json) => ItemModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<ItemModel> getItemById(
    int itemId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await itemService.getItemById(
      itemId: itemId,
      token: token,
    );

    if (response["success"] != true) {
      throw Exception(
        response["message"] ??
            "Item not found.",
      );
    }

    return ItemModel.fromJson(
      Map<String, dynamic>.from(
        response["data"],
      ),
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<ItemModel> updateItem({
    required int itemId,
    required String itemName,
    required int categoryId,
    required int unitId,
    String? barcode,
    String? description,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await itemService.updateItem(
      itemId: itemId,
      itemName: itemName,
      categoryId: categoryId,
      unitId: unitId,
      barcode: barcode,
      description: description,
      token: token,
    );

    if (response["success"] != true) {
      throw Exception(
        response["message"] ??
            "Failed to update item.",
      );
    }

    // Backend update returns only success/message.
    // Fetch updated item.

    return getItemById(itemId);
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> deleteItem(
    int itemId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await itemService.deleteItem(
      itemId: itemId,
      token: token,
    );

    if (response["success"] != true) {
      throw Exception(
        response["message"] ??
            "Failed to delete item.",
      );
    }
  }
}