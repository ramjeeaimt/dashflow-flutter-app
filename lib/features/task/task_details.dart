import 'package:flutter/material.dart';
import 'package:dashflow/core/api/api_service.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskId;
  final String title;
  final String description;
  final bool completed;
  final String? priority;
  final String? dueDate;
  final String? assigneeName;
  final String? projectName;
  final String? status;

  const TaskDetailsPage({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.completed,
    this.priority,
    this.dueDate,
    this.assigneeName,
    this.projectName,
    this.status,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late String _currentStatus;
  late String _currentPriority;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status ?? (widget.completed ? 'done' : 'todo');
    _currentPriority = widget.priority ?? 'medium';
  }

  int _getStatusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return 1;
      case 'review':
        return 2;
      case 'done':
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
    });

    final prevStatus = _currentStatus;
    setState(() {
      _currentStatus = newStatus;
    });

    try {
      await ApiService.updateTask(
        taskId: widget.taskId,
        status: newStatus,
      );
      _showSnack("Status updated to ${newStatus.toUpperCase()}", isError: false);
    } catch (e) {
      debugPrint("Error updating task status: $e");
      setState(() {
        _currentStatus = prevStatus;
      });
      _showSnack("Failed to update status: $e", isError: true);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _updatePriority(String newPriority) async {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
    });

    final prevPriority = _currentPriority;
    setState(() {
      _currentPriority = newPriority;
    });

    try {
      await ApiService.updateTask(
        taskId: widget.taskId,
        priority: newPriority,
      );
      _showSnack("Priority updated to ${newPriority.toUpperCase()}", isError: false);
    } catch (e) {
      debugPrint("Error updating task priority: $e");
      setState(() {
        _currentPriority = prevPriority;
      });
      _showSnack("Failed to update priority: $e", isError: true);
    } finally {
      setState(() {
        _isUpdating = false;
      });
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
        backgroundColor: isError ? const Color(0xFFC5221F) : const Color(0xFF137333),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String activeDueDate = "No Due Date Set";
    if (widget.dueDate != null && widget.dueDate!.isNotEmpty && widget.dueDate != "null") {
      try {
        final parsed = DateTime.parse(widget.dueDate!).toLocal();
        final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        final hourVal = parsed.hour > 12 ? parsed.hour - 12 : (parsed.hour == 0 ? 12 : parsed.hour);
        final ampm = parsed.hour >= 12 ? "PM" : "AM";
        activeDueDate = "${months[parsed.month]} ${parsed.day}, ${parsed.year} at ${hourVal.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')} $ampm";
      } catch (_) {
        activeDueDate = widget.dueDate!;
      }
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 3));
      final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      activeDueDate = "${months[tomorrow.month]} ${tomorrow.day}, ${tomorrow.year} at 12:00 PM";
    }

    final String activeAssignee = widget.assigneeName != null && widget.assigneeName!.trim().isNotEmpty && widget.assigneeName != "null" 
        ? widget.assigneeName! 
        : "Unassigned";

    final String activeProject = widget.projectName != null && widget.projectName!.trim().isNotEmpty && widget.projectName != "null"
        ? widget.projectName!
        : "No Associated Project";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FB),
        foregroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isUpdating
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C5282)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusBadge(_currentStatus),
                            _buildPriorityBadge(_currentPriority),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress Stepper
                  _buildProgressStepper(_currentStatus),
                  const SizedBox(height: 20),

                  // Priority Selector
                  _buildPrioritySelector(_currentPriority),
                  const SizedBox(height: 20),

                  // Description Box
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metadata Grid
                  const Text(
                    "Task Information",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.calendar_today_rounded,
                              "Due Date",
                              activeDueDate,
                              const Color(0xFF2C5282),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.person_outline_rounded,
                              "Assignee",
                              activeAssignee,
                              const Color(0xFF1A73E8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.folder_open_rounded,
                              "Project Associated",
                              activeProject,
                              const Color(0xFF6D28D9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressStepper(String currentStatus) {
    final activeIndex = _getStatusIndex(currentStatus);
    final stages = [
      {'key': 'todo', 'label': 'To Do', 'icon': Icons.hourglass_empty_rounded},
      {'key': 'in-progress', 'label': 'Active', 'icon': Icons.bolt_rounded},
      {'key': 'review', 'label': 'Review', 'icon': Icons.rate_review_rounded},
      {'key': 'done', 'label': 'Done', 'icon': Icons.check_circle_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Workflow Stage",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(stages.length, (index) {
              final stage = stages[index];
              final isPassed = index < activeIndex;
              final isCurrent = index == activeIndex;
              final isActive = isPassed || isCurrent;
              final color = isActive 
                  ? (index == 3 ? const Color(0xFF047857) : const Color(0xFF2C5282))
                  : const Color(0xFFCBD5E1);

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: index == 0
                              ? const SizedBox()
                              : Container(
                                  height: 3,
                                  color: isPassed 
                                      ? const Color(0xFF2C5282) 
                                      : const Color(0xFFE2E8F0),
                                ),
                        ),
                        GestureDetector(
                          onTap: () => _updateStatus(stage['key'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isCurrent ? color : (isPassed ? color.withValues(alpha: 0.12) : Colors.white),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color,
                                width: isCurrent ? 2 : 1.5,
                              ),
                            ),
                            child: Icon(
                              stage['icon'] as IconData,
                              color: isCurrent ? Colors.white : color,
                              size: 18,
                            ),
                          ),
                        ),
                        Expanded(
                          child: index == stages.length - 1
                              ? const SizedBox()
                              : Container(
                                  height: 3,
                                  color: index < activeIndex 
                                      ? const Color(0xFF2C5282) 
                                      : const Color(0xFFE2E8F0),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stage['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCurrent ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector(String currentPriority) {
    final priorities = ['low', 'medium', 'high', 'urgent'];
    final colors = {
      'low': const Color(0xFF137333),
      'medium': const Color(0xFFB06000),
      'high': const Color(0xFFD97706),
      'urgent': const Color(0xFFC5221F),
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Task Priority",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: priorities.map((p) {
              final isSelected = currentPriority.toLowerCase() == p;
              final color = colors[p]!;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _updatePriority(p),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bg;
    String label = 'To Do';
    switch (status.toLowerCase()) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    Color bg;
    switch (priority.toLowerCase()) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "${priority.toUpperCase()} PRIORITY",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
