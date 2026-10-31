import '../models/currency_model.dart';
import '../services/currency_service.dart';
import '../storage/storage_service.dart';

class CurrencyRepository {
  final CurrencyService currencyService;

  CurrencyRepository({
    required this.currencyService,
  });

  // ======================================================
  // GET ALL
  // ======================================================

  Future<List<CurrencyModel>> getCurrencies() async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await currencyService.getCurrencies(
      accessToken: token,
    );

    final List currencies =
        response["currencies"] ?? [];

    return currencies
        .map(
          (currency) => CurrencyModel.fromJson(
            Map<String, dynamic>.from(currency),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<CurrencyModel> getCurrencyById(
    int currencyId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await currencyService.getCurrencyById(
      accessToken: token,
      currencyId: currencyId,
    );

    return CurrencyModel.fromJson(
      Map<String, dynamic>.from(
        response["currency"],
      ),
    );
  }

  // ======================================================
  // CREATE
  // ======================================================

  Future<CurrencyModel> createCurrency({
    required String currencyName,
    required String currencyCode,
    required String symbol,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await currencyService.createCurrency(
      accessToken: token,
      currencyName: currencyName,
      currencyCode: currencyCode,
      symbol: symbol,
    );

    return CurrencyModel.fromJson(
      Map<String, dynamic>.from(
        response["currency"],
      ),
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<CurrencyModel> updateCurrency({
    required int currencyId,
    required String currencyName,
    required String currencyCode,
    required String symbol,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await currencyService.updateCurrency(
      accessToken: token,
      currencyId: currencyId,
      currencyName: currencyName,
      currencyCode: currencyCode,
      symbol: symbol,
    );

    // Backend currently returns only success/message
    // after update, so create the updated model locally.

    return CurrencyModel(
      currencyId: currencyId,
      currencyName: currencyName,
      currencyCode: currencyCode,
      symbol: symbol,
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> deleteCurrency(
    int currencyId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    await currencyService.deleteCurrency(
      accessToken: token,
      currencyId: currencyId,
    );
  }
}