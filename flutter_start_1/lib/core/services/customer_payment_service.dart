import '../constants/api_constants.dart';
import '../network/api_client.dart';

class CustomerPaymentService {
  final ApiClient apiClient;

  CustomerPaymentService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE CUSTOMER PAYMENT
  // ======================================================

  Future<Map<String, dynamic>> createCustomerPayment({
    required String accessToken,
    required int customerId,
    required int saleId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    return await apiClient.post(
      ApiConstants.customerPayments,
      token: accessToken,
      body: {
        "customer_id": customerId,
        "sale_id": saleId,
        "currency_id": currencyId,
        "amount": amount,
        "payment_date": paymentDate,
      },
    );
  }

  // ======================================================
  // GET ALL CUSTOMER PAYMENTS
  // ======================================================

  Future<Map<String, dynamic>> getCustomerPayments({
    required String accessToken,
  }) async {
    return await apiClient.get(
      ApiConstants.customerPayments,
      token: accessToken,
    );
  }

  // ======================================================
  // GET PAYMENT BY ID
  // ======================================================

  Future<Map<String, dynamic>> getCustomerPaymentById({
    required String accessToken,
    required int paymentId,
  }) async {
    return await apiClient.get(
      "${ApiConstants.customerPayments}/$paymentId",
      token: accessToken,
    );
  }

  // ======================================================
  // UPDATE CUSTOMER PAYMENT
  // ======================================================

  Future<Map<String, dynamic>> updateCustomerPayment({
    required String accessToken,
    required int paymentId,
    required int customerId,
    required int saleId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    return await apiClient.put(
      "${ApiConstants.customerPayments}/$paymentId",
      token: accessToken,
      body: {
        "customer_id": customerId,
        "sale_id": saleId,
        "currency_id": currencyId,
        "amount": amount,
        "payment_date": paymentDate,
      },
    );
  }

  // ======================================================
  // DELETE CUSTOMER PAYMENT
  // ======================================================

  Future<Map<String, dynamic>> deleteCustomerPayment({
    required String accessToken,
    required int paymentId,
  }) async {
    return await apiClient.delete(
      "${ApiConstants.customerPayments}/$paymentId",
      token: accessToken,
    );
  }
}