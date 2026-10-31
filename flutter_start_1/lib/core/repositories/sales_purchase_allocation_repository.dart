
import '../models/sales_purchase_allocation_model.dart';
import '../services/sales_purchase_allocation_service.dart';
import '../storage/storage_service.dart';

class SalesPurchaseAllocationRepository {
  final SalesPurchaseAllocationService service;

  SalesPurchaseAllocationRepository(this.service);

  // AUTHENTICATION

  Future<String> _getToken() async {
    final token = await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authorization token is required. Please log in again.',
      );
    }

    return token;
  }

  List<dynamic> _readList(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is! List) {
      throw Exception(
        'Invalid allocation response from server.',
      );
    }

    return data;
  }

  Map<String, dynamic> _readObject(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];

    if (data is! Map) {
      throw Exception(
        'Allocation information was not returned.',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  // GET ALL ALLOCATIONS

  Future<List<SalesPurchaseAllocationModel>>
      getAllocations() async {
    final token = await _getToken();

    final response = await service.getAllocations(
      accessToken: token,
    );

    return _readList(response)
        .map(
          (json) => SalesPurchaseAllocationModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // GET ALLOCATION BY ID

  Future<SalesPurchaseAllocationModel> getAllocationById(
    int allocationId,
  ) async {
    final token = await _getToken();

    final response = await service.getAllocationById(
      allocationId: allocationId,
      accessToken: token,
    );

    return SalesPurchaseAllocationModel.fromJson(
      _readObject(response),
    );
  }

  // GET SALES DETAIL OPTIONS

  Future<List<SaleDetailOptionModel>> getSaleDetails() async {
    final token = await _getToken();

    final response = await service.getSaleDetails(
      accessToken: token,
    );

    return _readList(response)
        .map(
          (json) => SaleDetailOptionModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // GET PURCHASE DETAIL OPTIONS

  Future<List<PurchaseDetailOptionModel>>
      getPurchaseDetails() async {
    final token = await _getToken();

    final response = await service.getPurchaseDetails(
      accessToken: token,
    );

    return _readList(response)
        .map(
          (json) => PurchaseDetailOptionModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

Future<bool> runAllocation({
  String? fromDate,
  String? toDate,
}) async {
  final token = await _getToken();
  final response = await service.runAllocation(
    accessToken: token,
    fromDate: fromDate,
    toDate: toDate,
  );
  return response['success'] == true;
}
  // CREATE ALLOCATION

  Future<SalesPurchaseAllocationModel> createAllocation({
    required int saleDetailId,
    required int purchaseDetailId,
    required int itemId,
    required double allocatedQuantity,
  }) async {
    final token = await _getToken();

    final response = await service.createAllocation(
      saleDetailId: saleDetailId,
      purchaseDetailId: purchaseDetailId,
      itemId: itemId,
      allocatedQuantity: allocatedQuantity,
      accessToken: token,
    );

    final data = response['data'];

    if (data is Map) {
      return SalesPurchaseAllocationModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    // Support APIs that return the new allocation ID.
    final allocationId = data is num
        ? data.toInt()
        : int.tryParse(data?.toString() ?? '');

    if (allocationId != null && allocationId > 0) {
      return getAllocationById(allocationId);
    }

    throw Exception(
      'Allocation was created, but the server did not return its details. Refresh the list.',
    );
  }

  // UPDATE ALLOCATION

  Future<SalesPurchaseAllocationModel> updateAllocation({
    required int allocationId,
    required int saleDetailId,
    required int purchaseDetailId,
    required int itemId,
    required double allocatedQuantity,
  }) async {
    final token = await _getToken();

    await service.updateAllocation(
      allocationId: allocationId,
      saleDetailId: saleDetailId,
      purchaseDetailId: purchaseDetailId,
      itemId: itemId,
      allocatedQuantity: allocatedQuantity,
      accessToken: token,
    );

    return getAllocationById(allocationId);
  }

  // DELETE ALLOCATION

  Future<void> deleteAllocation(int allocationId) async {
    final token = await _getToken();

    await service.deleteAllocation(
      allocationId: allocationId,
      accessToken: token,
    );
  }
}
