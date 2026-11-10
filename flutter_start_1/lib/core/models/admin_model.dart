class AdminModel {
  final int adminId;
  final String adminName;
  final String email;
  final bool isActive;
  final String? lastLoginAt;
  final String? createdAt;
  final String? updatedAt;
  
  final int totalUsers;
  final int totalItems;
  final int totalSales;
  final double totalProfit;

  AdminModel({
    required this.adminId,
    required this.adminName,
    required this.email,
    required this.isActive,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
    this.totalUsers = 0,
    this.totalItems = 0,
    this.totalSales = 0,
    this.totalProfit = 0.0,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      adminId: json["admin_id"],
      adminName: json["admin_name"],
      email: json["email"],
      isActive: json["is_active"] == true || json["is_active"] == 1,
      lastLoginAt: json["last_login_at"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      updatedAt: json["updated_at"]?.toString(),
      totalUsers: json["total_users"] ?? 0,
      totalItems: json["total_items"] ?? 0,
      totalSales: json["total_sales"] ?? 0,
      totalProfit: (json["total_profit"] as num?)?.toDouble() ?? 0.0,
    );
  }

  AdminModel copyWithStats({
    int? totalUsers,
    int? totalItems,
    int? totalSales,
    double? totalProfit,
  }) {
    return AdminModel(
      adminId: adminId,
      adminName: adminName,
      email: email,
      isActive: isActive,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalUsers: totalUsers ?? this.totalUsers,
      totalItems: totalItems ?? this.totalItems,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
    );
  }
}