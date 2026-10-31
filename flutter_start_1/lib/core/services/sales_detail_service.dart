
import '../models/sales_detail_model.dart';
import '../network/api_client.dart';

class SalesDetailService {
  final ApiClient apiClient;

  SalesDetailService({
    required this.apiClient,
  });

  static const String _endpoint = '/sales-details';

  // READ ALL
  Future<List<SalesDetailModel>> getSalesDetails({
    required String token,
    int? saleId,
    int? itemId,
  }) async {
    final query = <String, String>{};

    if (saleId != null) {
      query['sale_id'] = saleId.toString();
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
        'Invalid sales details response from server.',
      );
    }

    return data
        .map((record) => SalesDetailModel.fromAny(record))
        .toList();
  }

  // READ ONE
  Future<SalesDetailModel> getSalesDetailById({
    required int detailId,
    required String token,
  }) async {
    final response = await apiClient.get(
      '$_endpoint/$detailId',
      token: token,
    );

    return SalesDetailModel.fromAny(response['data']);
  }

  // CREATE
  Future<int> createSalesDetail({
    required String token,
    required int saleId,
    required int itemId,
    required double quantity,
    required double unitPrice,
  }) async {
    final response = await apiClient.post(
      _endpoint,
      token: token,
      body: {
        'sale_id': saleId,
        'item_id': itemId,
        'quantity': quantity,
        'unit_price': unitPrice,
      },
    );

    return int.tryParse(
          response['sale_detail_id']?.toString() ?? '',
        ) ??
        0;
  }

  // UPDATE
  Future<void> updateSalesDetail({
    required String token,
    required int detailId,
    required int saleId,
    required int itemId,
    required double quantity,
    required double unitPrice,
  }) async {
    await apiClient.put(
      '$_endpoint/$detailId',
      token: token,
      body: {
        'sale_id': saleId,
        'item_id': itemId,
        'quantity': quantity,
        'unit_price': unitPrice,
      },
    );
  }

  // DELETE
  Future<void> deleteSalesDetail({
    required String token,
    required int detailId,
  }) async {
    await apiClient.delete(
      '$_endpoint/$detailId',
      token: token,
    );
  }
}
