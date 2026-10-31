class SaleModel {
  final int saleId;

  final int customerId;
  final String customerName;

  final int currencyId;
  final String currencyName;
  final String currencyCode;
  final String symbol;

  final String saleDate;
  final String invoiceNo;

  SaleModel({
    required this.saleId,
    required this.customerId,
    required this.customerName,
    required this.currencyId,
    required this.currencyName,
    required this.currencyCode,
    required this.symbol,
    required this.saleDate,
    required this.invoiceNo,
  });

  factory SaleModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SaleModel(
      saleId: int.parse(
        json['sale_id'].toString(),
      ),

      customerId: int.parse(
        json['customer_id'].toString(),
      ),

      customerName:
          json['customer_name']?.toString() ?? '',

      currencyId: int.parse(
        json['currency_id'].toString(),
      ),

      currencyName:
          json['currency_name']?.toString() ?? '',

      currencyCode:
          json['currency_code']?.toString() ?? '',

      symbol:
          json['symbol']?.toString() ?? '',

      saleDate:
          json['sale_date']?.toString() ?? '',

      invoiceNo:
          json['invoice_no']?.toString() ?? '',
    );
  }
}