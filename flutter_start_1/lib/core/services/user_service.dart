import '../constants/api_constants.dart';
import '../network/api_client.dart';

class UserService {
  final ApiClient apiClient;

  UserService({
    required this.apiClient,
  });

  // ======================================================
  // GET CURRENT USER
  // ======================================================

  Future<Map<String, dynamic>> getMe({
    required String accessToken,
  }) async {
    return await apiClient.get(
      ApiConstants.userMe,
      token: accessToken,
    );
  }

  // ======================================================
  // UPDATE USER PROFILE
  // ======================================================

  Future<Map<String, dynamic>> updateMe({
    required String accessToken,
    required String name,
    required String email,
  }) async {
    return await apiClient.put(
      ApiConstants.userMe,
      token: accessToken,
      body: {
        "name": name,
        "email": email,
      },
    );
  }

  // ======================================================
  // CHANGE USER PASSWORD
  // ======================================================

  Future<Map<String, dynamic>> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await apiClient.put(
      "/users/me/password",
      token: accessToken,
      body: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      },
    );
  }
}