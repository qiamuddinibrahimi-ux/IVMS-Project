
class InventoryModel {
  final int itemId;
  final String itemName;
  final String? barcode;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final int? unitId;
  final String? unitName;
  final double currentStock;
  final double totalStockIn;
  final double totalStockOut;

  InventoryModel({
    required this.itemId,
    required this.itemName,
    this.barcode,
    this.description,
    this.categoryId,
    this.categoryName,
    this.unitId,
    this.unitName,
    this.currentStock = 0,
    this.totalStockIn = 0,
    this.totalStockOut = 0,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      itemId: _toInt(json['item_id']),
      itemName: json['item_name']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      description: json['description']?.toString(),
      categoryId: _toNullableInt(json['category_id']),
      categoryName: json['category_name']?.toString(),
      unitId: _toNullableInt(json['unit_id']),
      unitName: json['unit_name']?.toString(),
      currentStock: _toDouble(json['current_stock']),
      totalStockIn: _toDouble(json['total_stock_in']),
      totalStockOut: _toDouble(json['total_stock_out']),
    );
  }

  factory InventoryModel.fromLowStockJson(
    Map<String, dynamic> json,
  ) {
    return InventoryModel(
      itemId: _toInt(json['item_id']),
      itemName: json['item_name']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      categoryName: json['category_name']?.toString(),
      unitName: json['unit_name']?.toString(),
      currentStock: _toDouble(json['current_stock']),
    );
  }

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
}
