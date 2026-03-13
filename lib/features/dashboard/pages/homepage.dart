import 'package:flutter/material.dart';
import 'package:flutter_application_difmo/features/dashboard/pages/home_page_locations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application_difmo/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_application_difmo/features/auth/pages/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_difmo/features/activities/pages/location_page.dart';
import 'package:flutter_application_difmo/features/employees/components/team_status_widget.dart';
import 'package:flutter_application_difmo/features/employees/pages/employees_list_screen.dart';
import 'package:flutter_application_difmo/features/payslip/pages/payslip_list_screen.dart';
import 'package:flutter_application_difmo/features/leaves/pages/leaves_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  bool isPopUpVisible = false;
  String attendanceStatus = "Clock-In"; // Clock-In or Clock-Out
  String? attendanceId;
  String? employeeId;
  bool isLoading = true;

  // User Data
  String userName = "Loading...";
  String userRole = "Employee";
  String userEmail = "";
  // sdfsd
  // Time Info
  String clockInTime = "--:--";
  String clockOutTime = "--:--";
  String workingHours = "--h --m";
  String currentDate = "";
  String currentTime = "";

  // Activity History
  List<dynamic> activityHistory = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
    _fetchAttendanceStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        currentDate = DateFormat('EEEE, dd MMMM').format(now);
        currentTime = DateFormat('hh:mm:ss a').format(now);
      });
    }
  }

  DateTime? _parseUtcTime(String? dateStr, String? timeStr) {
    // debugPrint("Parsing time: date=$dateStr, time=$timeStr");
    if (dateStr == null || timeStr == null) return null;
    try {
      // Ensure date is YYYY-MM-DD
      final datePart = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;
      // Construct ISO string (Treat as local)
      final isoStr = "${datePart}T$timeStr";
      final dt = DateTime.parse(isoStr);
      // debugPrint("Parsed $isoStr to $dt");
      return dt;
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  Future<void> _fetchAttendanceStatus() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        final userId = user['id'];

        setState(() {
          employeeId = userId; // Setting it directly from user data
          userName = "${user['firstName']} ${user['lastName']}";
          userEmail = user['email'];
          if (user['roles'] != null && user['roles'].isNotEmpty) {
            userRole = user['roles'][0]['name'] ?? "Employee";
          }
        });

        // Get today's attendance using the assigned employeeId
        if (employeeId != null) {
          final attendance = await ApiService.getTodayAttendance(employeeId!);
          print("RAW ATTENDANCE DATA: $attendance"); // DEBUG LOG

          if (attendance != null) {
            String? date = attendance['date'];
            String? checkInStr = attendance['checkInTime'];
            String? checkOutStr = attendance['checkOutTime'];

            print("ID: ${attendance['id']}"); // DEBUG LOG
            print(
              "Date: $date, CheckIn: $checkInStr, CheckOut: $checkOutStr",
            ); // DEBUG LOG

            DateTime? checkIn = _parseUtcTime(date, checkInStr);
            DateTime? checkOut = _parseUtcTime(date, checkOutStr);

            setState(() {
              if (checkIn != null) {
                clockInTime = DateFormat('hh:mm a').format(checkIn);
              }
              if (checkOut != null) {
                clockOutTime = DateFormat('hh:mm a').format(checkOut);
                attendanceStatus = "Completed";

                // Calculate working hours
                final duration = checkOut.difference(checkIn!);
                final hours = duration.inHours;
                final minutes = duration.inMinutes.remainder(60);
                workingHours = "${hours}h ${minutes}m";
              } else {
                attendanceStatus = "Clock-Out";
                attendanceId = attendance['id'];
                print("Set attendanceId to $attendanceId"); // DEBUG LOG
              }
            });
          } else {
            setState(() {
              attendanceStatus = "Clock-In";
              clockInTime = "--:--";
              clockOutTime = "--:--";
              workingHours = "--h --m";
            });
          }

          // Get Activity History
          final history = await ApiService.getAttendanceHistory(employeeId!);
          setState(() {
            activityHistory = history;
          });
        }
      }
    } catch (e) {
      print("Error fetching attendance: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    print("User logging out..."); // Debug log
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("SharedPreferences cleared.");
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF36617E),
                        Color(0xFF5386A4),
                      ], // Primary to Lighter variant
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                              "assets/images/ranjeet.jpg",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userRole,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Iconsax.logout,
                              color: Colors.white,
                            ),
                            onPressed: _logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Clock Section
                      Center(
                        child: Column(
                          children: [
                            Text(
                              currentTime,
                              style: const TextStyle(
                                fontSize: 38,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currentDate,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      if (employeeId == null) {
                                        showSnack(
                                          "Please wait while we load your profile...",
                                        );
                                        return;
                                      }

                                      if (attendanceStatus == "Completed") {
                                        showSnack(
                                          "Attendance already completed for today",
                                        );
                                        return;
                                      }

                                      final permission =
                                          await Geolocator.checkPermission();
                                      if (permission ==
                                              LocationPermission.whileInUse ||
                                          permission ==
                                              LocationPermission.always) {
                                        // Directly navigate
                                        if (context.mounted) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  LocationConfirmPage(
                                                    isCheckIn:
                                                        attendanceStatus ==
                                                        "Clock-In",
                                                    employeeId: employeeId,
                                                    attendanceId: attendanceId,
                                                  ),
                                            ),
                                          );
                                          _fetchAttendanceStatus();
                                        }
                                      } else {
                                        setState(() {
                                          isPopUpVisible = true;
                                        });
                                      }
                                    },

                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Opacity(
                                  opacity:
                                      (isLoading ||
                                          attendanceStatus == "Completed")
                                      ? 0.5
                                      : 1.0,
                                  child: Column(
                                    children: [
                                      if (isLoading)
                                        const SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF36617E),
                                            strokeWidth: 3,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Iconsax.finger_scan,
                                          size: 50,
                                          color: Color(0xFF36617E),
                                        ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isLoading
                                            ? "Loading..."
                                            : attendanceStatus,
                                        style: const TextStyle(
                                          color: Color(0xFF36617E),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Time Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TimeInfo(title: "Clock-In", time: clockInTime),
                          TimeInfo(title: "Clock-Out", time: clockOutTime),
                          TimeInfo(title: "Working Hrs", time: workingHours),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Team Status Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TeamStatusWidget(),
                ),

                const SizedBox(height: 25),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount:
                        3, // Changed to 3 for better spacing with 6 options
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      ActionIcon(
                        icon: Iconsax.people,
                        label: "Employees",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployeesListScreen(),
                          ),
                        ),
                      ),
                      ActionIcon(
                        icon: Iconsax.calendar_edit,
                        label: "Leave",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeavesScreen(),
                          ),
                        ),
                      ),
                      ActionIcon(
                        icon: Iconsax.document_text,
                        label: "Payslip",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PayslipListScreen(),
                          ),
                        ),
                      ),
                      ActionIcon(
                        icon: Iconsax.task_square,
                        label: "Tasks",
                        onTap: () => showSnack("Tasks clicked"),
                      ),
                      ActionIcon(
                        icon: Iconsax.calendar_tick,
                        label: "Attendance",
                        onTap: () => showSnack("Attendance clicked"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Company Announcement Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade300,
                          Colors.orange.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.notification_bing,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Company Announcement",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Townhall meeting tomorrow at 10 AM. Don't forget!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Assigned Tasks Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Assigned Tasks",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF36617E),
                            ),
                          ),
                          Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      taskItem(
                        "Update Client Presentation",
                        "Today, 5:00 PM",
                        "Pending",
                      ),
                      taskItem(
                        "Review Monthly Reports",
                        "Tomorrow, 12:00 PM",
                        "Completed",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Attendance History Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Attendance History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF36617E),
                            ),
                          ),
                          Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (activityHistory.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Text(
                            "No attendance history found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...activityHistory.take(5).map((history) {
                          final dateStr = history['date'] ?? '';
                          String formattedDate = dateStr;
                          try {
                            if (dateStr.contains('T')) {
                              final dt = DateTime.parse(dateStr);
                              formattedDate = DateFormat(
                                'dd MMM yyyy',
                              ).format(dt);
                            }
                          } catch (_) {}

                          // Format time
                          String timeStr = history['checkInTime'] ?? '--:--';
                          try {
                            if (timeStr != '--:--' && dateStr.contains('T')) {
                              final isoStr =
                                  "${dateStr.split('T')[0]}T$timeStr";
                              final dt = DateTime.parse(isoStr);
                              timeStr = DateFormat('hh:mm a').format(dt);
                            }
                          } catch (_) {}

                          return activityItem(
                            "Clock In",
                            formattedDate,
                            timeStr,
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          if (isPopUpVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.3,
                ), // Optional background dim
                alignment: Alignment.center,
                child: LocationPopup(
                  isCheckIn: attendanceStatus == "Clock-In",
                  employeeId: employeeId,
                  attendanceId: attendanceId,
                  onClose: () {
                    setState(() {
                      isPopUpVisible = false;
                    });
                    // Refresh status after popup closes (assuming check-in/out might have happened)
                    _fetchAttendanceStatus();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Reusable Activity Item
  Widget activityItem(String title, String date, String time) {
    return InkWell(
      onTap: () => showSnack("$title tapped"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF36617E).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(Iconsax.clock, color: Color(0xFF36617E)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Text(
              time,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Task item widget
  Widget taskItem(String title, String dueDate, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF36617E).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: const Icon(Iconsax.task_square, color: Color(0xFF36617E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Due: $dueDate",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: status == "Pending"
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == "Pending"
                    ? Colors.orange.shade800
                    : Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Time Info Widget
class TimeInfo extends StatelessWidget {
  final String title, time;
  const TimeInfo({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

// Action Icon Widget
class ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ActionIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(
                0xFF36617E,
              ).withValues(alpha: 0.1), // Primary Light
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF36617E), size: 25),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
