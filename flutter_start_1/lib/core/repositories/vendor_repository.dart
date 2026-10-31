import '../models/vendor_model.dart';
import '../services/vendor_service.dart';
import '../storage/storage_service.dart';

class VendorRepository {
  final VendorService vendorService;

  VendorRepository({
    required this.vendorService,
  });

  // ======================================================
  // CREATE VENDOR
  // ======================================================

  Future<VendorModel> createVendor({
    required String vendorName,
    String? phone,
    String? email,
    String? address,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await vendorService.createVendor(
      vendorName: vendorName,
      phone: phone,
      email: email,
      address: address,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to create vendor.',
      );
    }

    if (response['data'] == null) {
      throw Exception(
        'Vendor information was not returned.',
      );
    }

    return VendorModel.fromJson(
      Map<String, dynamic>.from(
        response['data'],
      ),
    );
  }

  // ======================================================
  // GET ALL VENDORS
  // ======================================================

  Future<List<VendorModel>> getVendors() async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await vendorService.getVendors(
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to load vendors.',
      );
    }

    final List data =
        response['data'] ?? [];

    return data
        .map(
          (json) => VendorModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ======================================================
  // GET VENDOR BY ID
  // ======================================================

  Future<VendorModel> getVendorById(
    int vendorId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await vendorService.getVendorById(
      vendorId: vendorId,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Vendor not found.',
      );
    }

    if (response['data'] == null) {
      throw Exception(
        'Vendor information was not returned.',
      );
    }

    return VendorModel.fromJson(
      Map<String, dynamic>.from(
        response['data'],
      ),
    );
  }

  // ======================================================
  // UPDATE VENDOR
  // ======================================================

  Future<VendorModel> updateVendor({
    required int vendorId,
    required String vendorName,
    String? phone,
    String? email,
    String? address,
  }) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await vendorService.updateVendor(
      vendorId: vendorId,
      vendorName: vendorName,
      phone: phone,
      email: email,
      address: address,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to update vendor.',
      );
    }

    if (response['data'] == null) {
      throw Exception(
        'Updated vendor information was not returned.',
      );
    }

    return VendorModel.fromJson(
      Map<String, dynamic>.from(
        response['data'],
      ),
    );
  }

  // ======================================================
  // DELETE VENDOR
  // ======================================================

  Future<void> deleteVendor(
    int vendorId,
  ) async {
    final token =
        await StorageService.getUserAccessToken();

    final response =
        await vendorService.deleteVendor(
      vendorId: vendorId,
      token: token,
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Failed to delete vendor.',
      );
    }
  }
}