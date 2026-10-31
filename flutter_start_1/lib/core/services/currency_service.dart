import '../constants/api_constants.dart';
import '../network/api_client.dart';

class CurrencyService {
  final ApiClient apiClient;

  CurrencyService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<Map<String, dynamic>> createCurrency({
    required String accessToken,
    required String currencyName,
    required String currencyCode,
    required String symbol,
  }) async {
    return await apiClient.post(
      ApiConstants.currencies,
      token: accessToken,
      body: {
        "currency_name": currencyName,
        "currency_code": currencyCode,
        "symbol": symbol,
      },
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<Map<String, dynamic>> getCurrencies({
    required String accessToken,
  }) async {
    return await apiClient.get(
      ApiConstants.currencies,
      token: accessToken,
    );
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<Map<String, dynamic>> getCurrencyById({
    required String accessToken,
    required int currencyId,
  }) async {
    return await apiClient.get(
      "${ApiConstants.currencies}/$currencyId",
      token: accessToken,
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<Map<String, dynamic>> updateCurrency({
    required String accessToken,
    required int currencyId,
    required String currencyName,
    required String currencyCode,
    required String symbol,
  }) async {
    return await apiClient.put(
      "${ApiConstants.currencies}/$currencyId",
      token: accessToken,
      body: {
        "currency_name": currencyName,
        "currency_code": currencyCode,
        "symbol": symbol,
      },
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<Map<String, dynamic>> deleteCurrency({
    required String accessToken,
    required int currencyId,
  }) async {
    return await apiClient.delete(
      "${ApiConstants.currencies}/$currencyId",
      token: accessToken,
    );
  }
}