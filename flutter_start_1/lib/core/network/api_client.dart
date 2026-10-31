import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class ApiClient {
  // Single-flight refresh — only ONE refresh runs at a time,
  // even if 10 requests get 401 at once.
  static Future<bool>? _refreshInFlight;

  // ======================================================
  // PUBLIC HTTP METHODS
  // ======================================================

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) =>
      _send(method: 'GET', endpoint: endpoint, token: token);

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) =>
      _send(method: 'POST', endpoint: endpoint, body: body, token: token);

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) =>
      _send(method: 'PUT', endpoint: endpoint, body: body, token: token);

  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) =>
      _send(method: 'DELETE', endpoint: endpoint, token: token);

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) =>
      _send(method: 'PATCH', endpoint: endpoint, body: body, token: token);

  // ======================================================
  // CORE SENDER
  // ======================================================

  Future<Map<String, dynamic>> _send({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    String? token,
    bool isRetry = false,
  }) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint");

    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }

    // ======================================================
    // 401 → REFRESH ONCE, THEN RETRY
    // ======================================================
    if (response.statusCode == 401 && !isRetry) {
      // Don't try to refresh when the failing call IS the refresh call
      if (endpoint == ApiConstants.userRefresh ||
          endpoint == ApiConstants.userLogin ||
          endpoint == ApiConstants.userRegister) {
        return _handleResponse(response);
      }

      final refreshed = await _tryRefresh();

      if (refreshed) {
        final newToken = await StorageService.getUserAccessToken();
        return _send(
          method: method,
          endpoint: endpoint,
          body: body,
          token: newToken,
          isRetry: true,
        );
      }

      // Refresh failed — clear tokens and throw
      await StorageService.removeUserTokens();
      throw Exception('Session expired. Please log in again.');
    }

    return _handleResponse(response);
  }

  // ======================================================
  // REFRESH LOGIC (matches authController.refreshToken)
  // ======================================================

  Future<bool> _tryRefresh() {
    if (_refreshInFlight != null) return _refreshInFlight!;

    _refreshInFlight = _performRefresh();
    _refreshInFlight!.whenComplete(() {
      _refreshInFlight = null;
    });

    return _refreshInFlight!;
  }

  Future<bool> _performRefresh() async {
    try {
      final refreshToken = await StorageService.getUserRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) return false;

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}${ApiConstants.userRefresh}",
      );

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        return false;
      }

      // Backend returns FLAT: { success, accessToken }
      final newAccess = decoded['accessToken']?.toString() ?? '';

      if (newAccess.isEmpty) return false;

      // Backend does NOT rotate the refresh token — keep the old one.
      await StorageService.saveUserTokens(
        accessToken: newAccess,
        refreshToken: refreshToken,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ======================================================
  // RESPONSE PARSER
  // ======================================================

  Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic decodedBody;

    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      throw Exception("Server returned invalid JSON.");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(decodedBody);
    }

    String message = "Something went wrong.";

    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody["message"] != null) {
        message = decodedBody["message"].toString();
      } else if (decodedBody["error"] != null) {
        message = decodedBody["error"].toString();
      }
    }

    throw Exception(message);
  }
}