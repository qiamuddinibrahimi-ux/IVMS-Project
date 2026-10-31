
import '../models/purchase_detail_model.dart';
import '../network/api_client.dart';

class PurchaseDetailService {
  final ApiClient apiClient;

  PurchaseDetailService({
    required this.apiClient,
  });

  static const String _endpoint = '/purchase-details';

  Future<List<PurchaseDetailModel>> getPurchaseDetails({
    required String token,
    int? purchaseId,
    int? itemId,
  }) async {
    final query = <String, String>{};

    if (purchaseId != null) {
      query['purchase_id'] = purchaseId.toString();
    }

    if (itemId != null) {
      query['item_id'] = itemId.toString();
    }

    var endpoint = _endpoint;

    if (query.isNotEmpty) {
      endpoint += '?${Uri(queryParameters: query).query}';
    }

    final response = await apiClient.get(
      endpoint,
      token: token,
    );

    final data = response['data'];

    if (data is! List) {
      throw Exception(
        'Invalid purchase details response from server.',
      );
    }

    return data
        .map(
          (record) => PurchaseDetailModel.fromAny(record),
        )
        .toList();
  }

  Future<PurchaseDetailModel> getPurchaseDetailById({
    required int detailId,
    required String token,
  }) async {
    final response = await apiClient.get(
      '$_endpoint/$detailId',
      token: token,
    );

    return PurchaseDetailModel.fromAny(response['data']);
  }

  Future<int> createPurchaseDetail({
    required String token,
    required int purchaseId,
    required int itemId,
    required double quantity,
    required double unitPrice,
  }) async {
    final response = await apiClient.post(
      _endpoint,
      token: token,
      body: {
        'purchase_id': purchaseId,
        'item_id': itemId,
        'quantity': quantity,
        'unit_price': unitPrice,
      },
    );

    return int.tryParse(
          response['purchase_detail_id']?.toString() ?? '',
        ) ??
        0;
  }

  Future<void> updatePurchaseDetail({
    required String token,
    required int detailId,
    required int purchaseId,
    required int itemId,
    required double quantity,
    required double unitPrice,
  }) async {
    await apiClient.put(
      '$_endpoint/$detailId',
      token: token,
      body: {
        'purchase_id': purchaseId,
        'item_id': itemId,
        'quantity': quantity,
        'unit_price': unitPrice,
      },
    );
  }

  Future<void> deletePurchaseDetail({
    required String token,
    required int detailId,
  }) async {
    await apiClient.delete(
      '$_endpoint/$detailId',
      token: token,
    );
  }
}
