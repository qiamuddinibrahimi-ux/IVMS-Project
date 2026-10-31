import '../models/purchase_model.dart';
import '../services/purchase_service.dart';
import '../storage/storage_service.dart';

class PurchaseRepository {
  final PurchaseService purchaseService;

  PurchaseRepository({
    required this.purchaseService,
  });

  // ======================================================
  // CREATE PURCHASE
  // ======================================================

  Future<PurchaseModel> createPurchase({
    required int vendorId,
    required int currencyId,
    required String purchaseDate,
    required String invoiceNo,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await purchaseService.createPurchase(
      vendorId: vendorId,
      currencyId: currencyId,
      purchaseDate: purchaseDate,
      invoiceNo: invoiceNo,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to create purchase.',
      );
    }

    final purchaseId =
        int.parse(response['purchase_id'].toString());

    return getPurchaseById(purchaseId);
  }

  // ======================================================
  // GET ALL PURCHASES
  // ======================================================

  Future<List<PurchaseModel>> getPurchases() async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await purchaseService.getPurchases(
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to load purchases.',
      );
    }

    final List data = response['data'] ?? [];

    return data
        .map(
          (json) => PurchaseModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET PURCHASE BY ID
  // ======================================================

  Future<PurchaseModel> getPurchaseById(
    int purchaseId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await purchaseService.getPurchaseById(
      purchaseId: purchaseId,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Purchase not found.',
      );
    }

    return PurchaseModel.fromJson(
      Map<String, dynamic>.from(
        response['data'],
      ),
    );
  }

  // ======================================================
  // UPDATE PURCHASE
  // ======================================================

  Future<PurchaseModel> updatePurchase({
    required int purchaseId,
    required int vendorId,
    required int currencyId,
    required String purchaseDate,
    required String invoiceNo,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await purchaseService.updatePurchase(
      purchaseId: purchaseId,
      vendorId: vendorId,
      currencyId: currencyId,
      purchaseDate: purchaseDate,
      invoiceNo: invoiceNo,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to update purchase.',
      );
    }

    // Backend returns success/message only,
    // so fetch the updated purchase.
    return getPurchaseById(purchaseId);
  }

  // ======================================================
  // DELETE PURCHASE
  // ======================================================

  Future<void> deletePurchase(
    int purchaseId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await purchaseService.deletePurchase(
      purchaseId: purchaseId,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to delete purchase.',
      );
    }
  }
}