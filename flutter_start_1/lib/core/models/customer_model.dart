class CustomerModel {
  final int customerId;
  final String customerName;
  final String phone;
  final String email;
  final String address;

  CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory CustomerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerModel(
      customerId: json["customer_id"],
      customerName:
          json["customer_name"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
    );
  }

  CustomerModel copyWith({
    int? customerId,
    String? customerName,
    String? phone,
    String? email,
    String? address,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}