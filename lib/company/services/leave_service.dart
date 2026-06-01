import 'api_service.dart';
import 'models.dart';
import 'dart:async';

/// Leave Service
class LeaveService {
  final ApiService apiService;
  static const String _endpoint = '/leaves';

  LeaveService({required this.apiService});

  /// Get all leaves with pagination
  Future<ListResponse<Leave>> getAllLeaves({
    int page = 1,
    int pageSize = 10,
    String? employeeId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (employeeId != null && employeeId.isNotEmpty) {
        queryParams['employeeId'] = employeeId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      queryParams['page'] = page.toString();
      queryParams['limit'] = pageSize.toString();

      final queryString = Uri(queryParameters: queryParams).query;
      final path = queryString.isNotEmpty ? '$_endpoint?$queryString' : _endpoint;

      final response = await apiService.get(path);
      List<dynamic> listData = [];
      int total = 0;
      if (response is List) {
        listData = response;
        total = response.length;
      } else if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['leaves'] ?? response['items'];
        if (data is List) {
          listData = data;
        }
        total = response['total'] ?? response['totalCount'] ?? listData.length;
      }

      final items = listData.map((json) => Leave.fromJson(json)).toList();
      
      // Local client-side filter for dates if they were provided (fallback/reinforcement)
      var filteredItems = items;
      if (fromDate != null) {
        filteredItems = filteredItems.where((l) => l.fromDate.isAfter(fromDate)).toList();
      }
      if (toDate != null) {
        filteredItems = filteredItems.where((l) => l.toDate.isBefore(toDate)).toList();
      }

      return ListResponse(
        items: filteredItems,
        totalCount: total,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to fetch leaves: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get leaves for specific employee
  Future<ListResponse<Leave>> getEmployeeLeaves({
    required String employeeId,
    int page = 1,
    int pageSize = 10,
  }) async {
    return getAllLeaves(
      employeeId: employeeId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Apply for leave
  Future<Leave> applyLeave({
    required String employeeId,
    required String employeeName,
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    required int noOfDays,
    required String reason,
  }) async {
    try {
      final body = {
        'employeeId': employeeId,
        'startDate': fromDate.toIso8601String().substring(0, 10),
        'endDate': toDate.toIso8601String().substring(0, 10),
        'type': leaveType,
        'reason': reason,
      };

      final response = await apiService.post(_endpoint, body);
      return Leave.fromJson(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to apply leave: $e',
        errorCode: 'APPLY_ERROR',
      );
    }
  }

  /// Approve leave
  Future<Leave> approveLeave({
    required String leaveId,
    required String approverName,
  }) async {
    try {
      final body = {
        'status': 'APPROVED',
        'adminComment': 'Approved by $approverName',
      };
      final response = await apiService.patch('$_endpoint/$leaveId/status', body);
      return Leave.fromJson(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to approve leave: $e',
        errorCode: 'APPROVE_ERROR',
      );
    }
  }

  /// Reject leave
  Future<Leave> rejectLeave({
    required String leaveId,
    required String approverName,
  }) async {
    try {
      final body = {
        'status': 'REJECTED',
        'adminComment': 'Rejected by $approverName',
      };
      final response = await apiService.patch('$_endpoint/$leaveId/status', body);
      return Leave.fromJson(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to reject leave: $e',
        errorCode: 'REJECT_ERROR',
      );
    }
  }

  /// Get leave balance
  Future<Map<String, int>> getLeaveBalance(String employeeId) async {
    try {
      final leavesResponse = await getEmployeeLeaves(
        employeeId: employeeId,
        pageSize: 100,
      );
      final approvedLeaves = leavesResponse.items.where(
        (l) => l.status.toUpperCase() == 'APPROVED',
      );

      final Map<String, int> balance = _getDefaultLeaveBalance();
      for (final leave in approvedLeaves) {
        final type = leave.leaveType.toLowerCase();
        if (balance.containsKey(type)) {
          balance[type] = (balance[type]! - leave.noOfDays).clamp(0, 100);
        }
      }
      return balance;
    } catch (e) {
      return _getDefaultLeaveBalance();
    }
  }

  /// Get leave balance for all employees
  Future<Map<String, Map<String, int>>> getAllLeaveBalance() async {
    try {
      final leavesResponse = await getAllLeaves(pageSize: 1000);
      final Map<String, Map<String, int>> balances = {};

      for (final leave in leavesResponse.items) {
        final empId = leave.employeeId;
        balances.putIfAbsent(empId, () => _getDefaultLeaveBalance());

        if (leave.status.toUpperCase() == 'APPROVED') {
          final type = leave.leaveType.toLowerCase();
          if (balances[empId]!.containsKey(type)) {
            balances[empId]![type] =
                (balances[empId]![type]! - leave.noOfDays).clamp(0, 100);
          }
        }
      }
      return balances;
    } catch (e) {
      return {};
    }
  }

  /// Cancel leave application
  Future<bool> cancelLeave(String leaveId) async {
    try {
      await apiService.delete('$_endpoint/$leaveId');
      return true;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to cancel leave: $e',
        errorCode: 'CANCEL_ERROR',
      );
    }
  }

  /// Get pending leave requests
  Future<ListResponse<Leave>> getPendingLeaves({
    int page = 1,
    int pageSize = 10,
  }) async {
    return getAllLeaves(
      status: 'PENDING',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Default leave balance
  Map<String, int> _getDefaultLeaveBalance() {
    return {
      'casual': 12,
      'sick': 6,
      'earned': 15,
      'personal': 3,
      'maternity': 0,
    };
  }
}
