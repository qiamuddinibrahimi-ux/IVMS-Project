import '../models/purchase_payment_model.dart';
import '../services/purchase_payment_service.dart';
import '../storage/storage_service.dart';

class PurchasePaymentRepository {
  final PurchasePaymentService service;

  PurchasePaymentRepository({
    required this.service,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<int> createPurchasePayment({
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final response =
        await service.createPurchasePayment(
      purchaseId: purchaseId,
      vendorId: vendorId,
      currencyId: currencyId,
      amount: amount,
      paymentDate: paymentDate,
      accessToken: token,
    );

    if (response['payment_id'] == null) {
      throw Exception(
        'Payment ID was not returned.',
      );
    }

    return int.parse(
      response['payment_id'].toString(),
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<List<PurchasePaymentModel>>
      getPurchasePayments() async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final response =
        await service.getPurchasePayments(
      accessToken: token,
    );

    final data = response['data'];

    if (data == null) {
      return [];
    }

    return (data as List)
        .map(
          (json) =>
              PurchasePaymentModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<PurchasePaymentModel>
      getPurchasePaymentById(
    int paymentId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final response =
        await service.getPurchasePaymentById(
      paymentId: paymentId,
      accessToken: token,
    );

    if (response['data'] == null) {
      throw Exception(
        'Purchase payment was not returned.',
      );
    }

    return PurchasePaymentModel.fromJson(
      Map<String, dynamic>.from(
        response['data'],
      ),
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<PurchasePaymentModel>
      updatePurchasePayment({
    required int paymentId,
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required double amount,
    required String paymentDate,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    await service.updatePurchasePayment(
      paymentId: paymentId,
      purchaseId: purchaseId,
      vendorId: vendorId,
      currencyId: currencyId,
      amount: amount,
      paymentDate: paymentDate,
      accessToken: token,
    );

    return await getPurchasePaymentById(
      paymentId,
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> deletePurchasePayment(
    int paymentId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    await service.deletePurchasePayment(
      paymentId: paymentId,
      accessToken: token,
    );
  }
}