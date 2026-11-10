import '../models/admin_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../storage/storage_service.dart';

class AdminRepository {
  final AdminService adminService;

  AdminRepository({required this.adminService});

  Future<AdminModel> login({required String email, required String password}) async {
    final response = await adminService.login(email: email, password: password);
    final token = response["accessToken"];
    if (token == null || token.toString().isEmpty) throw Exception("Admin access token was not returned.");
    await StorageService.saveAdminToken(token.toString());
    return AdminModel.fromJson(Map<String, dynamic>.from(response["admin"]));
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await StorageService.getAdminToken();
    if (token == null || token.isEmpty) throw Exception("Admin is not logged in.");
    final response = await adminService.getDashboardStats(token: token);
    return Map<String, dynamic>.from(response["stats"]);
  }

  // ✅ NEW: User Management Repo Methods
  Future<List<UserModel>> getAllUsers() async {
    final token = await StorageService.getAdminToken();
    if (token == null) throw Exception("Admin is not logged in.");
    final response = await adminService.getUsers(token: token);
    final List usersJson = response['users'] ?? [];
    return usersJson.map((u) => UserModel.fromJson(u)).toList();
  }

  Future<UserModel> getUserDetails(int userId) async {
    final token = await StorageService.getAdminToken();
    if (token == null) throw Exception("Admin is not logged in.");
    final response = await adminService.getUserDetails(token: token, userId: userId);
    return UserModel.fromJson(response['user'], stats: response['stats']);
  }

  Future<void> toggleUserStatus(int userId) async {
    final token = await StorageService.getAdminToken();
    if (token == null) throw Exception("Admin is not logged in.");
    await adminService.toggleUserStatus(token: token, userId: userId);
  }

  Future<AdminModel> getMe() async {
    final token = await StorageService.getAdminToken();
    if (token == null || token.isEmpty) throw Exception("Admin is not logged in.");
    final response = await adminService.getMe(token: token);
    return AdminModel.fromJson(Map<String, dynamic>.from(response["admin"]));
  }

  Future<AdminModel> updateMe({String? adminName, String? email}) async {
    final token = await StorageService.getAdminToken();
    if (token == null || token.isEmpty) throw Exception("Admin is not logged in.");
    final response = await adminService.updateMe(token: token, adminName: adminName, email: email);
    return AdminModel.fromJson(Map<String, dynamic>.from(response["admin"]));
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final token = await StorageService.getAdminToken();
    if (token == null || token.isEmpty) throw Exception("Admin is not logged in.");
    await adminService.changePassword(token: token, currentPassword: currentPassword, newPassword: newPassword);
  }

  Future<void> logout() async {
    final token = await StorageService.getAdminToken();
    if (token != null && token.isNotEmpty) {
      try { await adminService.logout(token: token); } catch (_) {}
    }
    await StorageService.removeAdminToken();
  }

  Future<void> deactivate() async {
    final token = await StorageService.getAdminToken();
    if (token == null || token.isEmpty) throw Exception("Admin is not logged in.");
    await adminService.deactivate(token: token);
    await StorageService.removeAdminToken();
  }

  Future<void> deleteAccount() async {
    final token = await StorageService.getAdminToken();
    if (token == null || token.isEmpty) throw Exception("Admin is not logged in.");
    await adminService.deleteAccount(token: token);
    await StorageService.removeAdminToken();
  }
}