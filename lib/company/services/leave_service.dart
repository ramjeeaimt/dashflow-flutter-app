import 'api_service.dart';
import 'models.dart';
import 'dart:async';

/// Leave Service
class LeaveService {
  final ApiService apiService;
  static const String _endpoint = '/api/leaves';

  // Fake data storage
  static final List<Leave> _fakeLeaves = _generateFakeLeaves();
  static final Map<String, Map<String, int>> _leaveBalance =
      _generateLeaveBalance();

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
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      List<Leave> filtered = _fakeLeaves;

      // Filter by employeeId
      if (employeeId != null && employeeId.isNotEmpty) {
        filtered = filtered.where((l) => l.employeeId == employeeId).toList();
      }

      // Filter by status
      if (status != null && status.isNotEmpty) {
        filtered = filtered.where((l) => l.status == status).toList();
      }

      // Filter by date range
      if (fromDate != null) {
        filtered = filtered.where((l) => l.fromDate.isAfter(fromDate)).toList();
      }
      if (toDate != null) {
        filtered = filtered.where((l) => l.toDate.isBefore(toDate)).toList();
      }

      // Pagination
      final startIndex = (page - 1) * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, filtered.length);
      final paginatedList = filtered.sublist(
        startIndex,
        endIndex.clamp(0, filtered.length),
      );

      return ListResponse(
        items: paginatedList,
        totalCount: filtered.length,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
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
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final filtered = _fakeLeaves
          .where((l) => l.employeeId == employeeId)
          .toList();

      final startIndex = (page - 1) * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, filtered.length);
      final paginatedList = filtered.sublist(
        startIndex,
        endIndex.clamp(0, filtered.length),
      );

      return ListResponse(
        items: paginatedList,
        totalCount: filtered.length,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch employee leaves: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
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
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // Check leave balance
      final balance = _leaveBalance[employeeId] ?? {};
      final available = balance[leaveType] ?? 0;

      if (available < noOfDays) {
        throw ApiException(
          message: 'Insufficient leave balance',
          errorCode: 'INSUFFICIENT_BALANCE',
        );
      }

      final leave = Leave(
        id: 'LEAVE${DateTime.now().millisecondsSinceEpoch}',
        employeeId: employeeId,
        employeeName: employeeName,
        fromDate: fromDate,
        toDate: toDate,
        leaveType: leaveType,
        noOfDays: noOfDays,
        status: 'pending',
        reason: reason,
      );

      _fakeLeaves.add(leave);
      return leave;
    } catch (e) {
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
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final index = _fakeLeaves.indexWhere((l) => l.id == leaveId);

      if (index == -1) {
        throw ApiException(
          message: 'Leave request not found',
          errorCode: 'NOT_FOUND',
        );
      }

      final leave = _fakeLeaves[index];
      final approvedLeave = Leave(
        id: leave.id,
        employeeId: leave.employeeId,
        employeeName: leave.employeeName,
        fromDate: leave.fromDate,
        toDate: leave.toDate,
        leaveType: leave.leaveType,
        noOfDays: leave.noOfDays,
        status: 'approved',
        reason: leave.reason,
        approverName: approverName,
        approvedDate: DateTime.now(),
      );

      _fakeLeaves[index] = approvedLeave;

      // Update leave balance
      _leaveBalance[leave.employeeId] ??= {};
      _leaveBalance[leave.employeeId]![leave.leaveType] =
          (_leaveBalance[leave.employeeId]![leave.leaveType] ?? 0) -
          leave.noOfDays;

      return approvedLeave;
    } catch (e) {
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
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final index = _fakeLeaves.indexWhere((l) => l.id == leaveId);

      if (index == -1) {
        throw ApiException(
          message: 'Leave request not found',
          errorCode: 'NOT_FOUND',
        );
      }

      final leave = _fakeLeaves[index];
      final rejectedLeave = Leave(
        id: leave.id,
        employeeId: leave.employeeId,
        employeeName: leave.employeeName,
        fromDate: leave.fromDate,
        toDate: leave.toDate,
        leaveType: leave.leaveType,
        noOfDays: leave.noOfDays,
        status: 'rejected',
        reason: leave.reason,
        approverName: approverName,
        approvedDate: DateTime.now(),
      );

      _fakeLeaves[index] = rejectedLeave;
      return rejectedLeave;
    } catch (e) {
      throw ApiException(
        message: 'Failed to reject leave: $e',
        errorCode: 'REJECT_ERROR',
      );
    }
  }

  /// Get leave balance
  Future<Map<String, int>> getLeaveBalance(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _leaveBalance[employeeId] ?? _getDefaultLeaveBalance();
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch leave balance: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get leave balance for all employees
  Future<Map<String, Map<String, int>>> getAllLeaveBalance() async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      return _leaveBalance;
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch leave balance: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Cancel leave application
  Future<bool> cancelLeave(String leaveId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = _fakeLeaves.indexWhere((l) => l.id == leaveId);

      if (index == -1) {
        throw ApiException(
          message: 'Leave request not found',
          errorCode: 'NOT_FOUND',
        );
      }

      final leave = _fakeLeaves[index];

      if (leave.status == 'approved') {
        // Refund leave balance
        _leaveBalance[leave.employeeId] ??= {};
        _leaveBalance[leave.employeeId]![leave.leaveType] =
            (_leaveBalance[leave.employeeId]![leave.leaveType] ?? 0) +
            leave.noOfDays;
      }

      _fakeLeaves.removeAt(index);
      return true;
    } catch (e) {
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
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final filtered = _fakeLeaves.where((l) => l.status == 'pending').toList();

      final startIndex = (page - 1) * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, filtered.length);
      final paginatedList = filtered.sublist(
        startIndex,
        endIndex.clamp(0, filtered.length),
      );

      return ListResponse(
        items: paginatedList,
        totalCount: filtered.length,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch pending leaves: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Default leave balance
  static Map<String, int> _getDefaultLeaveBalance() {
    return {
      'casual': 12,
      'sick': 6,
      'earned': 15,
      'personal': 3,
      'maternity': 0,
    };
  }

  /// Generate fake leave data
  static List<Leave> _generateFakeLeaves() {
    final List<Leave> leaves = [];
    final employees = [
      {'id': 'EMP001', 'name': 'John Doe'},
      {'id': 'EMP002', 'name': 'Jane Smith'},
      {'id': 'EMP003', 'name': 'Mike Johnson'},
      {'id': 'EMP004', 'name': 'Sarah Williams'},
    ];

    final leaveTypes = ['casual', 'sick', 'earned', 'personal'];
    final now = DateTime.now();

    for (int i = 0; i < employees.length; i++) {
      for (int j = 0; j < 3; j++) {
        final fromDate = now.add(Duration(days: j * 30));
        final toDate = fromDate.add(Duration(days: 3));

        leaves.add(
          Leave(
            id: 'LEAVE${now.millisecondsSinceEpoch}$i$j',
            employeeId: employees[i]['id']!,
            employeeName: employees[i]['name']!,
            fromDate: fromDate,
            toDate: toDate,
            leaveType: leaveTypes[j % leaveTypes.length],
            noOfDays: 3,
            status: ['pending', 'approved', 'rejected'][j % 3],
            reason: 'Personal reasons',
            approverName: j == 1 ? 'Manager' : null,
            approvedDate: j == 1 ? DateTime.now() : null,
          ),
        );
      }
    }

    return leaves;
  }

  /// Generate leave balance
  static Map<String, Map<String, int>> _generateLeaveBalance() {
    final Map<String, Map<String, int>> balance = {};
    final employees = [
      'EMP001',
      'EMP002',
      'EMP003',
      'EMP004',
      'EMP005',
      'EMP006',
      'EMP007',
      'EMP008',
    ];

    for (var empId in employees) {
      balance[empId] = {
        'casual': 10,
        'sick': 4,
        'earned': 12,
        'personal': 2,
        'maternity': 0,
      };
    }

    return balance;
  }
}
