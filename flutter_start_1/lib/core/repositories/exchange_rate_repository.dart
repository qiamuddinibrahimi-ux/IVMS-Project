import '../models/exchange_rate_model.dart';
import '../services/exchange_rate_service.dart';
import '../storage/storage_service.dart';

class ExchangeRateRepository {
  final ExchangeRateService exchangeRateService;

  ExchangeRateRepository({
    required this.exchangeRateService,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<ExchangeRateModel> createExchangeRate({
    required int fromCurrencyId,
    required int toCurrencyId,
    required double rate,
    required String effectiveDate,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    final response =
        await exchangeRateService.createExchangeRate(
      fromCurrencyId: fromCurrencyId,
      toCurrencyId: toCurrencyId,
      rate: rate,
      effectiveDate: effectiveDate,
      token: token,
    );

    final created =
        response["exchangeRate"];

    if (created == null) {
      throw Exception(
        "Exchange rate was created but no data was returned.",
      );
    }

    return ExchangeRateModel.fromJson(
      Map<String, dynamic>.from(created),
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<List<ExchangeRateModel>>
      getExchangeRates() async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    final response =
        await exchangeRateService.getExchangeRates(
      token: token,
    );

    final List<dynamic> data =
        response["exchangeRates"] ?? [];

    return data
        .map(
          (item) => ExchangeRateModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<ExchangeRateModel>
      getExchangeRateById(int id) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    final response =
        await exchangeRateService.getExchangeRateById(
      id: id,
      token: token,
    );

    final data =
        response["exchangeRate"];

    if (data == null) {
      throw Exception(
        "Exchange rate data was not returned.",
      );
    }

    return ExchangeRateModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<ExchangeRateModel>
      updateExchangeRate({
    required int id,
    required int fromCurrencyId,
    required int toCurrencyId,
    required double rate,
    required String effectiveDate,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    await exchangeRateService.updateExchangeRate(
      id: id,
      fromCurrencyId: fromCurrencyId,
      toCurrencyId: toCurrencyId,
      rate: rate,
      effectiveDate: effectiveDate,
      token: token,
    );

    // Get the updated record so that currency
    // names/codes are also refreshed.
    return await getExchangeRateById(id);
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> deleteExchangeRate(
    int id,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    await exchangeRateService.deleteExchangeRate(
      id: id,
      token: token,
    );
  }
}