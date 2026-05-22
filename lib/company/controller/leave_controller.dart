import 'package:get/get.dart';

class LeaveController extends GetxController {
  var leaveList = <Leave>[].obs;
  var isLoading = false.obs;
  var selectedStatus = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  void fetchLeaves() {
    isLoading(true);
    try {
      // API call करें
      leaveList.addAll([
        Leave(
          id: 'L001',
          employeeId: 'EMP001',
          employeeName: 'राज कुमार',
          leaveType: 'Casual',
          startDate: DateTime.now().add(Duration(days: 2)),
          endDate: DateTime.now().add(Duration(days: 4)),
          numberOfDays: 3,
          reason: 'Personal work',
          status: 'Pending',
          appliedDate: DateTime.now(),
        ),
        Leave(
          id: 'L002',
          employeeId: 'EMP002',
          employeeName: 'प्रिया शर्मा',
          leaveType: 'Sick',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          numberOfDays: 1,
          reason: 'Not feeling well',
          status: 'Approved',
          appliedDate: DateTime.now().subtract(Duration(days: 1)),
        ),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch leaves: $e');
    } finally {
      isLoading(false);
    }
  }

  void applyLeave(Leave leave) {
    try {
      leaveList.add(leave);
      Get.snackbar('Success', 'Leave application submitted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply leave: $e');
    }
  }

  void approveLeave(String leaveId) {
    try {
      final index = leaveList.indexWhere((l) => l.id == leaveId);
      if (index != -1) {
        leaveList[index].status = 'Approved';
        leaveList.refresh();
        Get.snackbar('Success', 'Leave approved');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve leave: $e');
    }
  }

  void rejectLeave(String leaveId, String reason) {
    try {
      final index = leaveList.indexWhere((l) => l.id == leaveId);
      if (index != -1) {
        leaveList[index].status = 'Rejected';
        leaveList.refresh();
        Get.snackbar('Success', 'Leave rejected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject leave: $e');
    }
  }

  void cancelLeave(String leaveId) {
    try {
      leaveList.removeWhere((l) => l.id == leaveId);
      Get.snackbar('Success', 'Leave cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel leave: $e');
    }
  }

  void filterByStatus(String status) {
    selectedStatus(status);
  }

  List<Leave> getFilteredLeaves() {
    if (selectedStatus.value == 'All') {
      return leaveList;
    }
    return leaveList
        .where((leave) => leave.status == selectedStatus.value)
        .toList();
  }

  int getRemainingLeaves(String employeeId, String leaveType) {
    // Implement logic to calculate remaining leaves
    return 10; // Example
  }

  int getLeaveTaken(String employeeId, String leaveType) {
    return leaveList
        .where(
          (l) =>
              l.employeeId == employeeId &&
              l.leaveType == leaveType &&
              l.status == 'Approved',
        )
        .fold(0, (sum, leave) => sum + leave.numberOfDays);
  }
}

class Leave {
  String id;
  String employeeId;
  String employeeName;
  String leaveType; // Casual, Sick, Earned, etc.
  DateTime startDate;
  DateTime endDate;
  int numberOfDays;
  String reason;
  String status; // Pending, Approved, Rejected
  DateTime appliedDate;

  Leave({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.reason,
    required this.status,
    required this.appliedDate,
  });
}
