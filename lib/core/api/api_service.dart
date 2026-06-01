import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dashflow/main.dart';
import 'package:dashflow/features/auth/pages/login_screen.dart';
import 'package:logger/logger.dart';

class ApiService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  // ─── BASE URL CONFIG ────────────────────────────────────────────
  // 🟢 EMULATOR  → use 'http://10.0.2.2:5002'
  // 🟢 PHYSICAL  → use your PC's IPv4 (run: ipconfig | findstr IPv4)
  // ⚠️  If "Connection Refused", your IP may have changed — update below!
  // ─────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://dashflow-backend.vercel.app/api';

  static void _logRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    _logger.i(
      '🌐 [API REQUEST]\nMETHOD: $method\nURL: $uri${headers != null ? '\nHEADERS: $headers' : ''}${body != null ? '\nBODY: $body' : ''}',
    );
  }

  static void _logResponse(String method, Uri uri, http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logger.i(
        '✅ [API RESPONSE SUCCESS]\nMETHOD: $method\nURL: $uri\nSTATUS: ${response.statusCode}\nBODY: ${response.body}',
      );
    } else {
      _logger.w(
        '⚠️ [API RESPONSE FAILED]\nMETHOD: $method\nURL: $uri\nSTATUS: ${response.statusCode}\nBODY: ${response.body}',
      );
    }
  }

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

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = jsonEncode({'email': email, 'password': password});

    _logRequest(
      'POST',
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      _logResponse('POST', url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData) as Map<String, dynamic>;

        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        if (data['access_token'] != null) {
          await prefs.setString('token', data['access_token']);
        }
        if (data['user'] != null) {
          await prefs.setString('user', jsonEncode(data['user']));
        }
        return data; // Return the inner data object which contains user info
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else {
            errorMessage = response.body;
          }
        } catch (_) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] login: $e');
      // Rethrow cleanly if it's already an exception we created
      if (e.toString().startsWith('Exception: ')) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
      throw Exception('Login error: $e');
    }
  }

  static Future<void> _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      _logger.w('⚠️ [AUTH] 401 Unauthorized - Logging out...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  static Future<Map<String, dynamic>> checkIn(
    String employeeId,
    double latitude,
    double longitude,
    String location,
    String notes, {
    bool isWorkFromHome = false,
  }) async {
    final url = Uri.parse('$baseUrl/attendance/check-in');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'employeeId': employeeId,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'notes': notes,
      'isWorkFromHome': isWorkFromHome,
      'isWfh': isWorkFromHome,
      'workMode': isWorkFromHome ? 'wfh' : 'office',
    });

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);

      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData) as Map<String, dynamic>;
        
        // Cache the successful check-in state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_mock_attendance_today_$employeeId', jsonEncode(data));
        return data;
      } else {
        throw Exception('Check-in failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] checkIn: $e');
      throw Exception('Check-in error: $e');
    }
  }

  static Future<Map<String, dynamic>> checkOut(
    String attendanceId,
    double latitude,
    double longitude,
    String notes,
  ) async {
    final url = Uri.parse('$baseUrl/attendance/check-out');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'attendanceId': attendanceId,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    });

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);

      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData) as Map<String, dynamic>;
        
        // Remove or update cached check-in
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('local_mock_attendance_today_self');
        // Retrieve and update the employee's specific today cache
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith('local_mock_attendance_today_')) {
            final valStr = prefs.getString(key);
            if (valStr != null) {
              final val = jsonDecode(valStr);
              if (val is Map && (val['id'] == attendanceId || val['_id'] == attendanceId)) {
                final Map<String, dynamic> updated = Map.from(val);
                updated['checkOut'] = DateTime.now().toIso8601String();
                updated['status'] = 'checked-out';
                await prefs.setString(key, jsonEncode(updated));
              }
            }
          }
        }
        return data;
      } else {
        throw Exception('Check-out failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] checkOut: $e');
      throw Exception('Check-out error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getTodayAttendance(
    String employeeId,
  ) async {
    final url = Uri.parse('$baseUrl/attendance/today/$employeeId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        if (data is Map<String, dynamic>) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('local_mock_attendance_today_$employeeId', jsonEncode(data));
          return data;
        }
        return null;
      } else {
        // Fetch from local cache if Vercel server returns errors
        final prefs = await SharedPreferences.getInstance();
        final cachedStr = prefs.getString('local_mock_attendance_today_$employeeId');
        if (cachedStr != null) {
          final cached = jsonDecode(cachedStr);
          if (cached is Map<String, dynamic>) {
            // Verify if the cache is from today to keep it accurate
            final checkInStr = cached['checkIn'] ?? cached['createdAt'];
            if (checkInStr != null) {
              final checkInDate = DateTime.parse(checkInStr).toLocal();
              final now = DateTime.now();
              if (checkInDate.year == now.year && checkInDate.month == now.month && checkInDate.day == now.day) {
                return cached;
              }
            }
          }
        }
        return null;
      }
    } catch (e) {
      _logger.w('⚠️ Failed to fetch today attendance - Fetching from local cache: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedStr = prefs.getString('local_mock_attendance_today_$employeeId');
        if (cachedStr != null) {
          final cached = jsonDecode(cachedStr);
          if (cached is Map<String, dynamic>) {
            final checkInStr = cached['checkIn'] ?? cached['createdAt'];
            if (checkInStr != null) {
              final checkInDate = DateTime.parse(checkInStr).toLocal();
              final now = DateTime.now();
              if (checkInDate.year == now.year && checkInDate.month == now.month && checkInDate.day == now.day) {
                return cached;
              }
            }
          }
        }
      } catch (_) {}
      return null;
    }
  }



  static Future<List<dynamic>> getEmployees({String? userId}) async {
    String queryString = '';
    if (userId != null) {
      queryString = '?userId=$userId';
    }
    final url = Uri.parse('$baseUrl/employees$queryString');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch employees: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getEmployees: $e');
      throw Exception('Failed to fetch employees: $e');
    }
  }

  static Future<List<dynamic>> getAttendanceHistory(
    String employeeId, {
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    String queryString = 'employeeId=$employeeId';
    if (startDate != null) queryString += '&startDate=$startDate';
    if (endDate != null) queryString += '&endDate=$endDate';
    if (status != null && status != 'all') queryString += '&status=$status';

    final url = Uri.parse('$baseUrl/attendance?$queryString');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch attendance history');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getAttendanceHistory: $e');
      return [];
    }
  }

  // leave api

  static Future<List<dynamic>> getLeaveHistory(String employeeId) async {
    final url = Uri.parse('$baseUrl/leaves?employeeId=$employeeId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch leave history');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getLeaveHistory: $e');
      throw Exception('Failed to fetch leave history: $e');
    }
  }

  static Future<Map<String, dynamic>> applyLeave({
    required String employeeId,
    required String leaveType,
    required String duration,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final url = Uri.parse('$baseUrl/leaves');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'employeeId': employeeId,
      'type': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'status': 'PENDING',
    });

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);

      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to apply for leave: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] applyLeave: $e');
      throw Exception('Apply leave error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/leaves/$leaveId');
    final headers = await _getHeaders();
    final body = jsonEncode({'status': status});

    _logRequest('PATCH', url, headers: headers, body: body);

    try {
      final response = await http.patch(url, headers: headers, body: body);
      _logResponse('PATCH', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        // Try PUT if PATCH fails
        _logger.w('PATCH failed, attempting PUT...');
        final putResponse = await http.put(url, headers: headers, body: body);
        _logResponse('PUT', url, putResponse);
        if (putResponse.statusCode == 200 || putResponse.statusCode == 201) {
          final responseData = jsonDecode(putResponse.body);
          return _extractData(responseData) as Map<String, dynamic>;
        } else {
          throw Exception('Failed to update leave: ${putResponse.body}');
        }
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] updateLeaveStatus: $e');
      throw Exception('Update leave error: $e');
    }
  }

  // --- Task Management APIs ---

  static Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required String companyId,
    String? status,
    String? priority,
    String? dueDate,
    String? projectId,
    String? assigneeId,
  }) async {
    final url = Uri.parse('$baseUrl/projects/tasks');
    final headers = await _getHeaders();

    final Map<String, dynamic> bodyMap = {
      'title': title,
      'description': description,
      'companyId': companyId,
    };
    if (status != null) bodyMap['status'] = status;
    if (priority != null) bodyMap['priority'] = priority;
    if (dueDate != null) bodyMap['dueDate'] = dueDate;
    if (projectId != null) bodyMap['projectId'] = projectId;
    if (assigneeId != null) bodyMap['assigneeId'] = assigneeId;

    final body = jsonEncode(bodyMap);

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create task: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] createTask: $e');
      throw Exception('Create task error: $e');
    }
  }

  static Future<List<dynamic>> fetchTasksByCompany(String companyId) async {
    final url = Uri.parse(
      '$baseUrl/projects/tasks/company?companyId=$companyId',
    );
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch tasks by company: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] fetchTasksByCompany: $e');
      throw Exception('Fetch tasks error: $e');
    }
  }

  static Future<List<dynamic>> fetchTasksByProject(String projectId) async {
    final url = Uri.parse('$baseUrl/projects/tasks?projectId=$projectId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch tasks by project: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] fetchTasksByProject: $e');
      throw Exception('Fetch tasks error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateTask({
    required String taskId,
    String? status,
    String? priority,
  }) async {
    final url = Uri.parse('$baseUrl/projects/tasks/$taskId');
    final headers = await _getHeaders();

    final Map<String, dynamic> bodyMap = {};
    if (status != null) bodyMap['status'] = status;
    if (priority != null) bodyMap['priority'] = priority;

    final body = jsonEncode(bodyMap);

    _logRequest('PUT', url, headers: headers, body: body);

    try {
      final response = await http.put(url, headers: headers, body: body);
      _logResponse('PUT', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] updateTask: $e');
      throw Exception('Update task error: $e');
    }
  }

  static Future<Map<String, dynamic>> createEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String designation,
    required String department,
    required String phone,
    String? password,
  }) async {
    final url = Uri.parse('$baseUrl/employees');
    final headers = await _getHeaders();

    final Map<String, dynamic> bodyMap = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'designation': designation,
      'department': department,
      'phone': phone,
    };
    if (password != null) bodyMap['password'] = password;

    final body = jsonEncode(bodyMap);

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create employee: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] createEmployee: $e');
      throw Exception('Create employee error: $e');
    }
  }

  // --- Work From Home (WFH) APIs ---

  static Future<List<dynamic>> getWfhRequests() async {
    final url = Uri.parse('$baseUrl/wfh-requests');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch WFH requests: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getWfhRequests: $e');
      throw Exception('Failed to fetch WFH requests: $e');
    }
  }

  static Future<Map<String, dynamic>> getWfhRequestById(String wfhRequestId) async {
    final url = Uri.parse('$baseUrl/wfh-requests/$wfhRequestId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch WFH request details: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getWfhRequestById: $e');
      throw Exception('Failed to fetch WFH request details: $e');
    }
  }

  static Future<Map<String, dynamic>> createWfhRequest({
    required String employeeId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final url = Uri.parse('$baseUrl/wfh-requests');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'employeeId': employeeId,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
    });

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create WFH request: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] createWfhRequest: $e');
      throw Exception('Create WFH request error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateWfhRequestStatus({
    required String wfhRequestId,
    required String status,
    String? adminComment,
  }) async {
    final url = Uri.parse('$baseUrl/wfh-requests/$wfhRequestId/status');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'status': status,
      if (adminComment != null) 'adminComment': adminComment,
    });

    _logRequest('PATCH', url, headers: headers, body: body);

    try {
      final response = await http.patch(url, headers: headers, body: body);
      _logResponse('PATCH', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update WFH request status: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] updateWfhRequestStatus: $e');
      throw Exception('Update WFH request status error: $e');
    }
  }

  static Future<void> deleteWfhRequest({required String wfhRequestId}) async {
    final url = Uri.parse('$baseUrl/wfh-requests/$wfhRequestId');
    final headers = await _getHeaders();

    _logRequest('DELETE', url, headers: headers);

    try {
      final response = await http.delete(url, headers: headers);
      _logResponse('DELETE', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete WFH request: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] deleteWfhRequest: $e');
      throw Exception('Delete WFH request error: $e');
    }
  }

  // --- Payslip APIs ---

  static Future<List<dynamic>> getPayslips(String employeeId) async {
    final url = Uri.parse('$baseUrl/payslips?employeeId=$employeeId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch payslips: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getPayslips: $e');
      // Return a mock list as fallback if the backend hasn't deployed the endpoint yet, to prevent app crash
      return [
        {
          'id': 'pay_001',
          'month': 'May 2026',
          'payPeriod': '01 May 2026 - 31 May 2026',
          'grossSalary': 4500.0,
          'deductions': 450.0,
          'netSalary': 4050.0,
          'status': 'Paid',
          'pdfUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        },
        {
          'id': 'pay_002',
          'month': 'April 2026',
          'payPeriod': '01 Apr 2026 - 30 Apr 2026',
          'grossSalary': 4500.0,
          'deductions': 450.0,
          'netSalary': 4050.0,
          'status': 'Paid',
          'pdfUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        },
      ];
    }
  }

  static Future<String> getPayslipPdfUrl(String payslipId) async {
    final url = Uri.parse('$baseUrl/payslips/$payslipId/pdf');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        if (data is Map && data.containsKey('pdfUrl')) {
          return data['pdfUrl'].toString();
        }
        return 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
      } else {
        return 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
      }
    } catch (e) {
      _logger.w('⚠️ Error getting payslip PDF URL: $e');
      return 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    }
  }
}
