
class SalesPurchaseAllocationModel {
  final int allocationId;
  final int saleDetailId;
  final int purchaseDetailId;
  final int itemId;
  final String itemName;
  final double allocatedQuantity;

  final int? saleId;
  final String saleInvoiceNo;
  final String saleDate;
  final double saleQuantity;
  final double? saleUnitPrice;

  final int? purchaseId;
  final String purchaseInvoiceNo;
  final String purchaseDate;
  final double purchaseQuantity;
  final double? purchaseUnitPrice;

  const SalesPurchaseAllocationModel({
    required this.allocationId,
    required this.saleDetailId,
    required this.purchaseDetailId,
    required this.itemId,
    required this.itemName,
    required this.allocatedQuantity,
    this.saleId,
    this.saleInvoiceNo = '',
    this.saleDate = '',
    this.saleQuantity = 0,
    this.saleUnitPrice,
    this.purchaseId,
    this.purchaseInvoiceNo = '',
    this.purchaseDate = '',
    this.purchaseQuantity = 0,
    this.purchaseUnitPrice,
  });

  factory SalesPurchaseAllocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalesPurchaseAllocationModel(
      allocationId: _toInt(json['allocation_id']),
      saleDetailId: _toInt(json['sale_detail_id']),
      purchaseDetailId: _toInt(json['purchase_detail_id']),
      itemId: _toInt(json['item_id']),
      itemName: json['item_name']?.toString() ?? '',
      allocatedQuantity: _toDouble(
        json['allocated_quantity'],
      ),
      saleId: _toNullableInt(json['sale_id']),
      saleInvoiceNo:
          json['sale_invoice_no']?.toString() ?? '',
      saleDate: json['sale_date']?.toString() ?? '',
      saleQuantity: _toDouble(json['sale_quantity']),
      saleUnitPrice: json['sale_unit_price'] == null
          ? null
          : _toDouble(json['sale_unit_price']),
      purchaseId: _toNullableInt(json['purchase_id']),
      purchaseInvoiceNo:
          json['purchase_invoice_no']?.toString() ?? '',
      purchaseDate:
          json['purchase_date']?.toString() ?? '',
      purchaseQuantity: _toDouble(
        json['purchase_quantity'],
      ),
      purchaseUnitPrice:
          json['purchase_unit_price'] == null
              ? null
              : _toDouble(json['purchase_unit_price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allocation_id': allocationId,
      'sale_detail_id': saleDetailId,
      'purchase_detail_id': purchaseDetailId,
      'item_id': itemId,
      'item_name': itemName,
      'allocated_quantity': allocatedQuantity,
      'sale_id': saleId,
      'sale_invoice_no': saleInvoiceNo,
      'sale_date': saleDate,
      'sale_quantity': saleQuantity,
      'sale_unit_price': saleUnitPrice,
      'purchase_id': purchaseId,
      'purchase_invoice_no': purchaseInvoiceNo,
      'purchase_date': purchaseDate,
      'purchase_quantity': purchaseQuantity,
      'purchase_unit_price': purchaseUnitPrice,
    };
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

// ======================================================
// SALES DETAIL DROPDOWN MODEL
// ======================================================

class SaleDetailOptionModel {
  final int saleDetailId;
  final int saleId;
  final String invoiceNo;
  final String saleDate;
  final int itemId;
  final String itemName;
  final double saleQuantity;
  final double unitPrice;
  final double allocatedQuantity;
  final double remainingQuantity;

  const SaleDetailOptionModel({
    required this.saleDetailId,
    required this.saleId,
    required this.invoiceNo,
    required this.saleDate,
    required this.itemId,
    required this.itemName,
    required this.saleQuantity,
    required this.unitPrice,
    required this.allocatedQuantity,
    required this.remainingQuantity,
  });

  factory SaleDetailOptionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SaleDetailOptionModel(
      saleDetailId: _toInt(json['sale_detail_id']),
      saleId: _toInt(json['sale_id']),
      invoiceNo: json['invoice_no']?.toString() ?? '',
      saleDate: json['sale_date']?.toString() ?? '',
      itemId: _toInt(json['item_id']),
      itemName: json['item_name']?.toString() ?? '',
      saleQuantity: _toDouble(json['sale_quantity']),
      unitPrice: _toDouble(json['unit_price']),
      allocatedQuantity: _toDouble(
        json['allocated_quantity'],
      ),
      remainingQuantity: _toDouble(
        json['remaining_quantity'],
      ),
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

// ======================================================
// PURCHASE DETAIL DROPDOWN MODEL
// ======================================================

class PurchaseDetailOptionModel {
  final int purchaseDetailId;
  final int purchaseId;
  final String invoiceNo;
  final String purchaseDate;
  final int itemId;
  final String itemName;
  final double purchaseQuantity;
  final double unitPrice;
  final double allocatedQuantity;
  final double remainingQuantity;

  const PurchaseDetailOptionModel({
    required this.purchaseDetailId,
    required this.purchaseId,
    required this.invoiceNo,
    required this.purchaseDate,
    required this.itemId,
    required this.itemName,
    required this.purchaseQuantity,
    required this.unitPrice,
    required this.allocatedQuantity,
    required this.remainingQuantity,
  });

  factory PurchaseDetailOptionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseDetailOptionModel(
      purchaseDetailId: _toInt(json['purchase_detail_id']),
      purchaseId: _toInt(json['purchase_id']),
      invoiceNo: json['invoice_no']?.toString() ?? '',
      purchaseDate: json['purchase_date']?.toString() ?? '',
      itemId: _toInt(json['item_id']),
      itemName: json['item_name']?.toString() ?? '',
      purchaseQuantity: _toDouble(
        json['purchase_quantity'],
      ),
      unitPrice: _toDouble(json['unit_price']),
      allocatedQuantity: _toDouble(
        json['allocated_quantity'],
      ),
      remainingQuantity: _toDouble(
        json['remaining_quantity'],
      ),
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
