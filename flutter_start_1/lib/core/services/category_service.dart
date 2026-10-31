
import '../constants/api_constants.dart';
import '../network/api_client.dart';

class CategoryService {
  final ApiClient apiClient;

  CategoryService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE
  // ======================================================

  Future<Map<String, dynamic>> createCategory({
    required String accessToken,
    required String categoryName,
  }) async {
    return await apiClient.post(
      ApiConstants.categories,
      token: accessToken,
      body: {
        "category_name": categoryName,
      },
    );
  }

  // ======================================================
  // GET ALL
  // ======================================================

  Future<Map<String, dynamic>> getCategories({
    required String accessToken,
  }) async {
    return await apiClient.get(
      ApiConstants.categories,
      token: accessToken,
    );
  }

  // ======================================================
  // GET BY ID
  // ======================================================

  Future<Map<String, dynamic>> getCategoryById({
    required String accessToken,
    required int categoryId,
  }) async {
    return await apiClient.get(
      "${ApiConstants.categories}/$categoryId",
      token: accessToken,
    );
  }

  // ======================================================
  // UPDATE
  // ======================================================

  Future<Map<String, dynamic>> updateCategory({
    required String accessToken,
    required int categoryId,
    required String categoryName,
  }) async {
    return await apiClient.put(
      "${ApiConstants.categories}/$categoryId",
      token: accessToken,
      body: {
        "category_name": categoryName,
      },
    );
  }

  // ======================================================
  // DELETE
  // ======================================================

  Future<Map<String, dynamic>> deleteCategory({
    required String accessToken,
    required int categoryId,
  }) async {
    return await apiClient.delete(
      "${ApiConstants.categories}/$categoryId",
      token: accessToken,
    );
  }
}