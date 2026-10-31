import '../network/api_client.dart';
import '../constants/api_constants.dart';

class UnitService {
  final ApiClient apiClient;

  UnitService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE UNIT
  // POST /api/units
  // ======================================================

  Future<Map<String, dynamic>> createUnit({
    required String unitName,
    String? token,
  }) async {
    final response = await apiClient.post(
      ApiConstants.units,
      token: token,
      body: {
        'unit_name': unitName,
      },
    );

    return response;
  }

  // ======================================================
  // GET ALL UNITS
  // GET /api/units
  // ======================================================

  Future<Map<String, dynamic>> getUnits({
    String? token,
  }) async {
    final response = await apiClient.get(
      ApiConstants.units,
      token: token,
    );

    return response;
  }

  // ======================================================
  // GET UNIT BY ID
  // GET /api/units/:id
  // ======================================================

  Future<Map<String, dynamic>> getUnitById({
    required int unitId,
    String? token,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.units}/$unitId',
      token: token,
    );

    return response;
  }

  // ======================================================
  // UPDATE UNIT
  // PUT /api/units/:id
  // ======================================================

  Future<Map<String, dynamic>> updateUnit({
    required int unitId,
    required String unitName,
    String? token,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.units}/$unitId',
      token: token,
      body: {
        'unit_name': unitName,
      },
    );

    return response;
  }

  // ======================================================
  // DELETE UNIT
  // DELETE /api/units/:id
  // ======================================================

  Future<Map<String, dynamic>> deleteUnit({
    required int unitId,
    String? token,
  }) async {
    final response = await apiClient.delete(
      '${ApiConstants.units}/$unitId',
      token: token,
    );

    return response;
  }
}