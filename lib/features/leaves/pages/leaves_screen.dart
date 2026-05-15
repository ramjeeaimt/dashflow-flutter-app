import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'new_leave_screen.dart';

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  String selectedFilter = "All";

  final List<Map<String, dynamic>> leaves = [
    {
      'title': 'Half Day Application',
      'date': 'Wed, 16 Dec',
      'type': 'Casual',
      'status': 'Awaiting',
      'month': 'December 2020',
      'typeColor': Colors.amber,
      'statusBgColor': Colors.amber.shade100,
      'statusTextColor': Colors.amber.shade800,
    },
    {
      'title': 'Full Day Application',
      'date': 'Mon, 28 Nov',
      'type': 'Sick',
      'status': 'Approved',
      'month': 'November 2020',
      'typeColor': Colors.blue,
      'statusBgColor': Colors.green.shade100,
      'statusTextColor': Colors.green.shade800,
    },
    {
      'title': '3 Days Application',
      'date': 'Tue, 22 Nov - Fri, 25 Nov',
      'type': 'Casual',
      'status': 'Declined',
      'month': 'November 2020',
      'typeColor': Colors.amber,
      'statusBgColor': Colors.red.shade100,
      'statusTextColor': Colors.red.shade800,
    },
    {
      'title': 'Full Day Application',
      'date': 'Wed, 02 Nov',
      'type': 'Sick',
      'status': 'Approved',
      'month': 'November 2020',
      'typeColor': Colors.blue,
      'statusBgColor': Colors.green.shade100,
      'statusTextColor': Colors.green.shade800,
    },
  ];

  // ✅ FIX 2: filteredLeaves is a getter — runs every time selectedFilter changes
  List<Map<String, dynamic>> get filteredLeaves {
    if (selectedFilter == "All") return leaves;
    return leaves.where((l) => l['type'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Leaves",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E202B),
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Iconsax.notification,
                              color: Color(0xFF1E202B),
                            ),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewLeaveScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A67D8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildFilterTab("All", null),
                    _buildFilterTab("Casual", Colors.amber),
                    _buildFilterTab("Sick", Colors.blue.shade300),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                // ✅ FIX 3: use filteredLeaves, not leaves
                itemCount: filteredLeaves.length,
                itemBuilder: (context, index) {
                  final leave = filteredLeaves[index]; // ✅ FIX 3
                  bool showMonthInfo = false;
                  if (index == 0) {
                    showMonthInfo = true;
                  } else if (filteredLeaves[index - 1]['month'] !=
                      leave['month']) {
                    // ✅ FIX 3
                    showMonthInfo = true;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showMonthInfo) ...[
                        const SizedBox(height: 15),
                        Text(
                          leave['month'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leave['title'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  leave['date'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E202B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  leave['type'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: leave['typeColor'],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: leave['statusBgColor'],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    leave['status'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: leave['statusTextColor'],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String text, Color? dotColor) {
    bool isSelected = selectedFilter == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = text;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1E202B) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
