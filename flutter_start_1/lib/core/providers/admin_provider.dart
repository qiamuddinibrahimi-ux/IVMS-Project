import 'package:flutter/foundation.dart';
import '../models/admin_model.dart';
import '../models/user_model.dart';
import '../repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository repository;

  AdminProvider({required this.repository});

  AdminModel? _admin;
  List<UserModel> _users = [];

  bool _isLoading = false;
  String? _errorMessage;

  AdminModel? get admin => _admin;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _admin != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _admin = await repository.login(email: email, password: password);
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
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
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDashboardStats() async {
    if (_admin == null) _setLoading(true);
    _errorMessage = null;
    try {
      final stats = await repository.getDashboardStats();
      if (_admin != null) {
        _admin = _admin!.copyWithStats(
          totalUsers: stats["total_users"] ?? 0,
          totalItems: stats["total_items"] ?? 0,
          totalSales: stats["total_sales"] ?? 0,
          totalProfit: (stats["total_profit"] as num?)?.toDouble() ?? 0.0,
        );
      }
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
      notifyListeners();
    } finally {
      if (_admin == null) _setLoading(false);
    }
  }

  // ✅ NEW: User Management Methods
  Future<void> loadAllUsers() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _users = await repository.getAllUsers();
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({String? adminName, String? email}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _admin = await repository.updateMe(adminName: adminName, email: email);
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
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
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
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
      _errorMessage = error.toString().replaceFirst("Exception: ", "");
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