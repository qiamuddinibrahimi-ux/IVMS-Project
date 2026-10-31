import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository repository;

  CategoryProvider({
    required this.repository,
  });

  List<CategoryModel> _categories = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<CategoryModel> get categories =>
      _categories;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

  // ======================================================
  // LOAD CATEGORIES
  // ======================================================

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _categories =
          await repository.getCategories();
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // CREATE CATEGORY
  // ======================================================

  Future<bool> createCategory({
    required String categoryName,
  }) async {
    _errorMessage = null;

    try {
      final category =
          await repository.createCategory(
        categoryName: categoryName,
      );

      _categories.insert(0, category);

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      notifyListeners();

      return false;
    }
  }

  // ======================================================
  // GET CATEGORY BY ID
  // ======================================================

  Future<CategoryModel?> getCategoryById(
    int categoryId,
  ) async {
    _errorMessage = null;

    try {
      return await repository.getCategoryById(
        categoryId: categoryId,
      );
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      notifyListeners();

      return null;
    }
  }

  // ======================================================
  // UPDATE CATEGORY
  // ======================================================

  Future<bool> updateCategory({
    required int categoryId,
    required String categoryName,
  }) async {
    _errorMessage = null;

    try {
      await repository.updateCategory(
        categoryId: categoryId,
        categoryName: categoryName,
      );

      final index = _categories.indexWhere(
        (category) =>
            category.categoryId == categoryId,
      );

      if (index != -1) {
        _categories[index] =
            _categories[index].copyWith(
          categoryName: categoryName,
        );
      }

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      notifyListeners();

      return false;
    }
  }

  // ======================================================
  // DELETE CATEGORY
  // ======================================================

  Future<bool> deleteCategory(
    int categoryId,
  ) async {
    _errorMessage = null;

    try {
      await repository.deleteCategory(
        categoryId: categoryId,
      );

      _categories.removeWhere(
        (category) =>
            category.categoryId == categoryId,
      );

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst("Exception: ", "");

      notifyListeners();

      return false;
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