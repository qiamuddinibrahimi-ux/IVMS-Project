class CurrencyModel {
  final int currencyId;
  final String currencyName;
  final String currencyCode;
  final String symbol;

  CurrencyModel({
    required this.currencyId,
    required this.currencyName,
    required this.currencyCode,
    required this.symbol,
  });

  factory CurrencyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CurrencyModel(
      currencyId: json["currency_id"],
      currencyName:
          json["currency_name"]?.toString() ?? "",
      currencyCode:
          json["currency_code"]?.toString() ?? "",
      symbol:
          json["symbol"]?.toString() ?? "",
    );
  }

  CurrencyModel copyWith({
    int? currencyId,
    String? currencyName,
    String? currencyCode,
    String? symbol,
  }) {
    return CurrencyModel(
      currencyId: currencyId ?? this.currencyId,
      currencyName: currencyName ?? this.currencyName,
      currencyCode: currencyCode ?? this.currencyCode,
      symbol: symbol ?? this.symbol,
    );
  }
}