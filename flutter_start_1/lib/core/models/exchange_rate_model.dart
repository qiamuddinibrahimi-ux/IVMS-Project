class ExchangeRateModel {
  final int exchangeRateId;

  final int fromCurrencyId;
  final String fromCurrencyName;
  final String fromCurrencyCode;

  final int toCurrencyId;
  final String toCurrencyName;
  final String toCurrencyCode;

  final double rate;
  final String effectiveDate;
  final String createdAt;

  ExchangeRateModel({
    required this.exchangeRateId,
    required this.fromCurrencyId,
    required this.fromCurrencyName,
    required this.fromCurrencyCode,
    required this.toCurrencyId,
    required this.toCurrencyName,
    required this.toCurrencyCode,
    required this.rate,
    required this.effectiveDate,
    required this.createdAt,
  });

  factory ExchangeRateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExchangeRateModel(
      exchangeRateId:
          int.tryParse(
                json["exchange_rate_id"].toString(),
              ) ??
              0,

      fromCurrencyId:
          int.tryParse(
                json["from_currency_id"].toString(),
              ) ??
              0,

      fromCurrencyName:
          json["from_currency_name"]?.toString() ?? "",

      fromCurrencyCode:
          json["from_currency_code"]?.toString() ?? "",

      toCurrencyId:
          int.tryParse(
                json["to_currency_id"].toString(),
              ) ??
              0,

      toCurrencyName:
          json["to_currency_name"]?.toString() ?? "",

      toCurrencyCode:
          json["to_currency_code"]?.toString() ?? "",

      rate:
          double.tryParse(
                json["rate"].toString(),
              ) ??
              0.0,

      effectiveDate:
          json["effective_date"]?.toString() ?? "",

      createdAt:
          json["created_at"]?.toString() ?? "",
    );
  }
}