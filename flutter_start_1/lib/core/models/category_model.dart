class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String? photo;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.photo,
  });

  factory CategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoryModel(
      categoryId: json["category_id"],
      categoryName:
          json["category_name"]?.toString() ?? "",
      photo: json["photo"]?.toString(),
    );
  }

  CategoryModel copyWith({
    int? categoryId,
    String? categoryName,
    String? photo,
  }) {
    return CategoryModel(
      categoryId:
          categoryId ?? this.categoryId,
      categoryName:
          categoryName ?? this.categoryName,
      photo: photo ?? this.photo,
    );
  }
}