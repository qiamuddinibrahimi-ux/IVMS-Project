import '../network/api_client.dart';

class ExchangeRateService {
  final ApiClient apiClient;

  ExchangeRateService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<Map<String, dynamic>> createExchangeRate({
    required int fromCurrencyId,
    required int toCurrencyId,
    required double rate,
    required String effectiveDate,
    required String token,
  }) async {
    return await apiClient.post(
      "/exchange-rates",
      token: token,
      body: {
        "from_currency_id": fromCurrencyId,
        "to_currency_id": toCurrencyId,
        "rate": rate,
        "effective_date": effectiveDate,
      },
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<Map<String, dynamic>> getExchangeRates({
    required String token,
  }) async {
    return await apiClient.get(
      "/exchange-rates",
      token: token,
    );
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<Map<String, dynamic>> getExchangeRateById({
    required int id,
    required String token,
  }) async {
    return await apiClient.get(
      "/exchange-rates/$id",
      token: token,
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<Map<String, dynamic>> updateExchangeRate({
    required int id,
    required int fromCurrencyId,
    required int toCurrencyId,
    required double rate,
    required String effectiveDate,
    required String token,
  }) async {
    return await apiClient.put(
      "/exchange-rates/$id",
      token: token,
      body: {
        "from_currency_id": fromCurrencyId,
        "to_currency_id": toCurrencyId,
        "rate": rate,
        "effective_date": effectiveDate,
      },
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<Map<String, dynamic>> deleteExchangeRate({
    required int id,
    required String token,
  }) async {
    return await apiClient.delete(
      "/exchange-rates/$id",
      token: token,
    );
  }
}