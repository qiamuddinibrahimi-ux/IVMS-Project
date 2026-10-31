class PurchasePaymentModel {
  final int paymentId;

  final int purchaseId;
  final String invoiceNo;
  final String purchaseDate;

  final int vendorId;
  final String vendorName;

  final int currencyId;
  final String currencyName;
  final String currencyCode;
  final String symbol;

  final double amount;
  final String paymentDate;

  PurchasePaymentModel({
    required this.paymentId,
    required this.purchaseId,
    required this.invoiceNo,
    required this.purchaseDate,
    required this.vendorId,
    required this.vendorName,
    required this.currencyId,
    required this.currencyName,
    required this.currencyCode,
    required this.symbol,
    required this.amount,
    required this.paymentDate,
  });

  factory PurchasePaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchasePaymentModel(
      paymentId:
          int.parse(json['payment_id'].toString()),

      purchaseId:
          int.parse(json['purchase_id'].toString()),

      invoiceNo:
          json['invoice_no']?.toString() ?? '',

      purchaseDate:
          json['purchase_date']?.toString() ?? '',

      vendorId:
          int.parse(json['vendor_id'].toString()),

      vendorName:
          json['vendor_name']?.toString() ?? '',

      currencyId:
          int.parse(json['currency_id'].toString()),

      currencyName:
          json['currency_name']?.toString() ?? '',

      currencyCode:
          json['currency_code']?.toString() ?? '',

      symbol:
          json['symbol']?.toString() ?? '',

      amount:
          double.tryParse(
                json['amount'].toString(),
              ) ??
              0.0,

      paymentDate:
          json['payment_date']?.toString() ?? '',
    );
  }
}