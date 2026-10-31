import '../constants/api_constants.dart';
import '../network/api_client.dart';

class SaleService {
  final ApiClient apiClient;

  SaleService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE SALE
  // ======================================================

  Future<Map<String, dynamic>> createSale({
    required int customerId,
    required int currencyId,
    required String saleDate,
    required String invoiceNo,
    required String accessToken,
  }) async {
    return await apiClient.post(
      ApiConstants.sales,
      token: accessToken,
      body: {
        'customer_id': customerId,
        'currency_id': currencyId,
        'sale_date': saleDate,
        'invoice_no': invoiceNo,
      },
    );
  }

  // ======================================================
  // GET ALL SALES
  // ======================================================

  Future<Map<String, dynamic>> getSales({
    required String accessToken,
  }) async {
    return await apiClient.get(
      ApiConstants.sales,
      token: accessToken,
    );
  }

  // ======================================================
  // GET SALE BY ID
  // ======================================================

  Future<Map<String, dynamic>> getSaleById({
    required int saleId,
    required String accessToken,
  }) async {
    return await apiClient.get(
      '${ApiConstants.sales}/$saleId',
      token: accessToken,
    );
  }

  // ======================================================
  // UPDATE SALE
  // ======================================================

  Future<Map<String, dynamic>> updateSale({
    required int saleId,
    required int customerId,
    required int currencyId,
    required String saleDate,
    required String invoiceNo,
    required String accessToken,
  }) async {
    return await apiClient.put(
      '${ApiConstants.sales}/$saleId',
      token: accessToken,
      body: {
        'customer_id': customerId,
        'currency_id': currencyId,
        'sale_date': saleDate,
        'invoice_no': invoiceNo,
      },
    );
  }

  // ======================================================
  // DELETE SALE
  // ======================================================

  Future<Map<String, dynamic>> deleteSale({
    required int saleId,
    required String accessToken,
  }) async {
    return await apiClient.delete(
      '${ApiConstants.sales}/$saleId',
      token: accessToken,
    );
  }
}