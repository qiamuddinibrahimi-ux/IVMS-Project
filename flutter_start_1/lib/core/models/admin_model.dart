class AdminModel {
  final int adminId;
  final String adminName;
  final String email;
  final bool isActive;
  final String? lastLoginAt;
  final String? createdAt;
  final String? updatedAt;

  AdminModel({
    required this.adminId,
    required this.adminName,
    required this.email,
    required this.isActive,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      adminId: json["admin_id"],
      adminName: json["admin_name"],
      email: json["email"],
      isActive: json["is_active"] == true ||
          json["is_active"] == 1,
      lastLoginAt: json["last_login_at"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      updatedAt: json["updated_at"]?.toString(),
    );
  }
}