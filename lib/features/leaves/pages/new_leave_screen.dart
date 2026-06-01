import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/core/api/api_service.dart';

class NewLeaveScreen extends StatefulWidget {
  const NewLeaveScreen({super.key});

  @override
  State<NewLeaveScreen> createState() => _NewLeaveScreenState();
}

class _NewLeaveScreenState extends State<NewLeaveScreen> {
  static const _primary = Color(0xFF36617E);
  static const _textDark = Color(0xFF1E293B);
  static const _textGray = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  String selectedLeaveType = 'Casual';
  final _reasonController = TextEditingController();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now().add(const Duration(days: 1));

  String? _employeeId;
  bool _isSubmitting = false;

  static const List<String> _leaveTypes = [
    'Casual',
    'Sick',
    'Earned',
    'Maternity',
  ];

  int get totalDays =>
      toDate.difference(fromDate).inDays.abs() + 1;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      setState(() {
        _employeeId = user['employeeId'] ?? user['id']?.toString();
      });
    }
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.isBefore(now) ? now : fromDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => _themedDatePicker(child),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        // Ensure toDate is never before fromDate
        if (toDate.isBefore(fromDate)) {
          toDate = fromDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.isBefore(fromDate) ? fromDate.add(const Duration(days: 1)) : toDate,
      firstDate: fromDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _themedDatePicker(child),
    );
    if (picked != null) {
      setState(() => toDate = picked);
    }
  }

  Widget _themedDatePicker(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: _primary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: _textDark,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _primary),
        ),
      ),
      child: child!,
    );
  }

  Future<void> _submitLeaveRequest() async {
    if (_employeeId == null) {
      _showSnack('Could not load your profile. Please re-login.', isError: true);
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      _showSnack('Please enter a reason for your leave.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService.applyLeave(
        employeeId: _employeeId!,
        leaveType: selectedLeaveType.toUpperCase(),
        duration: totalDays == 1 ? 'Full Day' : 'Multiple Days',
        startDate: DateFormat('yyyy-MM-dd').format(fromDate),
        endDate: DateFormat('yyyy-MM-dd').format(toDate),
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      _showSnack('Leave applied successfully! ($totalDays day${totalDays > 1 ? 's' : ''})');
      Navigator.pop(context, true); // return true to trigger refresh
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to apply: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFC5221F) : const Color(0xFF137333),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: _textGray),
              iconSize: 20,
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        // Dismiss keyboard when tapping outside
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apply for Leave',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '$totalDays day${totalDays > 1 ? 's' : ''} selected',
                  style: const TextStyle(
                    color: _textGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Card Container ───────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Leave Type
                      _buildRow(
                        icon: Icons.category_outlined,
                        label: 'Leave Type',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedLeaveType,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textGray),
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'sans-serif',
                            ),
                            dropdownColor: Colors.white,
                            items: _leaveTypes
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedLeaveType = v ?? 'Casual'),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: _border),

                      // Reason
                      _buildRow(
                        icon: Icons.edit_outlined,
                        label: 'Reason',
                        child: TextField(
                          controller: _reasonController,
                          maxLines: 2,
                          minLines: 1,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter reason for leave...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: _border),

                      // From Date
                      _buildRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'From Date',
                        child: GestureDetector(
                          onTap: _pickFromDate,
                          child: _dateChip(fromDate),
                        ),
                      ),
                      Divider(height: 1, color: _border),

                      // To Date
                      _buildRow(
                        icon: Icons.event_outlined,
                        label: 'To Date',
                        child: GestureDetector(
                          onTap: _pickToDate,
                          child: _dateChip(toDate),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Duration Summary ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _primary.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: _primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${DateFormat('dd MMM').format(fromDate)} → ${DateFormat('dd MMM yyyy').format(toDate)}  •  $totalDays day${totalDays > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Submit Button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitLeaveRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      disabledBackgroundColor: _primary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Apply for $totalDays Day${totalDays > 1 ? 's' : ''} Leave',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_month_rounded, size: 14, color: _primary),
          const SizedBox(width: 6),
          Text(
            DateFormat('EEE, dd MMM yyyy').format(date),
            style: const TextStyle(
              color: _primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
