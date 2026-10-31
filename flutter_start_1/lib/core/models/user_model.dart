class UserModel {
  final int userId;
  final String name;
  final String email;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? lastLoginAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      userId: json["user_id"],
      name: json["name"],
      email: json["email"],
      isActive:
          json["is_active"] == true ||
          json["is_active"] == 1,
      createdAt:
          json["created_at"]?.toString(),
      updatedAt:
          json["updated_at"]?.toString(),
      lastLoginAt:
          json["last_login_at"]?.toString(),
    );
  }
}