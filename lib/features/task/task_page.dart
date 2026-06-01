import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:dashflow/features/task/task_details.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<dynamic> _tasks = [];
  List<dynamic> _employees = [];
  bool _isLoading = true;
  bool _isLoadingEmployees = false;
  String? _companyId;
  String _statusFilter = 'all'; // 'all', 'todo', 'in-progress', 'review', 'done'

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();

  final List<Map<String, String>> _projects = [
    {'id': 'crm-redesign', 'name': 'CRM Dashboard Redesign'},
    {'id': 'client-onboarding', 'name': 'Client Onboarding'},
    {'id': 'api-v2', 'name': 'API Integration v2'},
    {'id': 'marketing-campaign', 'name': 'Marketing Campaign'},
    {'id': 'platform-maint', 'name': 'Platform Maintenance'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCompanyAndTasks();
    _loadEmployees();
  }

  Future<void> _loadCompanyAndTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        final companyId = user['companyId'] ?? (user['company'] != null ? user['company']['id'] : null);
        if (companyId != null) {
          _companyId = companyId.toString();
          final fetchedTasks = await ApiService.fetchTasksByCompany(_companyId!);
          setState(() {
            _tasks = fetchedTasks;
          });
        } else {
          debugPrint("companyId not found in user object: $user");
        }
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr == null) return;
      
      final user = jsonDecode(userStr);
      String userRole = "Employee";
      if (user['roles'] != null && user['roles'] is List && user['roles'].isNotEmpty) {
        final firstRole = user['roles'][0];
        if (firstRole is Map) userRole = firstRole['name'] ?? "Employee";
        else userRole = firstRole.toString();
      } else if (user['roles'] is String) {
        userRole = user['roles'];
      }
      
      final role = userRole.toLowerCase();
      if (!role.contains('admin') && !role.contains('manager')) {
        return; // Non-admins don't have permission to fetch all employees
      }

      setState(() {
        _isLoadingEmployees = true;
      });

      final list = await ApiService.getEmployees();
      setState(() {
        _employees = list;
      });
    } catch (e) {
      debugPrint("Error loading employees: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEmployees = false;
        });
      }
    }
  }

  int get completedTasks =>
      _tasks.where((task) => _isTaskCompleted(task)).length;

  bool _isTaskCompleted(dynamic task) {
    final status = (task['status'] ?? '').toString().toUpperCase();
    return status == 'COMPLETED' || status == 'COMPLETE' || status == 'DONE';
  }

  void _toggleTaskStatus(dynamic task, bool? value) async {
    if (value == null) return;
    
    final taskId = task['id'] ?? task['_id'];
    if (taskId == null) return;

    final originalStatus = task['status'];
    final newStatus = value ? 'done' : 'todo';
    
    // Optimistic update
    setState(() {
      task['status'] = newStatus;
    });
    
    try {
      await ApiService.updateTask(
        taskId: taskId.toString(),
        status: newStatus,
      );
      _loadCompanyAndTasks(); // Reload to sync with server/cache state
    } catch (e) {
      debugPrint("Error updating task: $e");
      // Revert status on error
      setState(() {
        task['status'] = originalStatus;
      });
      _showSnack("Failed to update task: $e", isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFC5221F)
            : const Color(0xFF137333),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getProjectName(String? projId) {
    if (projId == null) return '';
    final match = _projects.firstWhere(
      (p) => p['id'] == projId,
      orElse: () => {},
    );
    return match['name'] ?? projId;
  }

  Map<String, dynamic>? _getAssignee(dynamic task) {
    if (task['assignee'] is Map) {
      return Map<String, dynamic>.from(task['assignee']);
    }
    final assigneeId = task['assigneeId']?.toString();
    if (assigneeId != null && _employees.isNotEmpty) {
      final emp = _employees.firstWhere(
        (e) => (e['id']?.toString() == assigneeId || e['_id']?.toString() == assigneeId),
        orElse: () => null,
      );
      if (emp != null) {
        return Map<String, dynamic>.from(emp);
      }
    }
    return null;
  }

  List<dynamic> get _filteredTasks {
    if (_statusFilter == 'all') return _tasks;
    return _tasks.where((task) {
      final status = (task['status'] ?? '').toString().toLowerCase();
      String mappedStatus = status;
      if (status == 'completed' || status == 'complete' || status == 'done') {
        mappedStatus = 'done';
      } else if (status == 'pending' || status == 'todo') {
        mappedStatus = 'todo';
      }
      return mappedStatus == _statusFilter;
    }).toList();
  }

  void showAddTaskBottomSheet() {
    String selectedStatus = 'todo';
    String selectedPriority = 'medium';
    String? selectedProjectId;
    String? selectedAssigneeId;
    DateTime? selectedDueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            Future<void> pickDateTime() async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDueDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF2C5282),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF1E293B),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDueDate ?? DateTime.now()),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2C5282),
                          onPrimary: Colors.white,
                          onSurface: Color(0xFF1E293B),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null) {
                  setSheetState(() {
                    selectedDueDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            }

            void submitTask() async {
              if (titleController.text.trim().isEmpty || subtitleController.text.trim().isEmpty) {
                _showSnack("Please fill out all fields", isError: true);
                return;
              }

              if (_companyId == null) {
                _showSnack("User session/Company not loaded yet.", isError: true);
                return;
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2C5282)),
                ),
              );

              try {
                await ApiService.createTask(
                  title: titleController.text.trim(),
                  description: subtitleController.text.trim(),
                  companyId: _companyId!,
                  status: selectedStatus,
                  priority: selectedPriority,
                  dueDate: selectedDueDate?.toUtc().toIso8601String(),
                  projectId: selectedProjectId,
                  assigneeId: selectedAssigneeId,
                );

                titleController.clear();
                subtitleController.clear();
                
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
                  Navigator.pop(context); // Pop bottom sheet
                }
                
                _showSnack("Task added successfully!", isError: false);
                _loadCompanyAndTasks();
              } catch (e) {
                if (context.mounted) Navigator.pop(context); // Pop loading dialog
                _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
              }
            }

            Widget buildPriorityChips() {
              final priorities = ['low', 'medium', 'high', 'urgent'];
              final colors = {
                'low': const Color(0xFF137333),
                'medium': const Color(0xFFB06000),
                'high': const Color(0xFFD97706),
                'urgent': const Color(0xFFC5221F),
              };
              return Row(
                children: priorities.map((p) {
                  final isSelected = selectedPriority == p;
                  final color = colors[p]!;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          selectedPriority = p;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? color : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          p.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? color : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }

            Widget buildStatusChips() {
              final statuses = ['todo', 'in-progress', 'review', 'done'];
              final labels = {
                'todo': 'To Do',
                'in-progress': 'In Progress',
                'review': 'Review',
                'done': 'Done',
              };
              final colors = {
                'todo': const Color(0xFF475569),
                'in-progress': const Color(0xFF1D4ED8),
                'review': const Color(0xFF6D28D9),
                'done': const Color(0xFF047857),
              };
              return Row(
                children: statuses.map((s) {
                  final isSelected = selectedStatus == s;
                  final color = colors[s]!;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          selectedStatus = s;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? color : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          labels[s]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? color : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Create New Task",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      "Add details to assign and track this task.",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Title Field
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Task Title",
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2C5282), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description Field
                    TextField(
                      controller: subtitleController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Describe what needs to be done...",
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Icon(Icons.description_outlined, color: Color(0xFF64748B)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2C5282), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Priority Section
                    const Text(
                      "Priority",
                      style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    buildPriorityChips(),
                    const SizedBox(height: 16),

                    // Status Section
                    const Text(
                      "Status",
                      style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    buildStatusChips(),
                    const SizedBox(height: 16),

                    // Project Selector
                    const Text(
                      "Project (Optional)",
                      style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedProjectId,
                      hint: const Text("Select Project", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.folder_open_rounded, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2C5282), width: 1.5)),
                      ),
                      dropdownColor: Colors.white,
                      items: _projects.map<DropdownMenuItem<String>>((proj) {
                        return DropdownMenuItem<String>(
                          value: proj['id'],
                          child: Text(proj['name']!, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() {
                          selectedProjectId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Assignee Selector
                    const Text(
                      "Assignee (Optional)",
                      style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedAssigneeId,
                      hint: _isLoadingEmployees 
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text("Select Assignee", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2C5282), width: 1.5)),
                      ),
                      dropdownColor: Colors.white,
                      items: _employees.map<DropdownMenuItem<String>>((emp) {
                        final id = (emp['id'] ?? emp['_id'] ?? '').toString();
                        final name = "${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}".trim();
                        final designation = emp['designation'] ?? 'Employee';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text("$name ($designation)", style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() {
                          selectedAssigneeId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Due Date Picker
                    const Text(
                      "Due Date (Optional)",
                      style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDueDate == null
                                  ? "Choose deadline"
                                  : "${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year} at ${TimeOfDay.fromDateTime(selectedDueDate!).format(context)}",
                              style: TextStyle(
                                color: selectedDueDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: submitTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5282),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Create Task",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _tasks.isEmpty ? 0 : completedTasks / _tasks.length;
    final displayTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Tasks",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C5282),
        onPressed: showAddTaskBottomSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),

      body: RefreshIndicator(
        onRefresh: _loadCompanyAndTasks,
        color: const Color(0xFF2C5282),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              /// Progress Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C5282), Color(0xFF1A365D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C5282).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Task Progress",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tasks.isEmpty ? "No active tasks" : "Keep going!",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 24),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$completedTasks of ${_tasks.length} completed",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter Chips
              _buildFilterChips(),

              /// Task List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF2C5282)),
                      )
                    : displayTasks.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: displayTasks.length,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, index) {
                              final task = displayTasks[index];
                              final completed = _isTaskCompleted(task);
                              final priority = (task['priority'] ?? 'medium').toString().toLowerCase();
                              final status = (task['status'] ?? 'todo').toString().toLowerCase();
                              final dueDateStr = task['dueDate']?.toString() ?? task['deadline']?.toString();
                              final projId = task['projectId']?.toString();
                              final projectName = _getProjectName(projId);
                              
                              final assignee = _getAssignee(task);
                              final assigneeName = assignee != null
                                  ? "${assignee['firstName'] ?? ''} ${assignee['lastName'] ?? ''}".trim()
                                  : (task['assigneeName']?.toString() ?? '');

                              String displayDueDate = '';
                              bool isOverdue = false;
                              if (dueDateStr != null && dueDateStr.isNotEmpty && dueDateStr != 'null') {
                                try {
                                  final parsed = DateTime.parse(dueDateStr).toLocal();
                                  final now = DateTime.now();
                                  isOverdue = parsed.isBefore(now) && !completed;
                                  final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                  displayDueDate = "${months[parsed.month]} ${parsed.day}, ${parsed.year}";
                                } catch (_) {
                                  displayDueDate = dueDateStr;
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: completed ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TaskDetailsPage(
                                          taskId: (task['id'] ?? task['_id'] ?? '').toString(),
                                          title: task["title"] ?? "No Title",
                                          description: task["description"] ?? "No Description",
                                          completed: completed,
                                          priority: task["priority"]?.toString(),
                                          dueDate: task["dueDate"]?.toString() ?? task["deadline"]?.toString(),
                                          assigneeName: assigneeName,
                                          projectName: projectName,
                                          status: task['status']?.toString(),
                                        ),
                                      ),
                                    );
                                    _loadCompanyAndTasks();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (projectName.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.folder_open_rounded, size: 12, color: Color(0xFF475569)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      projectName,
                                                      style: const TextStyle(
                                                        color: Color(0xFF475569),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              const SizedBox(),
                                            _buildPriorityBadge(priority),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Transform.scale(
                                              scale: 1.1,
                                              child: Checkbox(
                                                value: completed,
                                                activeColor: const Color(0xFF2C5282),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                                onChanged: (value) => _toggleTaskStatus(task, value),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    task["title"] ?? "Untitled Task",
                                                    style: TextStyle(
                                                      color: completed ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                                                    ),
                                                  ),
                                                  if (task["description"] != null && task["description"].toString().trim().isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      task["description"],
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: completed ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _buildStatusBadge(status),
                                                if (displayDueDate.isNotEmpty) ...[
                                                  const SizedBox(width: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time_rounded,
                                                        size: 13,
                                                        color: isOverdue ? const Color(0xFFC5221F) : const Color(0xFF64748B),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        displayDueDate,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                                          color: isOverdue ? const Color(0xFFC5221F) : const Color(0xFF64748B),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (assigneeName.isNotEmpty)
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: const Color(0xFF2C5282).withValues(alpha: 0.12),
                                                    child: Text(
                                                      assigneeName
                                                          .split(' ')
                                                          .where((w) => w.isNotEmpty)
                                                          .take(2)
                                                          .map((w) => w[0].toUpperCase())
                                                          .join(),
                                                      style: const TextStyle(
                                                        color: Color(0xFF2C5282),
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  ConstrainedBox(
                                                    constraints: const BoxConstraints(maxWidth: 80),
                                                    child: Text(
                                                      assigneeName.split(' ').first,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF475569),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              const Row(
                                                children: [
                                                  Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "Unassigned",
                                                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = [
      {'value': 'all', 'label': 'All Tasks'},
      {'value': 'todo', 'label': 'To Do'},
      {'value': 'in-progress', 'label': 'In Progress'},
      {'value': 'review', 'label': 'Review'},
      {'value': 'done', 'label': 'Completed'},
    ];
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final s = statuses[index];
          final isSelected = _statusFilter == s['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                s['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selectedColor: const Color(0xFF2C5282),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (val) {
                setState(() {
                  _statusFilter = s['value']!;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    Color bg;
    switch (priority) {
      case 'urgent':
        color = const Color(0xFFC5221F);
        bg = const Color(0xFFFCE8E6);
        break;
      case 'high':
        color = const Color(0xFFD97706);
        bg = const Color(0xFFFEF3C7);
        break;
      case 'low':
        color = const Color(0xFF137333);
        bg = const Color(0xFFE6F4EA);
        break;
      default:
        color = const Color(0xFFB06000);
        bg = const Color(0xFFFEF7E0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bg;
    String label = 'To Do';
    switch (status) {
      case 'in-progress':
        color = const Color(0xFF1D4ED8);
        bg = const Color(0xFFDBEAFE);
        label = 'In Progress';
        break;
      case 'review':
        color = const Color(0xFF6D28D9);
        bg = const Color(0xFFF3E8FF);
        label = 'Review';
        break;
      case 'done':
      case 'completed':
        color = const Color(0xFF047857);
        bg = const Color(0xFFD1FAE5);
        label = 'Done';
        break;
      default:
        color = const Color(0xFF475569);
        bg = const Color(0xFFF1F5F9);
        label = 'To Do';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Color(0xFF64748B),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No tasks found for the selected status.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
