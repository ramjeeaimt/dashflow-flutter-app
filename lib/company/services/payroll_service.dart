import 'api_service.dart';
import 'models.dart';
import 'dart:async';

/// Payroll Service
class PayrollService {
  final ApiService apiService;
  static const String _endpoint = '/api/payroll';

  // Fake data storage
  static final List<Payroll> _fakePayrolls = _generateFakePayrolls();

  PayrollService({required this.apiService});

  /// Get all payrolls with pagination
  Future<ListResponse<Payroll>> getAllPayrolls({
    int page = 1,
    int pageSize = 10,
    String? employeeId,
    String? status,
    int? month,
    int? year,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      List<Payroll> filtered = _fakePayrolls;

      // Filter by employeeId
      if (employeeId != null && employeeId.isNotEmpty) {
        filtered = filtered.where((p) => p.employeeId == employeeId).toList();
      }

      // Filter by status
      if (status != null && status.isNotEmpty) {
        filtered = filtered.where((p) => p.status == status).toList();
      }

      // Filter by month
      if (month != null) {
        filtered = filtered.where((p) => p.month == month).toList();
      }

      // Filter by year
      if (year != null) {
        filtered = filtered.where((p) => p.year == year).toList();
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
        message: 'Failed to fetch payrolls: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get payroll for employee
  Future<ListResponse<Payroll>> getEmployeePayroll({
    required String employeeId,
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final filtered = _fakePayrolls
          .where((p) => p.employeeId == employeeId)
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
        message: 'Failed to fetch employee payroll: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get payroll for specific month and year
  Future<Payroll> getPayrollByMonth({
    required String employeeId,
    required int month,
    required int year,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final payroll = _fakePayrolls.firstWhere(
        (p) => p.employeeId == employeeId && p.month == month && p.year == year,
      );
      return payroll;
    } catch (e) {
      throw ApiException(
        message: 'Payroll not found',
        statusCode: 404,
        errorCode: 'NOT_FOUND',
      );
    }
  }

  /// Process payroll
  Future<Payroll> processPayroll({required String payrollId}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final index = _fakePayrolls.indexWhere((p) => p.id == payrollId);

      if (index == -1) {
        throw ApiException(
          message: 'Payroll not found',
          statusCode: 404,
          errorCode: 'NOT_FOUND',
        );
      }

      final payroll = _fakePayrolls[index];
      final processedPayroll = Payroll(
        id: payroll.id,
        employeeId: payroll.employeeId,
        employeeName: payroll.employeeName,
        month: payroll.month,
        year: payroll.year,
        basicSalary: payroll.basicSalary,
        hra: payroll.hra,
        da: payroll.da,
        specialAllowance: payroll.specialAllowance,
        attendance: payroll.attendance,
        totalEarnings: payroll.totalEarnings,
        incomeTax: payroll.incomeTax,
        pfDeduction: payroll.pfDeduction,
        professionalTax: payroll.professionalTax,
        otherDeductions: payroll.otherDeductions,
        totalDeductions: payroll.totalDeductions,
        netSalary: payroll.netSalary,
        status: 'processed',
      );

      _fakePayrolls[index] = processedPayroll;
      return processedPayroll;
    } catch (e) {
      throw ApiException(
        message: 'Failed to process payroll: $e',
        errorCode: 'PROCESS_ERROR',
      );
    }
  }

  /// Release payroll
  Future<Payroll> releasePayroll({required String payrollId}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final index = _fakePayrolls.indexWhere((p) => p.id == payrollId);

      if (index == -1) {
        throw ApiException(
          message: 'Payroll not found',
          statusCode: 404,
          errorCode: 'NOT_FOUND',
        );
      }

      final payroll = _fakePayrolls[index];
      final releasedPayroll = Payroll(
        id: payroll.id,
        employeeId: payroll.employeeId,
        employeeName: payroll.employeeName,
        month: payroll.month,
        year: payroll.year,
        basicSalary: payroll.basicSalary,
        hra: payroll.hra,
        da: payroll.da,
        specialAllowance: payroll.specialAllowance,
        attendance: payroll.attendance,
        totalEarnings: payroll.totalEarnings,
        incomeTax: payroll.incomeTax,
        pfDeduction: payroll.pfDeduction,
        professionalTax: payroll.professionalTax,
        otherDeductions: payroll.otherDeductions,
        totalDeductions: payroll.totalDeductions,
        netSalary: payroll.netSalary,
        status: 'released',
        releaseDate: DateTime.now(),
      );

      _fakePayrolls[index] = releasedPayroll;
      return releasedPayroll;
    } catch (e) {
      throw ApiException(
        message: 'Failed to release payroll: $e',
        errorCode: 'RELEASE_ERROR',
      );
    }
  }

  /// Get pending payrolls
  Future<ListResponse<Payroll>> getPendingPayrolls({
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final filtered = _fakePayrolls
          .where((p) => p.status == 'pending')
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
        message: 'Failed to fetch pending payrolls: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Download payroll slip
  Future<String> downloadPayrollSlip({required String payrollId}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final payroll = _fakePayrolls.firstWhere((p) => p.id == payrollId);

      // Generate PDF URL (fake)
      final pdfUrl =
          'https://example.com/payroll/${payroll.employeeId}_${payroll.month}_${payroll.year}.pdf';

      return pdfUrl;
    } catch (e) {
      throw ApiException(
        message: 'Failed to download payroll slip: $e',
        errorCode: 'DOWNLOAD_ERROR',
      );
    }
  }

  /// Get payroll statistics
  Future<Map<String, dynamic>> getPayrollStats({
    required int month,
    required int year,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final monthPayrolls = _fakePayrolls
          .where((p) => p.month == month && p.year == year)
          .toList();

      final totalEarnings = monthPayrolls.fold<double>(
        0,
        (sum, p) => sum + p.totalEarnings,
      );
      final totalDeductions = monthPayrolls.fold<double>(
        0,
        (sum, p) => sum + p.totalDeductions,
      );
      final totalNetSalary = monthPayrolls.fold<double>(
        0,
        (sum, p) => sum + p.netSalary,
      );

      final processed = monthPayrolls
          .where((p) => p.status == 'processed')
          .length;
      final released = monthPayrolls
          .where((p) => p.status == 'released')
          .length;
      final pending = monthPayrolls.where((p) => p.status == 'pending').length;

      return {
        'month': month,
        'year': year,
        'totalEmployees': monthPayrolls.length,
        'totalEarnings': totalEarnings,
        'totalDeductions': totalDeductions,
        'totalNetSalary': totalNetSalary,
        'processedCount': processed,
        'releasedCount': released,
        'pendingCount': pending,
        'averageSalary': monthPayrolls.isNotEmpty
            ? totalNetSalary / monthPayrolls.length
            : 0,
      };
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch payroll stats: $e',
        errorCode: 'STATS_ERROR',
      );
    }
  }

  /// Generate fake payroll data
  static List<Payroll> _generateFakePayrolls() {
    final List<Payroll> payrolls = [];
    final employees = [
      {'id': 'EMP001', 'name': 'John Doe', 'basicSalary': 75000.0},
      {'id': 'EMP002', 'name': 'Jane Smith', 'basicSalary': 85000.0},
      {'id': 'EMP003', 'name': 'Mike Johnson', 'basicSalary': 65000.0},
      {'id': 'EMP004', 'name': 'Sarah Williams', 'basicSalary': 70000.0},
      {'id': 'EMP005', 'name': 'Robert Brown', 'basicSalary': 72000.0},
      {'id': 'EMP006', 'name': 'Emily Davis', 'basicSalary': 50000.0},
      {'id': 'EMP007', 'name': 'David Wilson', 'basicSalary': 68000.0},
      {'id': 'EMP008', 'name': 'Lisa Anderson', 'basicSalary': 55000.0},
    ];

    final statuses = ['pending', 'processed', 'released'];
    final now = DateTime.now();

    // Generate payroll for last 6 months
    for (int month = 1; month <= 6; month++) {
      for (var emp in employees) {
        final basicSalary = (emp['basicSalary'] as double);
        final hra = basicSalary * 0.15;
        final da = basicSalary * 0.10;
        final specialAllowance = basicSalary * 0.05;
        final attendance = basicSalary * 0.02;
        final totalEarnings =
            basicSalary + hra + da + specialAllowance + attendance;

        final incomeTax = totalEarnings * 0.10;
        final pfDeduction = basicSalary * 0.12;
        final professionalTax = 200;
        final otherDeductions = 500;
        final totalDeductions =
            incomeTax + pfDeduction + professionalTax + otherDeductions;

        final netSalary = totalEarnings - totalDeductions;

        payrolls.add(
          Payroll(
            id: 'PAY$month${emp['id']}',
            employeeId: emp['id']! as String,
            employeeName: emp['name']! as String,
            month: month,
            year: now.year,
            basicSalary: basicSalary,
            hra: hra,
            da: da,
            specialAllowance: specialAllowance,
            attendance: attendance,
            totalEarnings: totalEarnings,
            incomeTax: incomeTax,
            pfDeduction: pfDeduction,
            professionalTax: professionalTax,
            otherDeductions: otherDeductions,
            totalDeductions: totalDeductions,
            netSalary: netSalary,
            status: statuses[month % 3],
            releaseDate: month % 3 == 2 ? DateTime.now() : null,
          ),
        );
      }
    }

    return payrolls;
  }
}
