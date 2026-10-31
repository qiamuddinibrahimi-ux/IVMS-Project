import '../constants/api_constants.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({
    required this.apiClient,
  });

  // ======================================================
  // REGISTER
  // ======================================================

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await apiClient.post(
      ApiConstants.userRegister,
      body: {
        "name": name,
        "email": email,
        "password": password,
      },
    );
  }

  // ======================================================
  // LOGIN
  // ======================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await apiClient.post(
      ApiConstants.userLogin,
      body: {
        "email": email,
        "password": password,
      },
    );
  }

  // ======================================================
  // REFRESH ACCESS TOKEN
  // ======================================================

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    return await apiClient.post(
      ApiConstants.userRefresh,
      body: {
        "refreshToken": refreshToken,
      },
    );
  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<Map<String, dynamic>> logout({
    required String refreshToken,
  }) async {
    return await apiClient.post(
      ApiConstants.userLogout,
      body: {
        "refreshToken": refreshToken,
      },
    );
  }

  // ======================================================
  // LOGOUT ALL DEVICES
  // ======================================================

  Future<Map<String, dynamic>> logoutAll({
    required String accessToken,
  }) async {
    return await apiClient.post(
      ApiConstants.userLogoutAll,
      token: accessToken,
    );
  }
}