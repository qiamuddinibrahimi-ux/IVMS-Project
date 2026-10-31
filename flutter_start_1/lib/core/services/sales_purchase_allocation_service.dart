import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';

class SalesPurchaseAllocationService {
  final ApiClient apiClient;

  SalesPurchaseAllocationService(this.apiClient);

  String get _baseEndpoint =>
      ApiConstants.salesPurchaseAllocations;

  // GET ALL ALLOCATIONS

  Future<Map<String, dynamic>> getAllocations({
    required String accessToken,
  }) {
    return apiClient.get(
      _baseEndpoint,
      token: accessToken,
    );
  }

Future<Map<String, dynamic>> runAllocation({
  required String accessToken,
  String? fromDate,
  String? toDate,
}) {
  return apiClient.post(
    '$_baseEndpoint/allocate',
    token: accessToken,
    body: {
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    },
  );
}
  // GET ALLOCATION BY ID

  Future<Map<String, dynamic>> getAllocationById({
    required int allocationId,
    required String accessToken,
  }) {
    return apiClient.get(
      '$_baseEndpoint/$allocationId',
      token: accessToken,
    );
  }

  // CREATE ALLOCATION

  Future<Map<String, dynamic>> createAllocation({
    required int saleDetailId,
    required int purchaseDetailId,
    required int itemId,
    required double allocatedQuantity,
    required String accessToken,
  }) {
    return apiClient.post(
      _baseEndpoint,
      token: accessToken,
      body: {
        'sale_detail_id': saleDetailId,
        'purchase_detail_id': purchaseDetailId,
        'item_id': itemId,
        'allocated_quantity': allocatedQuantity,
      },
    );
  }

  // UPDATE ALLOCATION

  Future<Map<String, dynamic>> updateAllocation({
    required int allocationId,
    required int saleDetailId,
    required int purchaseDetailId,
    required int itemId,
    required double allocatedQuantity,
    required String accessToken,
  }) {
    return apiClient.put(
      '$_baseEndpoint/$allocationId',
      token: accessToken,
      body: {
        'sale_detail_id': saleDetailId,
        'purchase_detail_id': purchaseDetailId,
        'item_id': itemId,
        'allocated_quantity': allocatedQuantity,
      },
    );
  }

  // DELETE ALLOCATION

  Future<Map<String, dynamic>> deleteAllocation({
    required int allocationId,
    required String accessToken,
  }) {
    return apiClient.delete(
      '$_baseEndpoint/$allocationId',
      token: accessToken,
    );
  }

  // GET AVAILABLE SALES DETAILS

 Future<Map<String, dynamic>> getSaleDetails({
  required String accessToken,
}) async {
  final response = await apiClient.get(
    '$_baseEndpoint/sale-details',
    token: accessToken,
  );

  debugPrint('SALE DETAILS API RESPONSE: $response');

  return response;
}

  // GET AVAILABLE PURCHASE DETAILS

Future<Map<String, dynamic>> getPurchaseDetails({
  required String accessToken,
}) async {
  final response = await apiClient.get(
    '$_baseEndpoint/purchase-details',
    token: accessToken,
  );

  debugPrint('PURCHASE DETAILS API RESPONSE: $response');

  return response;
}
}
