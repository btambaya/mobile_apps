import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/auth_config.dart';
import '../../features/auth/data/datasources/cognito_auth_datasource.dart';

/// API Service for authenticated requests to backend
class ApiService {
  final FlutterSecureStorage _secureStorage;
  final CognitoAuthDatasource _authDatasource;
  
  // API Gateway base URL
  static const String _baseUrl = 'https://y1mheifune.execute-api.us-east-1.amazonaws.com/prod';

  ApiService({
    FlutterSecureStorage? secureStorage,
    CognitoAuthDatasource? authDatasource,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _authDatasource = authDatasource ?? CognitoAuthDatasource();

  /// Get authenticated headers with ID token for Cognito authorizer
  Future<Map<String, String>> _getAuthHeaders() async {
    // Cognito Authorizer validates ID token, not Access token
    String? idToken = await _secureStorage.read(key: AuthConfig.idTokenKey);
    
    if (idToken == null) {
      throw Exception('Not authenticated');
    }

    return {
      'Authorization': idToken,  // No 'Bearer ' prefix for Cognito
      'Content-Type': 'application/json',
    };
  }

  /// GET request with authentication
  Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl$endpoint');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 401) {
      // Token expired, try to refresh
      await _authDatasource.refreshSession();
      // Retry with new token
      final newHeaders = await _getAuthHeaders();
      final retryResponse = await http.get(url, headers: newHeaders);
      return _handleResponse(retryResponse);
    }

    return _handleResponse(response);
  }

  /// POST request with authentication
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await _authDatasource.refreshSession();
      final newHeaders = await _getAuthHeaders();
      final retryResponse = await http.post(
        url,
        headers: newHeaders,
        body: jsonEncode(body),
      );
      return _handleResponse(retryResponse);
    }

    return _handleResponse(response);
  }

  /// PUT request with authentication
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl$endpoint');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await _authDatasource.refreshSession();
      final newHeaders = await _getAuthHeaders();
      final retryResponse = await http.put(
        url,
        headers: newHeaders,
        body: jsonEncode(body),
      );
      return _handleResponse(retryResponse);
    }

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    }

    final error = body['error'] ?? 'Request failed';
    throw ApiException(response.statusCode, error);
  }
}

/// API Exception with status code
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
