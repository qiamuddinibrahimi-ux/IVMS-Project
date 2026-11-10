class UserModel {
  final int userId;
  final String name;
  final String email;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? lastLoginAt;

  // ✅ ADDED: Stats fields for Admin User Details Screen
  final int salesCount;
  final int purchasesCount;
  final int customersCount;
  final int vendorsCount;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    
    // Default to 0 so existing API calls don't break
    this.salesCount = 0,
    this.purchasesCount = 0,
    this.customersCount = 0,
    this.vendorsCount = 0,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? stats, // ✅ Added optional stats parameter
  }) {
    return UserModel(
      userId: json["user_id"],
      name: json["name"],
      email: json["email"],
      isActive: json["is_active"] == true || json["is_active"] == 1,
      createdAt: json["created_at"]?.toString(),
      updatedAt: json["updated_at"]?.toString(),
      lastLoginAt: json["last_login_at"]?.toString(),
      
      // ✅ Read from the optional stats parameter if provided
      salesCount: stats?["sales"] ?? 0,
      purchasesCount: stats?["purchases"] ?? 0,
      customersCount: stats?["customers"] ?? 0,
      vendorsCount: stats?["vendors"] ?? 0,
    );
  }
}