export '../../core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String BASE_URL = 'http://192.168.1.16:5002/api';

  late Dio _dio;
  late SharedPreferences _prefs;

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await saveToken(token);
        return response.data;
      }
      throw Exception('Login failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login error');
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch users');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching users');
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching user');
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    String? companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
          'companyId': companyId,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating user');
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating user');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _dio.delete('/users/$userId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting user');
    }
  }

  Future<List<dynamic>> getAllCompanies() async {
    try {
      final response = await _dio.get('/companies');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch companies');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching companies',
      );
    }
  }

  Future<Map<String, dynamic>> getCompanyById(String companyId) async {
    try {
      final response = await _dio.get('/companies/$companyId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching company');
    }
  }

  Future<Map<String, dynamic>> createCompany({
    required String name,
    required String email,
    required String website,
    required String industry,
    required int size,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final response = await _dio.post(
        '/companies',
        data: {
          'name': name,
          'email': email,
          'website': website,
          'industry': industry,
          'size': size,
          'address': address,
          'city': city,
          'country': country,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating company');
    }
  }

  Future<Map<String, dynamic>> updateCompany({
    required String companyId,
    required String name,
    required String email,
    required String website,
    required String industry,
    required int size,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final response = await _dio.put(
        '/companies/$companyId',
        data: {
          'name': name,
          'email': email,
          'website': website,
          'industry': industry,
          'size': size,
          'address': address,
          'city': city,
          'country': country,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating company');
    }
  }

  Future<void> deleteCompany(String companyId) async {
    try {
      final response = await _dio.delete('/companies/$companyId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete company');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting company');
    }
  }

  Future<List<dynamic>> getAllLeaves() async {
    try {
      final response = await _dio.get('/leaves');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch leaves');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching leaves');
    }
  }

  Future<Map<String, dynamic>> getLeaveById(String leaveId) async {
    try {
      final response = await _dio.get('/leaves/$leaveId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching leave');
    }
  }

  Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String startDate,
    required String endDate,
    required String type,
  }) async {
    try {
      final response = await _dio.post(
        '/leaves',
        data: {
          'employeeId': employeeId,
          'startDate': startDate,
          'endDate': endDate,
          'type': type,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to request leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error requesting leave');
    }
  }

  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String status,
    required String adminComment,
  }) async {
    try {
      final response = await _dio.patch(
        '/leaves/$leaveId',
        data: {'status': status, 'adminComment': adminComment},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating leave');
    }
  }

  Future<void> deleteLeave(String leaveId) async {
    try {
      final response = await _dio.delete('/leaves/$leaveId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete leave');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting leave');
    }
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    return _prefs.getString('jwt_token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
