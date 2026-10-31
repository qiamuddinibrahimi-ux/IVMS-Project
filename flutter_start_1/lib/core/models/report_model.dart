
class ReportModel {
  final Map<String, dynamic> data;

  const ReportModel(this.data);

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(Map<String, dynamic>.from(json));
  }

  String getString(String key, {String fallback = ''}) {
    final value = data[key];

    if (value == null) return fallback;

    return value.toString();
  }

  int getInt(String key, {int fallback = 0}) {
    final value = data[key];

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

double? getDouble(String key) {
  final value = data[key];

  if (value == null) return null;

  if (value is num) {
    return value.toDouble();
  }

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }

  return double.tryParse(text);
}

  bool get hasValidAmount => data['gross_profit'] != null;

  String get currencyCode => getString('currency_code');

  String get currencySymbol => getString(
        'currency_symbol',
        fallback: currencyCode,
      );

  String get calculationStatus => getString(
        'calculation_status',
        fallback: 'UNKNOWN',
      );

  factory ReportModel.fromAny(dynamic value) {
    if (value is Map<String, dynamic>) {
      return ReportModel.fromJson(value);
    }

    if (value is Map) {
      return ReportModel.fromJson(
        Map<String, dynamic>.from(value),
      );
    }

    throw const FormatException(
      'Invalid report record: expected a JSON object.',
    );
  }
}
