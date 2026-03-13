import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Employee {
  final String name;
  final String avatarUrl;
  final String status; // online, offline, on_leave
  final String currentProject;

  Employee({
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.currentProject,
  });
}

class TeamStatusWidget extends StatefulWidget {
  const TeamStatusWidget({super.key});

  @override
  State<TeamStatusWidget> createState() => _TeamStatusWidgetState();
}

class _TeamStatusWidgetState extends State<TeamStatusWidget> {
  String searchQuery = "";
  bool showSearch = false;
  
  // Dummy data
  final List<Employee> allEmployees = [
    Employee(name: "Sadhna K.", avatarUrl: "assets/images/ranjeet.jpg", status: "online", currentProject: "CRM App"),
    Employee(name: "Aman Doe", avatarUrl: "", status: "offline", currentProject: "API"),
    Employee(name: "Neha Smith", avatarUrl: "", status: "on_leave", currentProject: "Design"),
    Employee(name: "Rahul", avatarUrl: "", status: "online", currentProject: "Testing"),
    Employee(name: "Vikram", avatarUrl: "", status: "offline", currentProject: "CRM App"),
  ];

  List<Employee> get _filteredEmployees {
    if (searchQuery.isEmpty) return allEmployees;
    return allEmployees.where((emp) {
      final matchesSearch = emp.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            emp.currentProject.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Determine dots for status:
    // Green for 'Present' (online), Grey for 'Absent' (offline), Yellow for 'On Leave' (on_leave)

    final employeesToDisplay = showSearch ? _filteredEmployees : allEmployees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Team Status",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F2937)),
            ),
            Row(
              children: [
                if (showSearch)
                  Container(
                    width: 150,
                    height: 35,
                    margin: const EdgeInsets.only(right: 8),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "Search name/project",
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Iconsax.search_normal_1, size: 20, color: Colors.grey),
                    onPressed: () => setState(() => showSearch = true),
                  ),
                if (showSearch)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => setState(() {
                      showSearch = false;
                      searchQuery = "";
                    }),
                  )
                else
                  TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Color(0xFF36617E), fontWeight: FontWeight.bold))),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: employeesToDisplay.length,
            itemBuilder: (context, index) {
              final emp = employeesToDisplay[index];
              Color statusColor;
              if (emp.status == "online") {
                statusColor = Colors.green;
              } else if (emp.status == "on_leave") {
                statusColor = Colors.amber; // Yellow/Orange
              } else {
                statusColor = Colors.grey;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: emp.avatarUrl.isNotEmpty ? AssetImage(emp.avatarUrl) : null,
                          child: emp.avatarUrl.isEmpty 
                            ? Text(emp.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)) 
                            : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emp.name.split(' ')[0], // first name
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
