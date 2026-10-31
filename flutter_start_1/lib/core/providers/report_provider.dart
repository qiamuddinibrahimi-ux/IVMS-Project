
import 'package:flutter/foundation.dart';

import '../models/report_model.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository repository;

  ReportProvider({
    required this.repository,
  });

  bool isLoading = false;
  String? errorMessage;

  List<ReportModel> sales = [];
  List<ReportModel> purchases = [];
  List<ReportModel> customerPayments = [];
  List<ReportModel> vendorPayments = [];
  List<ReportModel> customerBalances = [];
  List<ReportModel> vendorBalances = [];
  List<ReportModel> inventory = [];
  List<ReportModel> itemSales = [];
  List<ReportModel> itemPurchases = [];
  List<ReportModel> profits = [];

  Map<String, dynamic> dailySummary = {};

  String? fromDate;
  String? toDate;
  String? selectedDailyDate;

  Future<void> _run(
    Future<void> Function() operation,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await operation();
    } catch (error) {
      errorMessage = error
          .toString()
          .replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setDateRange({
    String? from,
    String? to,
  }) {
    fromDate = from;
    toDate = to;
    notifyListeners();
  }

  Future<void> loadSales() => _run(() async {
        sales = await repository.getSales(
          fromDate: fromDate,
          toDate: toDate,
        );
      });

  Future<void> loadPurchases() => _run(() async {
        purchases = await repository.getPurchases(
          fromDate: fromDate,
          toDate: toDate,
        );
      });

  Future<void> loadCustomerPayments() => _run(() async {
        customerPayments =
            await repository.getCustomerPayments(
          fromDate: fromDate,
          toDate: toDate,
        );
      });

  Future<void> loadVendorPayments() => _run(() async {
        vendorPayments =
            await repository.getVendorPayments(
          fromDate: fromDate,
          toDate: toDate,
        );
      });

  Future<void> loadCustomerBalances() => _run(() async {
        customerBalances =
            await repository.getCustomerBalances();
      });

  Future<void> loadVendorBalances() => _run(() async {
        vendorBalances =
            await repository.getVendorBalances();
      });

  Future<void> loadInventory() => _run(() async {
        inventory = await repository.getInventory();
      });

  Future<void> loadItemSales() => _run(() async {
        itemSales = await repository.getItemSales(
          fromDate: fromDate,
          toDate: toDate,
        );
      });

  Future<void> loadItemPurchases() => _run(() async {
        itemPurchases =
            await repository.getItemPurchases(
          fromDate: fromDate,
          toDate: toDate,
        );
      });

  Future<void> loadProfit() => _run(() async {
        profits = await repository.getProfit(
          fromDate: fromDate,
          toDate: toDate,
        );
      });

  Future<void> loadDailySummary({
    String? date,
  }) =>
      _run(() async {
        selectedDailyDate = date;
        dailySummary = await repository.getDailySummary(
          date: date,
        );
      });

  Future<void> loadAllReports() => _run(() async {
        final results = await Future.wait<dynamic>([
          repository.getSales(
            fromDate: fromDate,
            toDate: toDate,
          ),
          repository.getPurchases(
            fromDate: fromDate,
            toDate: toDate,
          ),
          repository.getCustomerPayments(
            fromDate: fromDate,
            toDate: toDate,
          ),
          repository.getVendorPayments(
            fromDate: fromDate,
            toDate: toDate,
          ),
          repository.getCustomerBalances(),
          repository.getVendorBalances(),
          repository.getInventory(),
          repository.getItemSales(
            fromDate: fromDate,
            toDate: toDate,
          ),
          repository.getItemPurchases(
            fromDate: fromDate,
            toDate: toDate,
          ),
          repository.getProfit(
            fromDate: fromDate,
            toDate: toDate,
          ),
        ]);

        sales = results[0] as List<ReportModel>;
        purchases = results[1] as List<ReportModel>;
        customerPayments = results[2] as List<ReportModel>;
        vendorPayments = results[3] as List<ReportModel>;
        customerBalances = results[4] as List<ReportModel>;
        vendorBalances = results[5] as List<ReportModel>;
        inventory = results[6] as List<ReportModel>;
        itemSales = results[7] as List<ReportModel>;
        itemPurchases = results[8] as List<ReportModel>;
        profits = results[9] as List<ReportModel>;
      });
}
