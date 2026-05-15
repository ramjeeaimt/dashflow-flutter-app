import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  // Dummy data - Updated to use new EmployeeModel
  final List<EmployeeModel> employees = [
    EmployeeModel(
      id: 'EMP001',
      firstName: 'Ankur',
      lastName: 'Gautam',
      designation: 'Flutter Developer',
      department: 'Software Engineering',
      email: 'ankgau8714@gmail.com',
      phone: '8562990993',
    ),
    EmployeeModel(
      id: 'EMP002',
      firstName: 'Rajdeep',
      lastName: 'Maurya',
      designation: 'UI/UX designer',
      department: 'Software Engineering',
      email: 'rajdeepmaurya@mail.com',
      phone: '8548554885',
    ),
    EmployeeModel(
      id: 'EMP003',
      firstName: 'Pritam',
      lastName: 'Kumar',
      designation: 'Full stack Developer',
      department: 'Software Engineering',
      email: 'pritam@company.com',
      phone: '8454844555',
    ),
  ];

  String searchQuery = '';

  List<EmployeeModel> get filteredEmployees {
    if (searchQuery.isEmpty) return employees;
    return employees
        .where(
          (e) =>
              e.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              e.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
              e.department.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Employee Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by ID or Name...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                constraints: const BoxConstraints(maxHeight: 50),
              ),
            ),
          ),

          // 📋 Employees List
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(child: Text('No employees found'))
                : ListView.builder(
                    itemCount: filteredEmployees.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final emp = filteredEmployees[index];
                      return _EmployeeCard(employee: emp);
                    },
                  ),
          ),
        ],
      ),

      // ➕ Add Employees Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Employee',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// 🃏 Employees Card Widget
class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar with ID badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      employee.firstName[0],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  if (employee.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            employee.id,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          employee.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.designation,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.department,
                      style: TextStyle(
                        color: Colors.blue[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // More Action
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
