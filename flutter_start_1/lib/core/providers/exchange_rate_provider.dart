import 'package:flutter/foundation.dart';

import '../models/exchange_rate_model.dart';
import '../repositories/exchange_rate_repository.dart';

class ExchangeRateProvider extends ChangeNotifier {
  final ExchangeRateRepository repository;

  ExchangeRateProvider({
    required this.repository,
  });

  // ======================================================
  // STATE
  // ======================================================

  List<ExchangeRateModel> _exchangeRates = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<ExchangeRateModel> get exchangeRates =>
      _exchangeRates;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ======================================================
  // LOAD ALL
  // ======================================================

  Future<void> loadExchangeRates() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _exchangeRates =
          await repository.getExchangeRates();
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ======================================================
  // CREATE
  // ======================================================

  Future<bool> createExchangeRate({
    required int fromCurrencyId,
    required int toCurrencyId,
    required double rate,
    required String effectiveDate,
  }) async {
    _errorMessage = null;

    try {
      final exchangeRate =
          await repository.createExchangeRate(
        fromCurrencyId: fromCurrencyId,
        toCurrencyId: toCurrencyId,
        rate: rate,
        effectiveDate: effectiveDate,
      );

      _exchangeRates.insert(
        0,
        exchangeRate,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst("Exception: ", "");

      notifyListeners();

      return false;
    }
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<bool> updateExchangeRate({
    required int id,
    required int fromCurrencyId,
    required int toCurrencyId,
    required double rate,
    required String effectiveDate,
  }) async {
    _errorMessage = null;

    try {
      final updated =
          await repository.updateExchangeRate(
        id: id,
        fromCurrencyId: fromCurrencyId,
        toCurrencyId: toCurrencyId,
        rate: rate,
        effectiveDate: effectiveDate,
      );

      final index =
          _exchangeRates.indexWhere(
        (item) =>
            item.exchangeRateId == id,
      );

      if (index != -1) {
        _exchangeRates[index] = updated;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst("Exception: ", "");

      notifyListeners();

      return false;
    }
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<bool> deleteExchangeRate(
    int id,
  ) async {
    _errorMessage = null;

    try {
      await repository.deleteExchangeRate(id);

      _exchangeRates.removeWhere(
        (item) =>
            item.exchangeRateId == id,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst("Exception: ", "");

      notifyListeners();

      return false;
    }
  }

  // ======================================================
  // CLEAR ERROR
  // ======================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
    void clear() {
    _exchangeRates.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}