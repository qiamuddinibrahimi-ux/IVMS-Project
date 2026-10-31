
class InventorySummaryModel {
  final int totalItems;
  final double totalCurrentStock;
  final double totalStockIn;
  final double totalStockOut;

  InventorySummaryModel({
    required this.totalItems,
    required this.totalCurrentStock,
    required this.totalStockIn,
    required this.totalStockOut,
  });

  factory InventorySummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventorySummaryModel(
      totalItems: _toInt(json['total_items']),
      totalCurrentStock: _toDouble(
        json['total_current_stock'],
      ),
      totalStockIn: _toDouble(json['total_stock_in']),
      totalStockOut: _toDouble(json['total_stock_out']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
