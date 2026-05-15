import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final List<DateTime> currentWeek = List.generate(
      7,
      (index) => DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 1))
          .add(Duration(days: index)));

  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> dailyActivities = [
    {
      "type": "Clock-In",
      "time": "08:30 AM",
      "status": "On-time",
    },
    {
      "type": "Project Meeting",
      "time": "11:00 AM",
      "status": "Completed",
    },
    {
      "type": "Lunch Break",
      "time": "01:30 PM to 02:30 PM",
      "status": "Approved",
    },
    {
      "type": "Clock-Out",
      "time": "05:00 PM",
      "status": "Early",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'History & Activity',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar View Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "November 2023", // Ideally dynamic
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_month, color: Color(0xFF36617E)))
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: currentWeek.map((date) {
                    bool isSelected =
                        date.day == selectedDate.day && date.month == selectedDate.month;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF36617E) : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              ["M", "T", "W", "T", "F", "S", "S"][date.weekday - 1],
                              style: TextStyle(
                                color: isSelected ? Colors.white70 : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // Daily summary
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text("Working Hrs: 8h 30m", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                    )
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Activity list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Text(
                  "Activity Log",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1F2937)
                  ),
                ),
                const SizedBox(height: 16),
                ...dailyActivities.map((activity) => _buildActivityCard(
                      type: activity['type'],
                      time: activity['time'],
                      status: activity['status'],
                    )),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String type,
    required String time,
    required String status,
  }) {
    final bool isClockIn = type.toLowerCase().contains("in") || type.toLowerCase().contains("meeting");
    final IconData icon = type.contains("Meeting") ? Iconsax.video : (type.contains("Lunch") ? Iconsax.cup : (isClockIn ? Iconsax.login : Iconsax.logout));
    final Color iconColor = type.contains("Lunch") ? Colors.orange : (isClockIn ? const Color(0xFF36617E) : Colors.pink);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               border: Border.all(color: Colors.grey.shade300),
               borderRadius: BorderRadius.circular(12)
             ),
             child: Text(
              status,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
