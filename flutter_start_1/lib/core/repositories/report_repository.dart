import '../models/report_model.dart';
import '../services/report_service.dart';
import '../storage/storage_service.dart';

class ReportRepository {
  final ReportService reportService;

  ReportRepository({
    required this.reportService,
  });

  Future<String> _getToken() async {
    final token = await StorageService.getUserAccessToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('You are not logged in. Please log in again.');
    }

    return token;
  }

  Future<dynamic> _getResponse(
    Future<dynamic> Function(String token) request,
  ) async {
    final token = await _getToken();
    return request(token);
  }

  Future<List<ReportModel>> _parseList(dynamic response) async {
    if (response is! Map) {
      throw const FormatException('Invalid report response.');
    }

    final data = response['data'];

    if (data is! List) {
      throw const FormatException(
        'Invalid report data: expected a list.',
      );
    }

    return data
        .map((item) => ReportModel.fromAny(item))
        .toList();
  }

  Future<List<ReportModel>> getSales({
    String? fromDate,
    String? toDate,
  }) async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getSales(
          accessToken: token,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getPurchases({
    String? fromDate,
    String? toDate,
  }) async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getPurchases(
          accessToken: token,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getCustomerPayments({
    String? fromDate,
    String? toDate,
  }) async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getCustomerPayments(
          accessToken: token,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getVendorPayments({
    String? fromDate,
    String? toDate,
  }) async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getVendorPayments(
          accessToken: token,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getCustomerBalances() async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getCustomerBalances(
          accessToken: token,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getVendorBalances() async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getVendorBalances(
          accessToken: token,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getInventory() async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getInventory(
          accessToken: token,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getItemSales({
    String? fromDate,
    String? toDate,
  }) async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getItemSales(
          accessToken: token,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getItemPurchases({
    String? fromDate,
    String? toDate,
  }) async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getItemPurchases(
          accessToken: token,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  Future<List<ReportModel>> getProfit({
    String? fromDate,
    String? toDate,
  }) async {
    return _parseList(
      await _getResponse(
        (token) => reportService.getProfit(
          accessToken: token,
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getDailySummary({
    String? date,
  }) async {
    final response = await _getResponse(
      (token) => reportService.getDailySummary(
        accessToken: token,
        date: date,
      ),
    );

    if (response is! Map || response['data'] is! Map) {
      throw const FormatException(
        'Invalid daily summary response.',
      );
    }

    return Map<String, dynamic>.from(response['data'] as Map);
  }
}