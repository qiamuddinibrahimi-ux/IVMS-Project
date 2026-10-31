import '../models/sale_model.dart';
import '../services/sale_service.dart';
import '../storage/storage_service.dart';

class SaleRepository {
  final SaleService service;

  SaleRepository({
    required this.service,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<int> createSale({
    required int customerId,
    required int currencyId,
    required String saleDate,
    required String invoiceNo,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final response =
        await service.createSale(
      customerId: customerId,
      currencyId: currencyId,
      saleDate: saleDate,
      invoiceNo: invoiceNo,
      accessToken: token,
    );

    final saleId = response['sale_id'];

    if (saleId == null) {
      throw Exception(
        'Sale ID was not returned.',
      );
    }

    return int.parse(
      saleId.toString(),
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<List<SaleModel>> getSales() async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final response =
        await service.getSales(
      accessToken: token,
    );

    final data = response['data'];

    if (data is! List) {
      throw Exception(
        'Invalid sales response.',
      );
    }

    return data
        .map(
          (json) => SaleModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<SaleModel> getSaleById(
    int saleId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final response =
        await service.getSaleById(
      saleId: saleId,
      accessToken: token,
    );

    final data = response['data'];

    if (data == null) {
      throw Exception(
        'Sale information was not returned.',
      );
    }

    return SaleModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<SaleModel> updateSale({
    required int saleId,
    required int customerId,
    required int currencyId,
    required String saleDate,
    required String invoiceNo,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    await service.updateSale(
      saleId: saleId,
      customerId: customerId,
      currencyId: currencyId,
      saleDate: saleDate,
      invoiceNo: invoiceNo,
      accessToken: token,
    );

    // Backend update returns only message,
    // therefore get the updated sale.
    return await getSaleById(
      saleId,
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> deleteSale(
    int saleId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    await service.deleteSale(
      saleId: saleId,
      accessToken: token,
    );
  }
}