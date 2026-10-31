
class InventoryMovementModel {
  final int movementId;
  final int itemId;
  final String itemName;
  final String? barcode;
  final String movementType;
  final double quantity;
  final String sourceType;
  final int? sourceId;
  final DateTime? createdAt;

  InventoryMovementModel({
    required this.movementId,
    required this.itemId,
    required this.itemName,
    this.barcode,
    required this.movementType,
    required this.quantity,
    required this.sourceType,
    this.sourceId,
    this.createdAt,
  });

  factory InventoryMovementModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventoryMovementModel(
      movementId: _toInt(json['movement_id']),
      itemId: _toInt(json['item_id']),
      itemName: json['item_name']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      movementType: json['movement_type']?.toString() ?? '',
      quantity: _toDouble(json['quantity']),
      sourceType: json['source_type']?.toString() ?? '',
      sourceId: _toNullableInt(json['source_id']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  bool get isStockIn => movementType == 'IN';

  bool get isAdjustment => sourceType == 'ADJUSTMENT';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
