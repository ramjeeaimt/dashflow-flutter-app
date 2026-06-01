import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (code: $errorCode, status: $statusCode)';
}

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({
    this.baseUrl = 'https://dashflow-backend.vercel.app/api',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    try {
      final response = await client.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Connection failed: $e', errorCode: 'CONNECTION_ERROR');
    }
  }

  Future<dynamic> post(String path, dynamic body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    try {
      final response = await client.post(uri, headers: headers, body: jsonEncode(body));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Connection failed: $e', errorCode: 'CONNECTION_ERROR');
    }
  }

  Future<dynamic> patch(String path, dynamic body) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    try {
      final response = await client.patch(uri, headers: headers, body: jsonEncode(body));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Connection failed: $e', errorCode: 'CONNECTION_ERROR');
    }
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    try {
      final response = await client.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Connection failed: $e', errorCode: 'CONNECTION_ERROR');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String message = 'API Request failed';
      String? errorCode;
      try {
        final decoded = jsonDecode(response.body);
        message = decoded['message'] ?? decoded['error'] ?? message;
        errorCode = decoded['errorCode'] ?? decoded['code'];
      } catch (_) {
        message = response.body.isNotEmpty ? response.body : message;
      }
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
        errorCode: errorCode ?? 'API_ERROR',
      );
    }
  }
}
