
import '../constants/api_constants.dart';
import '../network/api_client.dart';

class ReportService {
  final ApiClient apiClient;

  ReportService({
    required this.apiClient,
  });

  Future<dynamic> _getReport(
    String endpoint, {
    required String accessToken,
    Map<String, String>? queryParameters,
  }) async {
    var path = endpoint;

    if (queryParameters != null &&
        queryParameters.isNotEmpty) {
      final filtered = Map<String, String>.from(
        queryParameters,
      )..removeWhere((key, value) => value.trim().isEmpty);

      if (filtered.isNotEmpty) {
        final query = Uri(
          queryParameters: filtered,
        ).query;

        path = '$endpoint?$query';
      }
    }

    return apiClient.get(
      path,
      token: accessToken,
    );
  }

  Future<dynamic> getSales({
    required String accessToken,
    String? fromDate,
    String? toDate,
  }) {
    return _getReport(
      ApiConstants.salesReport,
      accessToken: accessToken,
      queryParameters: {
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
      },
    );
  }

  Future<dynamic> getPurchases({
    required String accessToken,
    String? fromDate,
    String? toDate,
  }) {
    return _getReport(
      ApiConstants.purchasesReport,
      accessToken: accessToken,
      queryParameters: {
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
      },
    );
  }

  Future<dynamic> getCustomerPayments({
    required String accessToken,
    String? fromDate,
    String? toDate,
  }) {
    return _getReport(
      ApiConstants.customerPaymentsReport,
      accessToken: accessToken,
      queryParameters: {
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
      },
    );
  }

  Future<dynamic> getVendorPayments({
    required String accessToken,
    String? fromDate,
    String? toDate,
  }) {
    return _getReport(
      ApiConstants.vendorPaymentsReport,
      accessToken: accessToken,
      queryParameters: {
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
      },
    );
  }

  Future<dynamic> getCustomerBalances({
    required String accessToken,
  }) {
    return _getReport(
      ApiConstants.customerBalancesReport,
      accessToken: accessToken,
    );
  }

  Future<dynamic> getVendorBalances({
    required String accessToken,
  }) {
    return _getReport(
      ApiConstants.vendorBalancesReport,
      accessToken: accessToken,
    );
  }

  Future<dynamic> getInventory({
    required String accessToken,
  }) {
    return _getReport(
      ApiConstants.inventoryReport,
      accessToken: accessToken,
    );
  }

  Future<dynamic> getItemSales({
    required String accessToken,
    String? fromDate,
    String? toDate,
  }) {
    return _getReport(
      ApiConstants.itemSalesReport,
      accessToken: accessToken,
      queryParameters: {
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
      },
    );
  }

  Future<dynamic> getItemPurchases({
    required String accessToken,
    String? fromDate,
    String? toDate,
  }) {
    return _getReport(
      ApiConstants.itemPurchasesReport,
      accessToken: accessToken,
      queryParameters: {
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
      },
    );
  }

  Future<dynamic> getProfit({
    required String accessToken,
    String? fromDate,
    String? toDate,
  }) {
    return _getReport(
      ApiConstants.profitReport,
      accessToken: accessToken,
      queryParameters: {
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
      },
    );
  }

  Future<dynamic> getDailySummary({
    required String accessToken,
    String? date,
  }) {
    return _getReport(
      ApiConstants.dailySummaryReport,
      accessToken: accessToken,
      queryParameters: {
        'date': date ?? '',
      },
    );
  }
}
