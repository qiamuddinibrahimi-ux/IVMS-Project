class VendorModel {
  final int vendorId;
  final String vendorName;
  final String? phone;
  final String? email;
  final String? address;

  VendorModel({
    required this.vendorId,
    required this.vendorName,
    this.phone,
    this.email,
    this.address,
  });

  factory VendorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VendorModel(
      vendorId: int.parse(
        json['vendor_id'].toString(),
      ),
      vendorName:
          json['vendor_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}