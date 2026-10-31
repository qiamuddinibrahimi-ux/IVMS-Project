import '../models/category_model.dart';
import '../services/category_service.dart';
import '../storage/storage_service.dart';

class CategoryRepository {
  final CategoryService categoryService;

  CategoryRepository({
    required this.categoryService,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<CategoryModel> createCategory({
    required String categoryName,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await categoryService.createCategory(
      accessToken: token,
      categoryName: categoryName,
    );

    return CategoryModel.fromJson(
      Map<String, dynamic>.from(
        response["category"],
      ),
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<List<CategoryModel>> getCategories() async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await categoryService.getCategories(
      accessToken: token,
    );

    final List<dynamic> data =
        response["categories"] ?? [];

    return data
        .map(
          (item) => CategoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<CategoryModel> getCategoryById({
    required int categoryId,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    final response =
        await categoryService.getCategoryById(
      accessToken: token,
      categoryId: categoryId,
    );

    return CategoryModel.fromJson(
      Map<String, dynamic>.from(
        response["category"],
      ),
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<void> updateCategory({
    required int categoryId,
    required String categoryName,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    await categoryService.updateCategory(
      accessToken: token,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<void> deleteCategory({
    required int categoryId,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "User is not logged in.",
      );
    }

    await categoryService.deleteCategory(
      accessToken: token,
      categoryId: categoryId,
    );
  }
}