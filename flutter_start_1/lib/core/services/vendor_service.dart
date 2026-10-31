import '../network/api_client.dart';
import '../constants/api_constants.dart';

class VendorService {
  final ApiClient apiClient;

  VendorService({
    required this.apiClient,
  });

  // ======================================================
  // CREATE VENDOR
  // ======================================================

  Future<Map<String, dynamic>> createVendor({
    required String vendorName,
    String? phone,
    String? email,
    String? address,
    String? token,
  }) async {
    final response = await apiClient.post(
      ApiConstants.vendors,
      token: token,
      body: {
        'vendor_name': vendorName,
        'phone': phone,
        'email': email,
        'address': address,
      },
    );

    return response;
  }

  // ======================================================
  // GET ALL VENDORS
  // ======================================================

  Future<Map<String, dynamic>> getVendors({
    String? token,
  }) async {
    final response = await apiClient.get(
      ApiConstants.vendors,
      token: token,
    );

    return response;
  }

  // ======================================================
  // GET VENDOR BY ID
  // ======================================================

  Future<Map<String, dynamic>> getVendorById({
    required int vendorId,
    String? token,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.vendors}/$vendorId',
      token: token,
    );

    return response;
  }

  // ======================================================
  // UPDATE VENDOR
  // ======================================================

  Future<Map<String, dynamic>> updateVendor({
    required int vendorId,
    required String vendorName,
    String? phone,
    String? email,
    String? address,
    String? token,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.vendors}/$vendorId',
      token: token,
      body: {
        'vendor_name': vendorName,
        'phone': phone,
        'email': email,
        'address': address,
      },
    );

    return response;
  }

  // ======================================================
  // DELETE VENDOR
  // ======================================================

  Future<Map<String, dynamic>> deleteVendor({
    required int vendorId,
    String? token,
  }) async {
    final response = await apiClient.delete(
      '${ApiConstants.vendors}/$vendorId',
      token: token,
    );

    return response;
  }
}