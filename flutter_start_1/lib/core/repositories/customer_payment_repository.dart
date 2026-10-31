import '../models/customer_payment_model.dart';
import '../services/customer_payment_service.dart';
import '../storage/storage_service.dart';

class CustomerPaymentRepository {
  final CustomerPaymentService customerPaymentService;

  CustomerPaymentRepository({
    required this.customerPaymentService,
  });

  // ======================================================
  // GET ALL PAYMENTS
  // ======================================================

  Future<List<CustomerPaymentModel>>
      getCustomerPayments() async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await customerPaymentService
            .getCustomerPayments(
      accessToken: token,
    );

    final List payments =
        response["data"] ?? [];

    return payments
        .map(
          (payment) =>
              CustomerPaymentModel.fromJson(
            Map<String, dynamic>.from(
              payment,
            ),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET PAYMENT BY ID
  // ======================================================

  Future<CustomerPaymentModel>
      getCustomerPaymentById(
    int paymentId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await customerPaymentService
            .getCustomerPaymentById(
      accessToken: token,
      paymentId: paymentId,
    );

    return CustomerPaymentModel.fromJson(
      Map<String, dynamic>.from(
        response["data"],
      ),
    );
  }

  // ======================================================
  // CREATE PAYMENT
  // ======================================================

  Future<CustomerPaymentModel>
      createCustomerPayment({
    required int customerId,
    required int saleId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await customerPaymentService
            .createCustomerPayment(
      accessToken: token,
      customerId: customerId,
      saleId: saleId,
      currencyId: currencyId,
      amount: amount,
      paymentDate: paymentDate,
    );

    return CustomerPaymentModel(
      customerPaymentId:
          int.parse(
        response["customer_payment_id"]
            .toString(),
      ),

      customerId: customerId,
      customerName: "",

      saleId: saleId,
      invoiceNo: "",
      saleDate: "",

      currencyId: currencyId,
      currencyName: "",
      currencyCode: "",
      symbol: "",

      amount: amount,
      paymentDate: paymentDate,
    );
  }

  // ======================================================
  // UPDATE PAYMENT
  // ======================================================

  Future<CustomerPaymentModel>
      updateCustomerPayment({
    required int paymentId,
    required int customerId,
    required int saleId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    await customerPaymentService
        .updateCustomerPayment(
      accessToken: token,
      paymentId: paymentId,
      customerId: customerId,
      saleId: saleId,
      currencyId: currencyId,
      amount: amount,
      paymentDate: paymentDate,
    );

    return CustomerPaymentModel(
      customerPaymentId: paymentId,

      customerId: customerId,
      customerName: "",

      saleId: saleId,
      invoiceNo: "",
      saleDate: "",

      currencyId: currencyId,
      currencyName: "",
      currencyCode: "",
      symbol: "",

      amount: amount,
      paymentDate: paymentDate,
    );
  }

  // ======================================================
  // DELETE PAYMENT
  // ======================================================

  Future<void> deleteCustomerPayment(
    int paymentId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    await customerPaymentService
        .deleteCustomerPayment(
      accessToken: token,
      paymentId: paymentId,
    );
  }
}