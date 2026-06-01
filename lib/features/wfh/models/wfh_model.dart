enum WfhStatus { pending, approved, rejected }

class WfhRequestModel {
  final String id;
  final String employeeId;
  final String? userId;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final WfhStatus status;
  final String? adminComment;
  final DateTime createdAt;

  WfhRequestModel({
    required this.id,
    required this.employeeId,
    this.userId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.adminComment,
    required this.createdAt,
  });

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  String get dateRangeFormatted {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final startStr = "${startDate.day} ${months[startDate.month]} ${startDate.year}";
    final endStr = "${endDate.day} ${months[endDate.month]} ${endDate.year}";
    if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day) {
      return startStr;
    }
    return "$startStr – $endStr";
  }

  factory WfhRequestModel.fromJson(Map<String, dynamic> json, {String defaultEmployeeName = "Employee"}) {
    WfhStatus stat = WfhStatus.pending;
    final statusString = (json['status'] ?? '').toString().toUpperCase();
    if (statusString == 'APPROVED') {
      stat = WfhStatus.approved;
    } else if (statusString == 'REJECTED' || statusString == 'DECLINED') {
      stat = WfhStatus.rejected;
    }

    final startStr = json['startDate'] ?? '';
    final endStr = json['endDate'] ?? '';
    final createStr = json['createdAt'] ?? '';

    final start = DateTime.tryParse(startStr) ?? DateTime.now();
    final end = DateTime.tryParse(endStr) ?? start;
    final create = DateTime.tryParse(createStr) ?? DateTime.now();

    String empName = defaultEmployeeName;
    String empId = '';
    String? usrId;

    if (json['employee'] is Map) {
      final empMap = json['employee'] as Map;
      empId = empMap['id']?.toString() ?? empMap['_id']?.toString() ?? '';
      usrId = empMap['userId']?.toString();
      
      if (empMap['user'] is Map) {
        final userMap = empMap['user'] as Map;
        final firstName = userMap['firstName'] ?? '';
        final lastName = userMap['lastName'] ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          empName = "$firstName $lastName".trim();
        } else {
          empName = userMap['name'] ?? defaultEmployeeName;
        }
      }
    } else if (json['employeeId'] is Map) {
      final empMap = json['employeeId'] as Map;
      empId = empMap['_id']?.toString() ?? empMap['id']?.toString() ?? '';
      usrId = empMap['userId']?.toString();
      final firstName = empMap['firstName'] ?? '';
      final lastName = empMap['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        empName = "$firstName $lastName".trim();
      } else {
        empName = empMap['name'] ?? defaultEmployeeName;
      }
    } else {
      empId = json['employeeId']?.toString() ?? '';
      if (json['employeeName'] != null) {
        empName = json['employeeName'];
      }
    }

    return WfhRequestModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      employeeId: empId,
      userId: usrId,
      employeeName: empName,
      startDate: start.toLocal(),
      endDate: end.toLocal(),
      reason: json['reason'] ?? '',
      status: stat,
      adminComment: json['adminComment'],
      createdAt: create.toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'reason': reason,
      'status': status.name.toUpperCase(),
      'adminComment': adminComment,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
