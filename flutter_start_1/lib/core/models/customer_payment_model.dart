class CustomerPaymentModel {
  final int customerPaymentId;

  final int customerId;
  final String customerName;

  final int saleId;
  final String invoiceNo;
  final String saleDate;

  final int currencyId;
  final String currencyName;
  final String currencyCode;
  final String symbol;

  final double amount;
  final String paymentDate;

  CustomerPaymentModel({
    required this.customerPaymentId,
    required this.customerId,
    required this.customerName,
    required this.saleId,
    required this.invoiceNo,
    required this.saleDate,
    required this.currencyId,
    required this.currencyName,
    required this.currencyCode,
    required this.symbol,
    required this.amount,
    required this.paymentDate,
  });

  factory CustomerPaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerPaymentModel(
      customerPaymentId:
          int.parse(json["customer_payment_id"].toString()),

      customerId:
          int.parse(json["customer_id"].toString()),

      customerName:
          json["customer_name"]?.toString() ?? "",

      saleId:
          int.parse(json["sale_id"].toString()),

      invoiceNo:
          json["invoice_no"]?.toString() ?? "",

      saleDate:
          json["sale_date"]?.toString() ?? "",

      currencyId:
          int.parse(json["currency_id"].toString()),

      currencyName:
          json["currency_name"]?.toString() ?? "",

      currencyCode:
          json["currency_code"]?.toString() ?? "",

      symbol:
          json["symbol"]?.toString() ?? "",

      amount:
          double.tryParse(
                json["amount"].toString(),
              ) ??
              0.0,

      paymentDate:
          json["payment_date"]?.toString() ?? "",
    );
  }

  CustomerPaymentModel copyWith({
    int? customerPaymentId,
    int? customerId,
    String? customerName,
    int? saleId,
    String? invoiceNo,
    String? saleDate,
    int? currencyId,
    String? currencyName,
    String? currencyCode,
    String? symbol,
    double? amount,
    String? paymentDate,
  }) {
    return CustomerPaymentModel(
      customerPaymentId:
          customerPaymentId ??
              this.customerPaymentId,

      customerId:
          customerId ?? this.customerId,

      customerName:
          customerName ?? this.customerName,

      saleId:
          saleId ?? this.saleId,

      invoiceNo:
          invoiceNo ?? this.invoiceNo,

      saleDate:
          saleDate ?? this.saleDate,

      currencyId:
          currencyId ?? this.currencyId,

      currencyName:
          currencyName ?? this.currencyName,

      currencyCode:
          currencyCode ?? this.currencyCode,

      symbol:
          symbol ?? this.symbol,

      amount:
          amount ?? this.amount,

      paymentDate:
          paymentDate ?? this.paymentDate,
    );
  }
}