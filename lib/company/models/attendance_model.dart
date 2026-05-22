import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String status;
  final double? workingHours;
  final String? remarks;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.workingHours,
    this.remarks,
  });


  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);


  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);


  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    String? checkIn,
    String? checkOut,
    String? status,
    double? workingHours,
    String? remarks,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      workingHours: workingHours ?? this.workingHours,
      remarks: remarks ?? this.remarks,
    );
  }


  bool get isPresent => status == 'Present';


  bool get isAbsent => status == 'Absent';


  bool get isOnLeave => status == 'Leave';


  bool get isHoliday => status == 'Holiday';


  double calculateWorkingHours() {
    try {
      final checkInTime = _parseTime(checkIn);
      final checkOutTime = _parseTime(checkOut);

      if (checkInTime == null || checkOutTime == null) return 0.0;

      final difference = checkOutTime.difference(checkInTime);
      return difference.inMinutes / 60;
    } catch (e) {
      return 0.0;
    }
  }


  DateTime? _parseTime(String timeString) {
    try {
      if (timeString.isEmpty) return null;


      final now = DateTime.now();
      final parts = timeString.replaceAll(RegExp(r'\s+'), '').split(':');

      if (parts.length < 2) return null;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].replaceAll(RegExp(r'[^\d]'), ''));

      if (timeString.contains('PM') && hour != 12) {
        hour += 12;
      } else if (timeString.contains('AM') && hour == 12) {
        hour = 0;
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeId: $employeeId, employeeName: $employeeName, date: $date, checkIn: $checkIn, checkOut: $checkOut, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendanceModel &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.employeeName == employeeName &&
        other.date == date &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        employeeName.hashCode ^
        date.hashCode ^
        checkIn.hashCode ^
        checkOut.hashCode ^
        status.hashCode;
  }
}
