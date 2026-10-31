class ItemModel {
  final int itemId;
  final String itemName;

  final int categoryId;
  final String categoryName;

  final int unitId;
  final String unitName;

  final String? barcode;
  final String? description;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.unitId,
    required this.unitName,
    this.barcode,
    this.description,
  });

  factory ItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ItemModel(
      itemId: int.parse(
        json['item_id'].toString(),
      ),

      itemName:
          json['item_name']?.toString() ?? '',

      categoryId: int.parse(
        json['category_id'].toString(),
      ),

      categoryName:
          json['category_name']?.toString() ?? '',

      unitId: int.parse(
        json['unit_id'].toString(),
      ),

      unitName:
          json['unit_name']?.toString() ?? '',

      barcode:
          json['barcode']?.toString(),

      description:
          json['description']?.toString(),
    );
  }
}