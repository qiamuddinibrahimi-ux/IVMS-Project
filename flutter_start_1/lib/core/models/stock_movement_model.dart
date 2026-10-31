
class StockMovementModel {
  final int movementId;
  final int? userId;
  final int itemId;
  final String itemName;
  final String movementType;
  final double quantity;
  final String sourceType;
  final int? sourceId;
  final String? createdAt;

  const StockMovementModel({
    required this.movementId,
    this.userId,
    required this.itemId,
    required this.itemName,
    required this.movementType,
    required this.quantity,
    required this.sourceType,
    this.sourceId,
    this.createdAt,
  });

  factory StockMovementModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StockMovementModel(
      movementId: _toInt(json['movement_id']),
      userId: _toNullableInt(json['user_id']),
      itemId: _toInt(json['item_id']),
      itemName: json['item_name']?.toString() ?? '',
      movementType:
          json['movement_type']?.toString() ?? '',
      quantity: _toDouble(json['quantity']),
      sourceType:
          json['source_type']?.toString() ?? 'ADJUSTMENT',
      sourceId: _toNullableInt(json['source_id']),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movement_id': movementId,
      if (userId != null) 'user_id': userId,
      'item_id': itemId,
      'item_name': itemName,
      'movement_type': movementType,
      'quantity': quantity,
      'source_type': sourceType,
      'source_id': sourceId,
      'created_at': createdAt,
    };
  }

  // Request body for POST and PUT.
  // The backend obtains user_id from authentication.
  Map<String, dynamic> toRequestJson() {
    return {
      'item_id': itemId,
      'movement_type': movementType,
      'quantity': quantity,
      'source_type': sourceType,
      'source_id': sourceId,
    };
  }

  bool get isStockIn => movementType == 'IN';

  bool get isStockOut => movementType == 'OUT';

  static int _toInt(dynamic value) {
    if (value == null) {
      throw const FormatException(
        'Required stock movement ID is missing.',
      );
    }

    if (value is int) return value;

    final parsed = int.tryParse(value.toString());

    if (parsed == null) {
      throw FormatException(
        'Invalid integer value: $value',
      );
    }

    return parsed;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    return _toInt(value);
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      throw const FormatException(
        'Stock movement quantity is missing.',
      );
    }

    if (value is num) return value.toDouble();

    final parsed = double.tryParse(value.toString());

    if (parsed == null || !parsed.isFinite) {
      throw FormatException(
        'Invalid quantity value: $value',
      );
    }

    return parsed;
  }
}
