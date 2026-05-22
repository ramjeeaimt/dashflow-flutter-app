import 'api_service.dart';
import 'models.dart';
import 'dart:async';

/// Attendance Service
class AttendanceService {
  final ApiService apiService;
  static const String _endpoint = '/api/attendance';

  // Fake data storage
  static final List<Attendance> _fakeAttendances = _generateFakeAttendances();

  AttendanceService({required this.apiService});

  /// Get all attendances with pagination
  Future<ListResponse<Attendance>> getAllAttendances({
    int page = 1,
    int pageSize = 10,
    String? employeeId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      List<Attendance> filtered = _fakeAttendances;

      // Filter by employeeId
      if (employeeId != null && employeeId.isNotEmpty) {
        filtered = filtered.where((a) => a.employeeId == employeeId).toList();
      }

      // Filter by date range
      if (fromDate != null) {
        filtered = filtered.where((a) => a.date.isAfter(fromDate)).toList();
      }
      if (toDate != null) {
        filtered = filtered.where((a) => a.date.isBefore(toDate)).toList();
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
        message: 'Failed to fetch attendances: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get attendance for specific employee
  Future<ListResponse<Attendance>> getEmployeeAttendance({
    required String employeeId,
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final filtered = _fakeAttendances
          .where((a) => a.employeeId == employeeId)
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
        message: 'Failed to fetch employee attendance: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Mark check-in
  Future<Attendance> markCheckIn({
    required String employeeId,
    required String employeeName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final now = DateTime.now();
      final attendance = Attendance(
        id: 'ATT${DateTime.now().millisecondsSinceEpoch}',
        employeeId: employeeId,
        employeeName: employeeName,
        date: now,
        checkInTime:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        status: 'present',
      );

      _fakeAttendances.add(attendance);
      return attendance;
    } catch (e) {
      throw ApiException(
        message: 'Failed to mark check-in: $e',
        errorCode: 'CHECK_IN_ERROR',
      );
    }
  }

  /// Mark check-out
  Future<Attendance> markCheckOut({
    required String employeeId,
    required String attendanceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = _fakeAttendances.indexWhere(
        (a) => a.id == attendanceId && a.employeeId == employeeId,
      );

      if (index == -1) {
        throw ApiException(
          message: 'Attendance record not found',
          errorCode: 'NOT_FOUND',
        );
      }

      final now = DateTime.now();
      final checkOutTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final updatedAttendance = Attendance(
        id: _fakeAttendances[index].id,
        employeeId: _fakeAttendances[index].employeeId,
        employeeName: _fakeAttendances[index].employeeName,
        date: _fakeAttendances[index].date,
        checkInTime: _fakeAttendances[index].checkInTime,
        checkOutTime: checkOutTime,
        status: _fakeAttendances[index].status,
        remarks: _fakeAttendances[index].remarks,
      );

      _fakeAttendances[index] = updatedAttendance;
      return updatedAttendance;
    } catch (e) {
      throw ApiException(
        message: 'Failed to mark check-out: $e',
        errorCode: 'CHECK_OUT_ERROR',
      );
    }
  }

  /// Get attendance report
  Future<Map<String, dynamic>> getAttendanceReport({
    required String employeeId,
    required int month,
    required int year,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final employeeAttendances = _fakeAttendances
          .where((a) => a.employeeId == employeeId)
          .toList();

      final present = employeeAttendances
          .where((a) => a.status == 'present')
          .length;
      final absent = employeeAttendances
          .where((a) => a.status == 'absent')
          .length;
      final late = employeeAttendances.where((a) => a.status == 'late').length;
      final halfDay = employeeAttendances
          .where((a) => a.status == 'half-day')
          .length;

      return {
        'employeeId': employeeId,
        'month': month,
        'year': year,
        'present': present,
        'absent': absent,
        'late': late,
        'halfDay': halfDay,
        'percentage': present / (present + absent + late + halfDay) * 100,
      };
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch attendance report: $e',
        errorCode: 'REPORT_ERROR',
      );
    }
  }

  /// Generate fake attendance data
  static List<Attendance> _generateFakeAttendances() {
    final List<Attendance> attendances = [];
    final now = DateTime.now();
    final employees = [
      {'id': 'EMP001', 'name': 'John Doe'},
      {'id': 'EMP002', 'name': 'Jane Smith'},
      {'id': 'EMP003', 'name': 'Mike Johnson'},
      {'id': 'EMP004', 'name': 'Sarah Williams'},
    ];

    // Generate last 30 days of data
    for (int i = 0; i < 30; i++) {
      for (var emp in employees) {
        final date = now.subtract(Duration(days: i));

        // Skip weekends
        if (date.weekday != 6 && date.weekday != 7) {
          final status = [
            'present',
            'absent',
            'late',
            'half-day',
          ][i % 4]; // Rotate through statuses
          final checkInTime = status == 'absent'
              ? '00:00'
              : status == 'late'
              ? '10:15'
              : '09:00';

          attendances.add(
            Attendance(
              id: 'ATT${date.millisecondsSinceEpoch}${emp['id']}',
              employeeId: emp['id']!,
              employeeName: emp['name']!,
              date: date,
              checkInTime: checkInTime,
              checkOutTime: status == 'absent' ? null : '18:00',
              status: status,
            ),
          );
        }
      }
    }

    return attendances;
  }
}
