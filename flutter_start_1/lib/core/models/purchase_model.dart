class PurchaseModel {
  final int purchaseId;
  final int vendorId;
  final String vendorName;
  final int currencyId;
  final String currencyName;
  final String currencyCode;
  final String symbol;
  final String purchaseDate;
  final String invoiceNo;

  PurchaseModel({
    required this.purchaseId,
    required this.vendorId,
    required this.vendorName,
    required this.currencyId,
    required this.currencyName,
    required this.currencyCode,
    required this.symbol,
    required this.purchaseDate,
    required this.invoiceNo,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      purchaseId: int.parse(
        json['purchase_id'].toString(),
      ),
      vendorId: int.parse(
        json['vendor_id'].toString(),
      ),
      vendorName: json['vendor_name']?.toString() ?? '',
      currencyId: int.parse(
        json['currency_id'].toString(),
      ),
      currencyName: json['currency_name']?.toString() ?? '',
      currencyCode: json['currency_code']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      purchaseDate: json['purchase_date']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchase_id': purchaseId,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'currency_id': currencyId,
      'currency_name': currencyName,
      'currency_code': currencyCode,
      'symbol': symbol,
      'purchase_date': purchaseDate,
      'invoice_no': invoiceNo,
    };
  }
}