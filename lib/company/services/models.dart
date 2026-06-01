class Leave {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime fromDate;
  final DateTime toDate;
  final String leaveType;
  final int noOfDays;
  final String status;
  final String reason;
  final String? approverName;
  final DateTime? approvedDate;

  Leave({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.noOfDays,
    required this.status,
    required this.reason,
    this.approverName,
    this.approvedDate,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] ?? json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      fromDate: json['fromDate'] != null
          ? DateTime.parse(json['fromDate'])
          : (json['startDate'] != null
              ? DateTime.parse(json['startDate'])
              : DateTime.now()),
      toDate: json['toDate'] != null
          ? DateTime.parse(json['toDate'])
          : (json['endDate'] != null
              ? DateTime.parse(json['endDate'])
              : DateTime.now()),
      leaveType: json['leaveType'] ?? json['type'] ?? '',
      noOfDays: json['noOfDays'] ?? json['numberOfDays'] ?? 0,
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      approverName: json['approverName'] ?? json['adminComment'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'leaveType': leaveType,
      'noOfDays': noOfDays,
      'status': status,
      'reason': reason,
      'approverName': approverName,
      'approvedDate': approvedDate?.toIso8601String(),
    };
  }
}

class Attendance {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkInTime;
  final String? checkOutTime;
  final String status;
  final String? remarks;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.remarks,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      checkInTime: json['checkInTime'] ?? json['checkIn'] ?? '',
      checkOutTime: json['checkOutTime'] ?? json['checkOut'],
      status: json['status'] ?? '',
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'remarks': remarks,
    };
  }
}

class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String department;
  final double salary;
  final DateTime joinDate;
  final String status;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.department,
    required this.salary,
    required this.joinDate,
    required this.status,
    required this.imageUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : DateTime.now(),
      status: json['status'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'department': department,
      'salary': salary,
      'joinDate': joinDate.toIso8601String(),
      'status': status,
      'imageUrl': imageUrl,
    };
  }
}

class Payroll {
  final String id;
  final String employeeId;
  final String employeeName;
  final int month;
  final int year;
  final double basicSalary;
  final double hra;
  final double da;
  final double specialAllowance;
  final double attendance;
  final double totalEarnings;
  final double incomeTax;
  final double pfDeduction;
  final double professionalTax;
  final double otherDeductions;
  final double totalDeductions;
  final double netSalary;
  final String status;
  final DateTime? releaseDate;

  Payroll({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.hra,
    required this.da,
    required this.specialAllowance,
    required this.attendance,
    required this.totalEarnings,
    required this.incomeTax,
    required this.pfDeduction,
    required this.professionalTax,
    required this.otherDeductions,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
    this.releaseDate,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'] ?? json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      basicSalary: (json['basicSalary'] as num?)?.toDouble() ?? 0.0,
      hra: (json['hra'] as num?)?.toDouble() ?? 0.0,
      da: (json['da'] as num?)?.toDouble() ?? 0.0,
      specialAllowance: (json['specialAllowance'] as num?)?.toDouble() ?? 0.0,
      attendance: (json['attendance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      incomeTax: (json['incomeTax'] as num?)?.toDouble() ?? 0.0,
      pfDeduction: (json['pfDeduction'] as num?)?.toDouble() ?? 0.0,
      professionalTax: (json['professionalTax'] as num?)?.toDouble() ?? 0.0,
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      netSalary: (json['netSalary'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'month': month,
      'year': year,
      'basicSalary': basicSalary,
      'hra': hra,
      'da': da,
      'specialAllowance': specialAllowance,
      'attendance': attendance,
      'totalEarnings': totalEarnings,
      'incomeTax': incomeTax,
      'pfDeduction': pfDeduction,
      'professionalTax': professionalTax,
      'otherDeductions': otherDeductions,
      'totalDeductions': totalDeductions,
      'netSalary': netSalary,
      'status': status,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }
}

class ListResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  ListResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });
}
