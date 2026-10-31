import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../storage/storage_service.dart';

class CustomerRepository {
  final CustomerService customerService;

  CustomerRepository({
    required this.customerService,
  });

  // ======================================================
  // GET ALL CUSTOMERS
  // ======================================================

  Future<List<CustomerModel>> getCustomers() async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await customerService.getCustomers(
      accessToken: token,
    );

    final List customers =
        response["data"] ?? [];

    return customers
        .map(
          (customer) => CustomerModel.fromJson(
            Map<String, dynamic>.from(customer),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET CUSTOMER BY ID
  // ======================================================

  Future<CustomerModel> getCustomerById(
    int customerId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await customerService.getCustomerById(
      accessToken: token,
      customerId: customerId,
    );

    return CustomerModel.fromJson(
      Map<String, dynamic>.from(
        response["data"],
      ),
    );
  }

  // ======================================================
  // CREATE CUSTOMER
  // ======================================================

  Future<CustomerModel> createCustomer({
    required String customerName,
    required String phone,
    required String email,
    required String address,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await customerService.createCustomer(
      accessToken: token,
      customerName: customerName,
      phone: phone,
      email: email,
      address: address,
    );

    return CustomerModel(
      customerId: response["customer_id"],
      customerName: customerName,
      phone: phone,
      email: email,
      address: address,
    );
  }

  // ======================================================
  // UPDATE CUSTOMER
  // ======================================================

  Future<CustomerModel> updateCustomer({
    required int customerId,
    required String customerName,
    required String phone,
    required String email,
    required String address,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    await customerService.updateCustomer(
      accessToken: token,
      customerId: customerId,
      customerName: customerName,
      phone: phone,
      email: email,
      address: address,
    );

    return CustomerModel(
      customerId: customerId,
      customerName: customerName,
      phone: phone,
      email: email,
      address: address,
    );
  }

  // ======================================================
  // DELETE CUSTOMER
  // ======================================================

  Future<void> deleteCustomer(
    int customerId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    await customerService.deleteCustomer(
      accessToken: token,
      customerId: customerId,
    );
  }
}