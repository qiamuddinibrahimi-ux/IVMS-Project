import '../models/admin_model.dart';
import '../services/admin_service.dart';
import '../storage/storage_service.dart';

class AdminRepository {
  final AdminService adminService;

  AdminRepository({
    required this.adminService,
  });

  Future<AdminModel> login({
    required String email,
    required String password,
  }) async {
    final response = await adminService.login(
      email: email,
      password: password,
    );

    final token = response["accessToken"];

    if (token == null || token.toString().isEmpty) {
      throw Exception(
        "Admin access token was not returned.",
      );
    }

    await StorageService.saveAdminToken(
      token.toString(),
    );

    return AdminModel.fromJson(
      Map<String, dynamic>.from(
        response["admin"],
      ),
    );
  }

  Future<AdminModel> getMe() async {
    final token = await StorageService.getAdminToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "Admin is not logged in.",
      );
    }

    final response = await adminService.getMe(
      token: token,
    );

    return AdminModel.fromJson(
      Map<String, dynamic>.from(
        response["admin"],
      ),
    );
  }

  Future<AdminModel> updateMe({
    String? adminName,
    String? email,
  }) async {
    final token = await StorageService.getAdminToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "Admin is not logged in.",
      );
    }

    final response = await adminService.updateMe(
      token: token,
      adminName: adminName,
      email: email,
    );

    return AdminModel.fromJson(
      Map<String, dynamic>.from(
        response["admin"],
      ),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await StorageService.getAdminToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "Admin is not logged in.",
      );
    }

    await adminService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    final token = await StorageService.getAdminToken();

    if (token != null && token.isNotEmpty) {
      try {
        await adminService.logout(
          token: token,
        );
      } catch (_) {
        // Even if server logout fails,
        // remove the local token.
      }
    }

    await StorageService.removeAdminToken();
  }

  Future<void> deactivate() async {
    final token = await StorageService.getAdminToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "Admin is not logged in.",
      );
    }

    await adminService.deactivate(
      token: token,
    );

    await StorageService.removeAdminToken();
  }

  Future<void> deleteAccount() async {
    final token = await StorageService.getAdminToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "Admin is not logged in.",
      );
    }

    await adminService.deleteAccount(
      token: token,
    );

    await StorageService.removeAdminToken();
  }
}