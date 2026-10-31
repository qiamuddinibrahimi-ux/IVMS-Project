import '../network/api_client.dart';
import '../constants/api_constants.dart';

class PurchaseService {
  final ApiClient apiClient;

  PurchaseService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE PURCHASE
  // ======================================================

  Future<Map<String, dynamic>> createPurchase({
    required int vendorId,
    required int currencyId,
    required String purchaseDate,
    required String invoiceNo,
    String? token,
  }) async {
    final response = await apiClient.post(
      ApiConstants.purchases,
      token: token,
      body: {
        'vendor_id': vendorId,
        'currency_id': currencyId,
        'purchase_date': purchaseDate,
        'invoice_no': invoiceNo,
      },
    );

    return response;
  }

  // ======================================================
  // GET ALL PURCHASES
  // ======================================================

  Future<Map<String, dynamic>> getPurchases({
    String? token,
  }) async {
    final response = await apiClient.get(
      ApiConstants.purchases,
      token: token,
    );

    return response;
  }

  // ======================================================
  // GET PURCHASE BY ID
  // ======================================================

  Future<Map<String, dynamic>> getPurchaseById({
    required int purchaseId,
    String? token,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.purchases}/$purchaseId',
      token: token,
    );

    return response;
  }

  // ======================================================
  // UPDATE PURCHASE
  // ======================================================

  Future<Map<String, dynamic>> updatePurchase({
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required String purchaseDate,
    required String invoiceNo,
    String? token,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.purchases}/$purchaseId',
      token: token,
      body: {
        'vendor_id': vendorId,
        'currency_id': currencyId,
        'purchase_date': purchaseDate,
        'invoice_no': invoiceNo,
      },
    );

    return response;
  }

  // ======================================================
  // DELETE PURCHASE
  // ======================================================

  Future<Map<String, dynamic>> deletePurchase({
    required int purchaseId,
    String? token,
  }) async {
    final response = await apiClient.delete(
      '${ApiConstants.purchases}/$purchaseId',
      token: token,
    );

    return response;
  }
}