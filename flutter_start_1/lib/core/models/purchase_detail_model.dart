
class PurchaseDetailModel {
  final int purchaseDetailId;
  final int purchaseId;
  final int itemId;
  final double quantity;
  final double unitPrice;
  final String itemName;

  const PurchaseDetailModel({
    required this.purchaseDetailId,
    required this.purchaseId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.itemName,
  });

  double get lineTotal => quantity * unitPrice;

  factory PurchaseDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseDetailModel(
      purchaseDetailId:
          _toInt(json['purchase_detail_id']),
      purchaseId: _toInt(json['purchase_id']),
      itemId: _toInt(json['item_id']),
      quantity: _toDouble(json['quantity']),
      unitPrice: _toDouble(json['unit_price']),
      itemName: json['item_name']?.toString() ?? 'Unknown item',
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory PurchaseDetailModel.fromAny(dynamic value) {
    if (value is Map) {
      return PurchaseDetailModel.fromJson(
        Map<String, dynamic>.from(value),
      );
    }
    throw const FormatException(
      'Invalid purchase detail record.',
    );
  }
}
