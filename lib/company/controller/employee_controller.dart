import 'package:get/get.dart';

class EmployeeController extends GetxController {
  var employeeList = <Employee>[].obs;
  var filteredEmployeeList = <Employee>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  void fetchEmployees() {
    isLoading(true);
    try {
      // API call करें
      employeeList.addAll([
        Employee(
          id: 'EMP001',
          name: 'राज कुमार',
          email: 'raj@example.com',
          phone: '9876543210',
          department: 'IT',
          designation: 'Developer',
          salary: 50000,
          joinDate: DateTime(2022, 01, 15),
        ),
        Employee(
          id: 'EMP002',
          name: 'प्रिया शर्मा',
          email: 'priya@example.com',
          phone: '9876543211',
          department: 'HR',
          designation: 'HR Manager',
          salary: 45000,
          joinDate: DateTime(2021, 06, 20),
        ),
      ]);
      filteredEmployeeList.value = employeeList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch employees: $e');
    } finally {
      isLoading(false);
    }
  }

  void addEmployee(Employee employee) {
    try {
      employeeList.add(employee);
      filteredEmployeeList.value = employeeList;
      Get.snackbar('Success', 'Employee added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add employee: $e');
    }
  }

  void updateEmployee(String id, Employee updatedEmployee) {
    try {
      final index = employeeList.indexWhere((emp) => emp.id == id);
      if (index != -1) {
        employeeList[index] = updatedEmployee;
        employeeList.refresh();
        filteredEmployeeList.value = employeeList;
        Get.snackbar('Success', 'Employee updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update employee: $e');
    }
  }

  void deleteEmployee(String id) {
    try {
      employeeList.removeWhere((emp) => emp.id == id);
      filteredEmployeeList.value = employeeList;
      Get.snackbar('Success', 'Employee deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete employee: $e');
    }
  }

  void searchEmployee(String query) {
    searchQuery(query);
    if (query.isEmpty) {
      filteredEmployeeList.value = employeeList;
    } else {
      filteredEmployeeList.value = employeeList
          .where(
            (emp) =>
                emp.name.toLowerCase().contains(query.toLowerCase()) ||
                emp.id.contains(query),
          )
          .toList();
    }
  }

  void filterByDepartment(String department) {
    if (department.isEmpty) {
      filteredEmployeeList.value = employeeList;
    } else {
      filteredEmployeeList.value = employeeList
          .where((emp) => emp.department == department)
          .toList();
    }
  }
}

class Employee {
  String id;
  String name;
  String email;
  String phone;
  String department;
  String designation;
  double salary;
  DateTime joinDate;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.salary,
    required this.joinDate,
  });
}
