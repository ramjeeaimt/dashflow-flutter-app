import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyAttendancePage extends StatefulWidget {
  const MyAttendancePage({super.key});

  @override
  State<MyAttendancePage> createState() => _MyAttendancePageState();
}

class _MyAttendancePageState extends State<MyAttendancePage> {
  bool isCheckedIn = false;

  DateTime? checkInTime;
  DateTime? checkOutTime;

  List<AttendanceRecord> attendanceRecords = [
    AttendanceRecord(
      date: DateTime(2026, 5, 25),
      checkIn: '09:15 AM',
      checkOut: '05:30 PM',
      workingHours: '8h 15m',
      status: 'Present',
    ),
    AttendanceRecord(
      date: DateTime(2026, 5, 24),
      checkIn: '09:00 AM',
      checkOut: '05:45 PM',
      workingHours: '8h 45m',
      status: 'Present',
    ),
    AttendanceRecord(
      date: DateTime(2026, 5, 23),
      checkIn: '10:30 AM',
      checkOut: '05:30 PM',
      workingHours: '7h 00m',
      status: 'Late',
    ),
    AttendanceRecord(
      date: DateTime(2026, 5, 22),
      checkIn: '---',
      checkOut: '---',
      workingHours: '0h',
      status: 'Absent',
    ),
  ];

  void _handleCheckIn() {
    setState(() {
      isCheckedIn = true;
      checkInTime = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Checked In at ${DateFormat('hh:mm a').format(checkInTime!)}",
        ),
      ),
    );
  }

  void _handleCheckOut() {
    setState(() {
      isCheckedIn = false;
      checkOutTime = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Checked Out at ${DateFormat('hh:mm a').format(checkOutTime!)}",
        ),
      ),
    );
  }

  String _getWorkingHours() {
    if (checkInTime == null || checkOutTime == null) {
      return '0h 0m';
    }

    Duration difference = checkOutTime!.difference(checkInTime!);

    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Attendance",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),

            const SizedBox(height: 20),

            /// CHECK IN CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isCheckedIn
                      ? [const Color(0xff34A853), const Color(0xff2d8e47)]
                      : [const Color(0xff1450D2), const Color(0xff0d3aa3)],
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    "Current Status",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    isCheckedIn ? "Checked In" : "Checked Out",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isCheckedIn && checkInTime != null
                        ? DateFormat('hh:mm a').format(checkInTime!)
                        : "--:-- --",
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isCheckedIn ? null : _handleCheckIn,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          child: const Text(
                            "Check In",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: isCheckedIn ? _handleCheckOut : null,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          child: const Text(
                            "Check Out",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// TODAY TIME CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Time",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  const SizedBox(height: 20),

                  _timeRow(
                    "Check In",
                    checkInTime != null
                        ? DateFormat('hh:mm a').format(checkInTime!)
                        : '--:--',
                    Colors.green,
                  ),

                  const SizedBox(height: 14),

                  _timeRow(
                    "Check Out",
                    checkOutTime != null
                        ? DateFormat('hh:mm a').format(checkOutTime!)
                        : '--:--',
                    Colors.red,
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Working Hours",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text(
                          _getWorkingHours(),
                          style: const TextStyle(
                            color: Color(0xff1450D2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// STATS
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.check_circle,
                    label: "Present",
                    value: "18",
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    icon: Icons.close,
                    label: "Absent",
                    value: "1",
                    color: Colors.red,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    icon: Icons.schedule,
                    label: "Late",
                    value: "2",
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// RECENT ATTENDANCE
            const Text(
              "Recent Attendance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),

            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendanceRecords.length,

              itemBuilder: (context, index) {
                final record = attendanceRecords[index];

                return _attendanceItem(record);
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _timeRow(String label, String time, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: color),

            const SizedBox(width: 10),

            Text(label),
          ],
        ),

        Text(
          time,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _attendanceItem(AttendanceRecord record) {
    Color statusColor = _getStatusColor(record.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: statusColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(_getStatusIcon(record.status), color: statusColor),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(record.date),

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      '${record.checkIn} - ${record.checkOut}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      child: Text(
                        record.workingHours,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

              decoration: BoxDecoration(
                color: statusColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                record.status,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;

      case 'Late':
        return Colors.orange;

      case 'Absent':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Present':
        return Icons.check_circle;

      case 'Late':
        return Icons.schedule;

      case 'Absent':
        return Icons.close;

      default:
        return Icons.help;
    }
  }
}

class AttendanceRecord {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String workingHours;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.workingHours,
    required this.status,
  });
}
