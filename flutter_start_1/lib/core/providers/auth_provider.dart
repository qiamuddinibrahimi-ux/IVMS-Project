import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../storage/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({
    required this.repository,
  });

  // ======================================================
  // STATE
  // ======================================================

  UserModel? _user;

  bool _isLoading = false;

  String? _errorMessage;

  // ======================================================
  // GETTERS
  // ======================================================

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;

  // ======================================================
  // LOADING
  // ======================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ======================================================
  // REGISTER
  // ======================================================

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _user = await repository.register(
        name: name,
        email: email,
        password: password,
      );

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // LOGIN
  // ======================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _user = await repository.login(
        email: email,
        password: password,
      );

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // RESTORE USER SESSION
  // ======================================================

 Future<bool> restoreUserSession() async {
  _setLoading(true);
  _errorMessage = null;

  try {
    final token = await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      _user = null;
      return false;
    }

    // getMe() uses ApiClient — which now auto-refreshes on 401
    _user = await repository.getMe();
    return true;
  } catch (error) {
    _user = null;
    await StorageService.removeUserTokens();
    _errorMessage = error
        .toString()
        .replaceFirst("Exception: ", "");
    return false;
  } finally {
    _setLoading(false);
  }
}

  // ======================================================
  // REFRESH ACCESS TOKEN
  // ======================================================

  Future<bool> refreshAccessToken() async {
    try {
      await repository.refreshAccessToken();

      // IMPORTANT:
      // Refreshing the token alone does not populate _user.
      // Load the current user after refreshing.

      _user = await repository.getMe();

      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (error) {
      _user = null;

      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    }
  }

  // ======================================================
  // UPDATE PROFILE
  // ======================================================

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _user = await repository.updateProfile(
        name: name,
        email: email,
      );

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // CHANGE PASSWORD
  // ======================================================

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.logout();

      _user = null;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      // Even if backend logout fails,
      // remove the local session.
      await StorageService.removeUserTokens();

      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // LOGOUT ALL DEVICES
  // ======================================================

  Future<bool> logoutAll() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.logoutAll();

      _user = null;

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // CLEAR ERROR
  // ======================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}