import '../constants/api_constants.dart';
import '../network/api_client.dart';

class CustomerService {
  final ApiClient apiClient;

  CustomerService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE CUSTOMER
  // ======================================================

  Future<Map<String, dynamic>> createCustomer({
    required String accessToken,
    required String customerName,
    required String phone,
    required String email,
    required String address,
  }) async {
    return await apiClient.post(
      ApiConstants.customers,
      token: accessToken,
      body: {
        "customer_name": customerName,
        "phone": phone,
        "email": email,
        "address": address,
      },
    );
  }

  // ======================================================
  // GET ALL CUSTOMERS
  // ======================================================

  Future<Map<String, dynamic>> getCustomers({
    required String accessToken,
  }) async {
    return await apiClient.get(
      ApiConstants.customers,
      token: accessToken,
    );
  }

  // ======================================================
  // GET CUSTOMER BY ID
  // ======================================================

  Future<Map<String, dynamic>> getCustomerById({
    required String accessToken,
    required int customerId,
  }) async {
    return await apiClient.get(
      "${ApiConstants.customers}/$customerId",
      token: accessToken,
    );
  }

  // ======================================================
  // UPDATE CUSTOMER
  // ======================================================

  Future<Map<String, dynamic>> updateCustomer({
    required String accessToken,
    required int customerId,
    required String customerName,
    required String phone,
    required String email,
    required String address,
  }) async {
    return await apiClient.put(
      "${ApiConstants.customers}/$customerId",
      token: accessToken,
      body: {
        "customer_name": customerName,
        "phone": phone,
        "email": email,
        "address": address,
      },
    );
  }

  // ======================================================
  // DELETE CUSTOMER
  // ======================================================

  Future<Map<String, dynamic>> deleteCustomer({
    required String accessToken,
    required int customerId,
  }) async {
    return await apiClient.delete(
      "${ApiConstants.customers}/$customerId",
      token: accessToken,
    );
  }
}