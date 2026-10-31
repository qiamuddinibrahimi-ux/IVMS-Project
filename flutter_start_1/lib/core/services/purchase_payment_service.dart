import '../constants/api_constants.dart';
import '../network/api_client.dart';

class PurchasePaymentService {
  final ApiClient apiClient;

  PurchasePaymentService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<Map<String, dynamic>> createPurchasePayment({
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required double amount,
    required String paymentDate,
    required String accessToken,
  }) async {
    return await apiClient.post(
      ApiConstants.purchasePayments,
      token: accessToken,
      body: {
        'purchase_id': purchaseId,
        'vendor_id': vendorId,
        'currency_id': currencyId,
        'amount': amount,
        'payment_date': paymentDate,
      },
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<Map<String, dynamic>> getPurchasePayments({
    required String accessToken,
  }) async {
    return await apiClient.get(
      ApiConstants.purchasePayments,
      token: accessToken,
    );
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<Map<String, dynamic>> getPurchasePaymentById({
    required int paymentId,
    required String accessToken,
  }) async {
    return await apiClient.get(
      '${ApiConstants.purchasePayments}/$paymentId',
      token: accessToken,
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<Map<String, dynamic>> updatePurchasePayment({
    required int paymentId,
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required double amount,
    required String paymentDate,
    required String accessToken,
  }) async {
    return await apiClient.put(
      '${ApiConstants.purchasePayments}/$paymentId',
      token: accessToken,
      body: {
        'purchase_id': purchaseId,
        'vendor_id': vendorId,
        'currency_id': currencyId,
        'amount': amount,
        'payment_date': paymentDate,
      },
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<Map<String, dynamic>> deletePurchasePayment({
    required int paymentId,
    required String accessToken,
  }) async {
    return await apiClient.delete(
      '${ApiConstants.purchasePayments}/$paymentId',
      token: accessToken,
    );
  }
}