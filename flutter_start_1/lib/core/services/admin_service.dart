import '../network/api_client.dart';
import '../constants/api_constants.dart';

class AdminService {
  final ApiClient apiClient;

  AdminService({required this.apiClient});

  Future<Map<String, dynamic>> getDashboardStats({required String token}) async {
    return await apiClient.get(ApiConstants.adminStats, token: token);
  }

  // ✅ NEW: User Management Service Methods
  Future<Map<String, dynamic>> getUsers({required String token}) async {
    return await apiClient.get(ApiConstants.adminUsers, token: token);
  }

  Future<Map<String, dynamic>> getUserDetails({required String token, required int userId}) async {
    return await apiClient.get(ApiConstants.adminUserDetails(userId), token: token);
  }

  Future<Map<String, dynamic>> toggleUserStatus({required String token, required int userId}) async {
    return await apiClient.patch(ApiConstants.adminUserToggleStatus(userId), token: token);
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    return await apiClient.post(ApiConstants.adminLogin, body: {"email": email, "password": password});
  }

  Future<Map<String, dynamic>> getMe({required String token}) async {
    return await apiClient.get(ApiConstants.adminMe, token: token);
  }

  Future<Map<String, dynamic>> updateMe({required String token, String? adminName, String? email}) async {
    final body = <String, dynamic>{};
    if (adminName != null) body["admin_name"] = adminName;
    if (email != null) body["email"] = email;
    return await apiClient.put(ApiConstants.adminMe, body: body, token: token);
  }

  Future<Map<String, dynamic>> changePassword({required String token, required String currentPassword, required String newPassword}) async {
    return await apiClient.put(ApiConstants.adminChangePassword, body: {"currentPassword": currentPassword, "newPassword": newPassword}, token: token);
  }

  Future<Map<String, dynamic>> deactivate({required String token}) async {
    return await apiClient.patch(ApiConstants.adminDeactivate, token: token);
  }

  Future<Map<String, dynamic>> deleteAccount({required String token}) async {
    return await apiClient.delete(ApiConstants.adminMe, token: token);
  }

  Future<Map<String, dynamic>> logout({required String token}) async {
    return await apiClient.post(ApiConstants.adminLogout, token: token);
  }
}