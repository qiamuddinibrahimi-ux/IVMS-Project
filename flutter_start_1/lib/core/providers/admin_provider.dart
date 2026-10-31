import 'package:flutter/foundation.dart';

import '../models/admin_model.dart';
import '../repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository repository;

  AdminProvider({
    required this.repository,
  });

  AdminModel? _admin;

  bool _isLoading = false;

  String? _errorMessage;

  AdminModel? get admin => _admin;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _admin != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _admin = await repository.login(
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

  Future<bool> loadAdmin() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _admin = await repository.getMe();

      return true;
    } catch (error) {
      _admin = null;

      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? adminName,
    String? email,
  }) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _admin = await repository.updateMe(
        adminName: adminName,
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

  Future<void> logout() async {
    _setLoading(true);

    try {
      await repository.logout();

      _admin = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deactivate() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      await repository.deactivate();

      _admin = null;

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

  Future<bool> deleteAccount() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      await repository.deleteAccount();

      _admin = null;

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}