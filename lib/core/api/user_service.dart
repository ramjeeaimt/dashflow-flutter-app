import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/features/admin/users/models/user_model.dart';
import 'package:logger/logger.dart';

class UserService {
  static const String baseUrl = 'https://dashflow-backend.vercel.app/api';
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      var innerData = responseData['data'];
      if (innerData is Map<String, dynamic> && innerData.containsKey('data')) {
        return innerData['data'];
      }
      return innerData;
    }
    return responseData;
  }

  // GET /users
  static Future<List<UserModel>> getUsers() async {
    final url = Uri.parse('$baseUrl/users');
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        if (data is List) {
          return data.map((e) => UserModel.fromJson(e)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getUsers: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  // GET /users/:id
  static Future<UserModel> getUserById(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getUserById: $e');
      throw Exception('Failed to fetch user details: $e');
    }
  }

  // POST /users
  static Future<UserModel> createUser(UserModel user, String password) async {
    final url = Uri.parse('$baseUrl/users');
    final headers = await _getHeaders();
    final body = jsonEncode(user.toJson(password: password));

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] createUser: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  // PUT /users/:id
  static Future<UserModel> updateUser(String id, UserModel user) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final headers = await _getHeaders();
    // Do not send password on update unless it's changed, here we just send standard info
    final body = jsonEncode(user.toJson());

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] updateUser: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  // DELETE /users/:id
  static Future<void> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final headers = await _getHeaders();

    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] deleteUser: $e');
      throw Exception('Failed to delete user: $e');
    }
  }
}
