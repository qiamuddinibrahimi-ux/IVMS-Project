import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../storage/storage_service.dart';

class AuthRepository {
  final AuthService authService;
  final UserService userService;

  AuthRepository({
    required this.authService,
    required this.userService,
  });

  // ======================================================
  // REGISTER
  // ======================================================

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await authService.register(
      name: name,
      email: email,
      password: password,
    );

  

    final userJson = response["user"];
    if (userJson == null || userJson is! Map) {
      throw Exception("User information was not returned.");
    }

    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  // ======================================================
  // LOGIN (matches authController.login flat response)
  // ======================================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await authService.login(
      email: email,
      password: password,
    );

   

    // Flat response: { success, message, accessToken, refreshToken, user }
    final accessToken = response["accessToken"];
    final refreshToken = response["refreshToken"];
    final userJson = response["user"];

    if (accessToken == null || accessToken.toString().isEmpty) {
      throw Exception("Access token was not returned.");
    }
    if (refreshToken == null || refreshToken.toString().isEmpty) {
      throw Exception("Refresh token was not returned.");
    }
    if (userJson == null || userJson is! Map) {
      throw Exception("User information was not returned.");
    }

    await StorageService.saveUserTokens(
      accessToken: accessToken.toString(),
      refreshToken: refreshToken.toString(),
    );

    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  // ======================================================
  // GET ME
  // ======================================================

  Future<UserModel> getMe() async {
    final token = await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("User is not logged in.");
    }

    final response = await userService.getMe(accessToken: token);

    

    // userService typically returns { success, user } (flat)
    final userJson = response["user"];

    if (userJson == null || userJson is! Map) {
      throw Exception("User information was not returned.");
    }

    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  // ======================================================
  // UPDATE PROFILE
  // ======================================================

  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final token = await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("User is not logged in.");
    }

    final response = await userService.updateMe(
      accessToken: token,
      name: name,
      email: email,
    );

    final userJson = response["user"];

    if (userJson == null || userJson is! Map) {
      throw Exception("Updated user information was not returned.");
    }

    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  // ======================================================
  // CHANGE PASSWORD
  // ======================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception("User is not logged in.");
    }

    await userService.changePassword(
      accessToken: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  // ======================================================
  // REFRESH ACCESS TOKEN (matches authController.refreshToken)
  // ======================================================

  Future<String> refreshAccessToken() async {
    final refreshToken = await StorageService.getUserRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception("Refresh token is not available.");
    }

    final response = await authService.refreshToken(
      refreshToken: refreshToken,
    );

    

    // Flat response: { success, accessToken }
    final newAccessToken = response["accessToken"];

    if (newAccessToken == null || newAccessToken.toString().isEmpty) {
      throw Exception("New access token was not returned.");
    }

    // Backend does NOT rotate refresh token — keep the old one.
    await StorageService.saveUserTokens(
      accessToken: newAccessToken.toString(),
      refreshToken: refreshToken,
    );

    return newAccessToken.toString();
  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> logout() async {
    final refreshToken = await StorageService.getUserRefreshToken();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await authService.logout(refreshToken: refreshToken);
      } catch (_) {
        // Local logout still runs even if server errors.
      }
    }

    await StorageService.removeUserTokens();
  }

  // ======================================================
  // LOGOUT ALL
  // ======================================================

  Future<void> logoutAll() async {
    final accessToken = await StorageService.getUserAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("User is not logged in.");
    }

    await authService.logoutAll(accessToken: accessToken);
    await StorageService.removeUserTokens();
  }
}