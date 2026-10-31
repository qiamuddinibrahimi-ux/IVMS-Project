import '../models/unit_model.dart';
import '../services/unit_service.dart';
import '../storage/storage_service.dart';

class UnitRepository {
  final UnitService unitService;

  UnitRepository({
    required this.unitService,
  });

  // ======================================================
  // CREATE UNIT
  // ======================================================

  Future<UnitModel> createUnit({
    required String unitName,
  }) async {
    final token = await StorageService.getUserAccessToken();

    final response = await unitService.createUnit(
      unitName: unitName,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'Failed to create unit.',
      );
    }

    return UnitModel.fromJson(
      Map<String, dynamic>.from(response['unit']),
    );
  }

  // ======================================================
  // GET ALL UNITS
  // ======================================================

  Future<List<UnitModel>> getUnits() async {
    final token = await StorageService.getUserAccessToken();

    final response = await unitService.getUnits(
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'Failed to load units.',
      );
    }

    final List data = response['units'] ?? [];

    return data
        .map(
          (json) => UnitModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET UNIT BY ID
  // ======================================================

  Future<UnitModel> getUnitById(int unitId) async {
    final token = await StorageService.getUserAccessToken();

    final response = await unitService.getUnitById(
      unitId: unitId,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'Unit not found.',
      );
    }

    return UnitModel.fromJson(
      Map<String, dynamic>.from(response['unit']),
    );
  }

  // ======================================================
  // UPDATE UNIT
  // ======================================================

  Future<UnitModel> updateUnit({
    required int unitId,
    required String unitName,
  }) async {
    final token = await StorageService.getUserAccessToken();

    final response = await unitService.updateUnit(
      unitId: unitId,
      unitName: unitName,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'Failed to update unit.',
      );
    }

    // Backend returns only success/message after update,
    // so retrieve the updated unit.
    return getUnitById(unitId);
  }

  // ======================================================
  // DELETE UNIT
  // ======================================================

  Future<void> deleteUnit(int unitId) async {
    final token = await StorageService.getUserAccessToken();

    final response = await unitService.deleteUnit(
      unitId: unitId,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'Failed to delete unit.',
      );
    }
  }
}