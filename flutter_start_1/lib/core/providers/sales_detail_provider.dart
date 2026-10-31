
import 'package:flutter/foundation.dart';

import '../models/sales_detail_model.dart';
import '../services/sales_detail_service.dart';

class SalesDetailProvider extends ChangeNotifier {
  final SalesDetailService service;

  SalesDetailProvider({
    required this.service,
  });

  List<SalesDetailModel> _details = [];

  List<SalesDetailModel> get details =>
      List.unmodifiable(_details);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setError(Object error) {
    _errorMessage = error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  // READ ALL
  Future<void> loadDetails({
    required String token,
    int? saleId,
    int? itemId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _details = await service.getSalesDetails(
        token: token,
        saleId: saleId,
        itemId: itemId,
      );
    } catch (error) {
      _setError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE OR UPDATE
  Future<bool> saveDetail({
    required String token,
    int? detailId,
    required int saleId,
    required int itemId,
    required double quantity,
    required double unitPrice,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (detailId == null) {
        await service.createSalesDetail(
          token: token,
          saleId: saleId,
          itemId: itemId,
          quantity: quantity,
          unitPrice: unitPrice,
        );
      } else {
        await service.updateSalesDetail(
          token: token,
          detailId: detailId,
          saleId: saleId,
          itemId: itemId,
          quantity: quantity,
          unitPrice: unitPrice,
        );
      }

      await loadDetails(token: token);

      return _errorMessage == null;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<bool> removeDetail({
    required String token,
    required int detailId,
  }) async {
    _errorMessage = null;

    try {
      await service.deleteSalesDetail(
        token: token,
        detailId: detailId,
      );

      _details = _details
          .where(
            (detail) => detail.saleDetailId != detailId,
          )
          .toList();

      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      notifyListeners();
      return false;
    }
  }
}
