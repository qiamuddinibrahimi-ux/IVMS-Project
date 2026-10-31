
import 'package:flutter/foundation.dart';

import '../models/purchase_detail_model.dart';
import '../services/purchase_detail_service.dart';

class PurchaseDetailProvider extends ChangeNotifier {
  final PurchaseDetailService service;

  PurchaseDetailProvider({
    required this.service,
  });

  List<PurchaseDetailModel> _details = [];

  List<PurchaseDetailModel> get details =>
      List.unmodifiable(_details);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setError(Object error) {
    _errorMessage = error.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }

  Future<void> loadDetails({
    required String token,
    int? purchaseId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _details = await service.getPurchaseDetails(
        token: token,
        purchaseId: purchaseId,
      );
    } catch (error) {
      _setError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveDetail({
    required String token,
    int? detailId,
    required int purchaseId,
    required int itemId,
    required double quantity,
    required double unitPrice,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (detailId == null) {
        await service.createPurchaseDetail(
          token: token,
          purchaseId: purchaseId,
          itemId: itemId,
          quantity: quantity,
          unitPrice: unitPrice,
        );
      } else {
        await service.updatePurchaseDetail(
          token: token,
          detailId: detailId,
          purchaseId: purchaseId,
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

  Future<bool> removeDetail({
    required String token,
    required int detailId,
  }) async {
    _errorMessage = null;

    try {
      await service.deletePurchaseDetail(
        token: token,
        detailId: detailId,
      );

      _details = _details
          .where((detail) =>
              detail.purchaseDetailId != detailId)
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
