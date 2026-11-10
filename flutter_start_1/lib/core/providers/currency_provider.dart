import 'package:flutter/foundation.dart';

import '../models/currency_model.dart';
import '../repositories/currency_repository.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyRepository repository;

  CurrencyProvider({
    required this.repository,
  });

  // ============================================================
  // STATE
  // ============================================================

  List<CurrencyModel> _currencies = [];

  bool _isLoading = false;

  String? _errorMessage;

  // Prevent multiple requests at the same time
  bool _isLoadingCurrencies = false;

  // ============================================================
  // GETTERS
  // ============================================================

  List<CurrencyModel> get currencies => _currencies;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // LOADING
  // ============================================================

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }

  // ============================================================
  // LOAD CURRENCIES
  // ============================================================

  Future<void> loadCurrencies({
    bool forceRefresh = false,
  }) async {
    // Don't make another request if one is already running
    if (_isLoadingCurrencies) {
      return;
    }

    // If currencies already exist, don't reload unnecessarily
    if (_currencies.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingCurrencies = true;

    _errorMessage = null;

    _setLoading(true);

    try {
      final currencies = await repository.getCurrencies();

      _currencies = currencies;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingCurrencies = false;

      _setLoading(false);
    }
  }

  // ============================================================
  // CREATE CURRENCY
  // ============================================================

  Future<bool> createCurrency({
    required String currencyName,
    required String currencyCode,
    required String symbol,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final currency = await repository.createCurrency(
        currencyName: currencyName,
        currencyCode: currencyCode,
        symbol: symbol,
      );

      _currencies.insert(0, currency);

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // UPDATE CURRENCY
  // ============================================================

  Future<bool> updateCurrency({
    required int currencyId,
    required String currencyName,
    required String currencyCode,
    required String symbol,
  }) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      final updatedCurrency =
          await repository.updateCurrency(
        currencyId: currencyId,
        currencyName: currencyName,
        currencyCode: currencyCode,
        symbol: symbol,
      );

      final index = _currencies.indexWhere(
        (currency) =>
            currency.currencyId == currencyId,
      );

      if (index != -1) {
        _currencies[index] = updatedCurrency;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // DELETE CURRENCY
  // ============================================================

  Future<bool> deleteCurrency(
    int currencyId,
  ) async {
    _errorMessage = null;

    _setLoading(true);

    try {
      await repository.deleteCurrency(currencyId);

      _currencies.removeWhere(
        (currency) =>
            currency.currencyId == currencyId,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }
    void clear() {
    _currencies.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}