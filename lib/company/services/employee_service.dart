import 'api_service.dart';
import 'models.dart';
import 'dart:async';

/// Employee Service
class EmployeeService {
  final ApiService apiService;
  static const String _endpoint = '/api/employees';

  // Fake data storage
  static final List<Employee> _fakeEmployees = _generateFakeEmployees();

  EmployeeService({required this.apiService});

  /// Get all employees with pagination
  Future<ListResponse<Employee>> getAllEmployees({
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
    String? department,
    String? status,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      List<Employee> filtered = _fakeEmployees;

      // Search by name or email
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered
            .where(
              (e) =>
                  e.name.toLowerCase().contains(query) ||
                  e.email.toLowerCase().contains(query),
            )
            .toList();
      }

      // Filter by department
      if (department != null && department.isNotEmpty) {
        filtered = filtered.where((e) => e.department == department).toList();
      }

      // Filter by status
      if (status != null && status.isNotEmpty) {
        filtered = filtered.where((e) => e.status == status).toList();
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
        message: 'Failed to fetch employees: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get employee by ID
  Future<Employee> getEmployeeById(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final employee = _fakeEmployees.firstWhere((e) => e.id == employeeId);
      return employee;
    } catch (e) {
      throw ApiException(
        message: 'Employee not found',
        statusCode: 404,
        errorCode: 'NOT_FOUND',
      );
    }
  }

  /// Create new employee
  Future<Employee> createEmployee({
    required String name,
    required String email,
    required String phone,
    required String designation,
    required String department,
    required double salary,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final employee = Employee(
        id: 'EMP${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        designation: designation,
        department: department,
        salary: salary,
        joinDate: DateTime.now(),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=${name.split(' ')[0]}',
      );

      _fakeEmployees.add(employee);
      return employee;
    } catch (e) {
      throw ApiException(
        message: 'Failed to create employee: $e',
        errorCode: 'CREATE_ERROR',
      );
    }
  }

  /// Update employee
  Future<Employee> updateEmployee({
    required String employeeId,
    required String name,
    required String email,
    required String phone,
    required String designation,
    required String department,
    required double salary,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final index = _fakeEmployees.indexWhere((e) => e.id == employeeId);

      if (index == -1) {
        throw ApiException(
          message: 'Employee not found',
          statusCode: 404,
          errorCode: 'NOT_FOUND',
        );
      }

      final updatedEmployee = Employee(
        id: employeeId,
        name: name,
        email: email,
        phone: phone,
        designation: designation,
        department: department,
        salary: salary,
        joinDate: _fakeEmployees[index].joinDate,
        status: status,
        imageUrl: _fakeEmployees[index].imageUrl,
      );

      _fakeEmployees[index] = updatedEmployee;
      return updatedEmployee;
    } catch (e) {
      throw ApiException(
        message: 'Failed to update employee: $e',
        errorCode: 'UPDATE_ERROR',
      );
    }
  }

  /// Delete employee
  Future<bool> deleteEmployee(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = _fakeEmployees.indexWhere((e) => e.id == employeeId);

      if (index == -1) {
        throw ApiException(
          message: 'Employee not found',
          statusCode: 404,
          errorCode: 'NOT_FOUND',
        );
      }

      _fakeEmployees.removeAt(index);
      return true;
    } catch (e) {
      throw ApiException(
        message: 'Failed to delete employee: $e',
        errorCode: 'DELETE_ERROR',
      );
    }
  }

  /// Get employees by department
  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      return _fakeEmployees.where((e) => e.department == department).toList();
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch employees: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get department list
  Future<List<String>> getDepartments() async {
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final departments = _fakeEmployees
          .map((e) => e.department)
          .toSet()
          .toList();
      return departments;
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch departments: $e',
        errorCode: 'FETCH_ERROR',
      );
    }
  }

  /// Get employee statistics
  Future<Map<String, dynamic>> getEmployeeStats() async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final totalEmployees = _fakeEmployees.length;
      final activeEmployees = _fakeEmployees
          .where((e) => e.status == 'active')
          .length;
      final inactiveEmployees = _fakeEmployees
          .where((e) => e.status == 'inactive')
          .length;
      final onLeaveEmployees = _fakeEmployees
          .where((e) => e.status == 'on-leave')
          .length;

      final departments = _fakeEmployees
          .map((e) => e.department)
          .toSet()
          .toList();

      return {
        'totalEmployees': totalEmployees,
        'activeEmployees': activeEmployees,
        'inactiveEmployees': inactiveEmployees,
        'onLeaveEmployees': onLeaveEmployees,
        'departmentCount': departments.length,
        'averageSalary': _fakeEmployees.isNotEmpty
            ? _fakeEmployees.map((e) => e.salary).reduce((a, b) => a + b) /
                  totalEmployees
            : 0,
      };
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch employee stats: $e',
        errorCode: 'STATS_ERROR',
      );
    }
  }

  /// Generate fake employee data
  static List<Employee> _generateFakeEmployees() {
    return [
      Employee(
        id: 'EMP001',
        name: 'John Doe',
        email: 'john.doe@company.com',
        phone: '+91 98765 43210',
        designation: 'Senior Developer',
        department: 'IT',
        salary: 75000,
        joinDate: DateTime(2020, 5, 15),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=JD',
      ),
      Employee(
        id: 'EMP002',
        name: 'Jane Smith',
        email: 'jane.smith@company.com',
        phone: '+91 98765 43211',
        designation: 'Product Manager',
        department: 'Product',
        salary: 85000,
        joinDate: DateTime(2019, 8, 20),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=JS',
      ),
      Employee(
        id: 'EMP003',
        name: 'Mike Johnson',
        email: 'mike.johnson@company.com',
        phone: '+91 98765 43212',
        designation: 'UI/UX Designer',
        department: 'Design',
        salary: 65000,
        joinDate: DateTime(2021, 3, 10),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=MJ',
      ),
      Employee(
        id: 'EMP004',
        name: 'Sarah Williams',
        email: 'sarah.williams@company.com',
        phone: '+91 98765 43213',
        designation: 'HR Manager',
        department: 'HR',
        salary: 70000,
        joinDate: DateTime(2018, 11, 5),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=SW',
      ),
      Employee(
        id: 'EMP005',
        name: 'Robert Brown',
        email: 'robert.brown@company.com',
        phone: '+91 98765 43214',
        designation: 'Finance Manager',
        department: 'Finance',
        salary: 72000,
        joinDate: DateTime(2017, 6, 12),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=RB',
      ),
      Employee(
        id: 'EMP006',
        name: 'Emily Davis',
        email: 'emily.davis@company.com',
        phone: '+91 98765 43215',
        designation: 'Junior Developer',
        department: 'IT',
        salary: 50000,
        joinDate: DateTime(2022, 1, 15),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=ED',
      ),
      Employee(
        id: 'EMP007',
        name: 'David Wilson',
        email: 'david.wilson@company.com',
        phone: '+91 98765 43216',
        designation: 'Sales Manager',
        department: 'Sales',
        salary: 68000,
        joinDate: DateTime(2020, 9, 8),
        status: 'on-leave',
        imageUrl: 'https://via.placeholder.com/150?text=DW',
      ),
      Employee(
        id: 'EMP008',
        name: 'Lisa Anderson',
        email: 'lisa.anderson@company.com',
        phone: '+91 98765 43217',
        designation: 'Content Writer',
        department: 'Marketing',
        salary: 55000,
        joinDate: DateTime(2021, 7, 20),
        status: 'active',
        imageUrl: 'https://via.placeholder.com/150?text=LA',
      ),
    ];
  }
}
