
class SalesDetailModel {
  final int saleDetailId;
  final int saleId;
  final int itemId;
  final double quantity;
  final double unitPrice;
  final String itemName;

  const SalesDetailModel({
    required this.saleDetailId,
    required this.saleId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.itemName,
  });

  double get lineTotal => quantity * unitPrice;

  factory SalesDetailModel.fromJson(Map<String, dynamic> json) {
    return SalesDetailModel(
      saleDetailId: _toInt(json['sale_detail_id']),
      saleId: _toInt(json['sale_id']),
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
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  factory SalesDetailModel.fromAny(dynamic value) {
    if (value is Map) {
      return SalesDetailModel.fromJson(
        Map<String, dynamic>.from(value),
      );
    }

    throw const FormatException(
      'Invalid sales detail record.',
    );
  }
}
