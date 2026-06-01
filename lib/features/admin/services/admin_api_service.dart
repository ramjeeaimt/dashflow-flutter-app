import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApiService {
  static const String _base = 'https://dashflow-backend.vercel.app/api';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final d = raw['data'];
      if (d is Map<String, dynamic> && d.containsKey('data')) return d['data'];
      if (d != null) return d;
    }
    return raw;
  }

  static Future<List<dynamic>> getAllEmployees() async {
    try {
      final res = await http.get(Uri.parse('$_base/employees'), headers: await _headers());
      if (res.statusCode == 200) {
        final data = _unwrap(jsonDecode(res.body));
        return data is List ? data : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getAllLeaves() async {
    try {
      final res = await http.get(Uri.parse('$_base/leaves'), headers: await _headers());
      if (res.statusCode == 200) {
        final data = _unwrap(jsonDecode(res.body));
        return data is List ? data : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getAllAttendance() async {
    try {
      final res = await http.get(Uri.parse('$_base/attendance'), headers: await _headers());
      if (res.statusCode == 200) {
        final data = _unwrap(jsonDecode(res.body));
        return data is List ? data : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getAllWfhRequests() async {
    try {
      final res = await http.get(Uri.parse('$_base/wfh-requests'), headers: await _headers());
      if (res.statusCode == 200) {
        final data = _unwrap(jsonDecode(res.body));
        return data is List ? data : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> updateLeaveStatus(String leaveId, String status) async {
    try {
      final h = await _headers();
      final body = jsonEncode({'status': status});
      final url = Uri.parse('$_base/leaves/$leaveId');
      var res = await http.patch(url, headers: h, body: body);
      if (res.statusCode == 200 || res.statusCode == 201) return true;
      res = await http.put(url, headers: h, body: body);
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateWfhStatus(String wfhId, String status) async {
    try {
      final h = await _headers();
      final body = jsonEncode({'status': status});
      final res = await http.patch(
        Uri.parse('$_base/wfh-requests/$wfhId/status'),
        headers: h,
        body: body,
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteEmployee(String employeeId) async {
    try {
      final res = await http.delete(
        Uri.parse('$_base/employees/$employeeId'),
        headers: await _headers(),
      );
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
