import 'package:flutter/material.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final String employeeId;
  final String userName;

  const AttendanceHistoryPage({
    super.key,
    required this.employeeId,
    required this.userName,
  });

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  bool isLoading = true;
  List<dynamic> attendanceList = [];

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String selectedStatus = 'all';

  static const _primary = Color(0xFF36617E);
  static const _textDark = Color(0xFF1E293B);
  static const _textGray = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _bg = Color(0xFFF8F9FB);

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'all', 'label': 'All', 'icon': Icons.apps_rounded, 'color': Color(0xFF36617E), 'bg': Color(0xFFE8F0F7)},
    {'value': 'present', 'label': 'Present', 'icon': Icons.check_circle_outline_rounded, 'color': Color(0xFF137333), 'bg': Color(0xFFE6F4EA)},
    {'value': 'absent', 'label': 'Absent', 'icon': Icons.cancel_outlined, 'color': Color(0xFFC5221F), 'bg': Color(0xFFFCE8E6)},
    {'value': 'late', 'label': 'Late', 'icon': Icons.access_time_rounded, 'color': Color(0xFFB06000), 'bg': Color(0xFFFEF7E0)},
    {'value': 'half_day', 'label': 'Half Day', 'icon': Icons.timelapse_rounded, 'color': Color(0xFF6D28D9), 'bg': Color(0xFFF3E8FF)},
    {'value': 'wfh', 'label': 'WFH', 'icon': Icons.home_work_outlined, 'color': Color(0xFF0D7490), 'bg': Color(0xFFE0F2FE)},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => isLoading = true);
    try {
      final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
      final data = await ApiService.getAttendanceHistory(
        widget.employeeId,
        startDate: DateFormat('yyyy-MM-dd').format(startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
        status: selectedStatus == 'all' ? null : selectedStatus,
      );
      setState(() => attendanceList = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching history: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFC5221F),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.year == now.year && selectedMonth.month == now.month;
  }

  void _goToPrevMonth() {
    final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
    final earliest = DateTime(DateTime.now().year - 1, DateTime.now().month);
    if (!prev.isBefore(earliest)) {
      setState(() => selectedMonth = prev);
      _fetchAttendance();
    }
  }

  void _goToNextMonth() {
    if (!_isCurrentMonth) {
      setState(() => selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1));
      _fetchAttendance();
    }
  }

  DateTime? _parseTime(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return null;
    try {
      final d = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;
      return DateTime.parse('${d}T$timeStr');
    } catch (_) {
      return null;
    }
  }

  Future<void> _showMonthYearPicker() async {
    int tempYear = selectedMonth.year;
    int tempMonth = selectedMonth.month;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: _primary),
                    onPressed: () => setDialogState(() => tempYear--),
                  ),
                  Text(
                    tempYear.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, color: _primary),
                    onPressed: () {
                      if (tempYear < DateTime.now().year) {
                        setDialogState(() => tempYear++);
                      }
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 250,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthNum = index + 1;
                    final isSelected = monthNum == tempMonth;
                    final isFuture = (tempYear == DateTime.now().year && monthNum > DateTime.now().month) || (tempYear > DateTime.now().year);
                    return InkWell(
                      onTap: isFuture
                          ? null
                          : () {
                              setDialogState(() => tempMonth = monthNum);
                              Navigator.pop(context, true);
                            },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? _primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('MMM').format(DateTime(2000, monthNum)),
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isFuture ? Colors.grey : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );

    if (tempYear != selectedMonth.year || tempMonth != selectedMonth.month) {
      final newDate = DateTime(tempYear, tempMonth);
      if (!newDate.isAfter(DateTime.now())) {
        setState(() => selectedMonth = newDate);
        _fetchAttendance();
      }
    }
  }

  Map<String, int> _getSummary() {
    int present = 0, absent = 0, wfh = 0, late = 0;
    for (final item in attendanceList) {
      final status = (item['status'] ?? '').toString().toLowerCase();
      final workMode = (item['workMode'] ?? '').toString().toLowerCase();
      if (workMode == 'wfh') {
        wfh++;
      } else if (status == 'present') {
        present++;
      } else if (status == 'absent') {
        absent++;
      } else if (status == 'late') {
        late++;
      }
    }
    return {'present': present, 'absent': absent, 'wfh': wfh, 'late': late};
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMonthNavigator(),
            _buildFilterRow(),
            if (!isLoading && attendanceList.isNotEmpty) _buildSummaryCards(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: _primary))
                  : attendanceList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: _primary,
                          onRefresh: _fetchAttendance,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: attendanceList.length,
                            itemBuilder: (context, index) {
                              final item = attendanceList[index];
                              final date = item['date'] ?? '';
                              return _buildAttendanceCard(
                                date: date,
                                checkIn: _parseTime(date, item['checkInTime']),
                                checkOut: _parseTime(date, item['checkOutTime']),
                                status: (item['status'] ?? 'present').toString(),
                                workMode: (item['workMode'] ?? 'office').toString(),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Back button — same style as WFH screen
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: _textGray),
              onPressed: () => Navigator.pop(context),
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attendance History',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                widget.userName,
                style: const TextStyle(
                  color: _textGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Month Navigator ──────────────────────────────────────────────────────

  Widget _buildMonthNavigator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ← Prev arrow
            _navArrowBtn(
              icon: Icons.chevron_left_rounded,
              onTap: _goToPrevMonth,
              enabled: true,
            ),
            // Month / Year label
            Expanded(
              child: GestureDetector(
                onTap: _showMonthYearPicker,
                child: Container(
                  color: Colors.transparent, // To make the whole area clickable
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.calendar_1, size: 16, color: _primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM yyyy').format(selectedMonth),
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: _textGray, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            // → Next arrow
            _navArrowBtn(
              icon: Icons.chevron_right_rounded,
              onTap: _isCurrentMonth ? null : _goToNextMonth,
              enabled: !_isCurrentMonth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navArrowBtn({
    required IconData icon,
    VoidCallback? onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? _primary.withOpacity(0.06) : Colors.transparent,
          borderRadius: icon == Icons.chevron_left_rounded
              ? const BorderRadius.horizontal(left: Radius.circular(14))
              : const BorderRadius.horizontal(right: Radius.circular(14)),
        ),
        child: Icon(
          icon,
          size: 28,
          color: enabled ? _primary : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  // ─── Status Filter (scrollable chips — same pill style as WFH tab bar) ───

  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statusOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = _statusOptions[i];
          final isSelected = selectedStatus == opt['value'];
          final color = opt['color'] as Color;
          final bg = opt['bg'] as Color;

          return GestureDetector(
            onTap: () {
              if (selectedStatus != opt['value']) {
                setState(() => selectedStatus = opt['value'] as String);
                _fetchAttendance();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _primary : _border,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: _primary.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    size: 13,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    opt['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _textGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Summary Cards (same style as WFH _summaryCard) ──────────────────────

  Widget _buildSummaryCards() {
    final s = _getSummary();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          _summaryCard(
            label: 'Present',
            count: s['present']!,
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF137333),
            bgColor: const Color(0xFFE6F4EA),
          ),
          const SizedBox(width: 10),
          _summaryCard(
            label: 'WFH',
            count: s['wfh']!,
            icon: Icons.home_work_outlined,
            iconColor: const Color(0xFF0D7490),
            bgColor: const Color(0xFFE0F2FE),
          ),
          const SizedBox(width: 10),
          _summaryCard(
            label: 'Late',
            count: s['late']!,
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFB06000),
            bgColor: const Color(0xFFFEF7E0),
          ),
          const SizedBox(width: 10),
          _summaryCard(
            label: 'Absent',
            count: s['absent']!,
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFFC5221F),
            bgColor: const Color(0xFFFCE8E6),
          ),
        ],
      ),
    );
  }

  /// Exact same widget pattern as WFH screen's `_summaryCard`
  Widget _summaryCard({
    required String label,
    required int count,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                color: _textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: _textGray,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

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
              border: Border.all(color: _border),
            ),
            child: const Icon(Iconsax.calendar_remove, size: 30, color: _textGray),
          ),
          const SizedBox(height: 16),
          Text(
            'No records for ${DateFormat('MMMM yyyy').format(selectedMonth)}',
            style: const TextStyle(
              color: _textGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different month or filter',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Attendance Card (consistent with WFH card style) ────────────────────

  Widget _buildAttendanceCard({
    required String date,
    required DateTime? checkIn,
    required DateTime? checkOut,
    required String status,
    required String workMode,
  }) {
    final bool isWFH = workMode.toLowerCase() == 'wfh';
    final Color statusTxtColor = _getStatusColor(status);
    final Color statusBg = _getStatusBg(status);
    final String statusLabel = _statusLabel(status);

    DateTime? parsedDate;
    try {
      final ds = date.contains('T') ? date.split('T')[0] : date;
      parsedDate = DateTime.parse(ds);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Icon + Date info + Status badge ──
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.calendar_1, color: _primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parsedDate != null
                            ? DateFormat('EEEE').format(parsedDate)
                            : 'Unknown',
                        style: const TextStyle(
                          color: _textGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        parsedDate != null
                            ? DateFormat('dd MMMM yyyy').format(parsedDate)
                            : date,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusTxtColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isWFH) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'WFH',
                          style: TextStyle(
                            color: Color(0xFF0D7490),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Divider ──
            const Divider(height: 1, color: _border),
            const SizedBox(height: 12),
            // ── Row 2: Check In / Check Out / Hours ──
            Row(
              children: [
                _timeColumn(
                  icon: Iconsax.login,
                  label: 'Check In',
                  value: checkIn != null ? DateFormat('hh:mm a').format(checkIn) : '--:--',
                  color: const Color(0xFF137333),
                ),
                Container(width: 1, height: 28, color: _border),
                _timeColumn(
                  icon: Iconsax.logout,
                  label: 'Check Out',
                  value: checkOut != null ? DateFormat('hh:mm a').format(checkOut) : '--:--',
                  color: const Color(0xFFB06000),
                ),
                Container(width: 1, height: 28, color: _border),
                _timeColumn(
                  icon: Iconsax.clock,
                  label: 'Hours',
                  value: _calcHours(checkIn, checkOut),
                  color: _primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _textDark),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _calcHours(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) return '--';
    final dur = checkOut.difference(checkIn);
    return '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present': return 'Present';
      case 'absent': return 'Absent';
      case 'late': return 'Late';
      case 'half_day': return 'Half Day';
      case 'wfh': return 'WFH';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present': return const Color(0xFF137333);
      case 'absent': return const Color(0xFFC5221F);
      case 'late': return const Color(0xFFB06000);
      case 'half_day': return const Color(0xFF6D28D9);
      case 'wfh': return const Color(0xFF0D7490);
      default: return _primary;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'present': return const Color(0xFFE6F4EA);
      case 'absent': return const Color(0xFFFCE8E6);
      case 'late': return const Color(0xFFFEF7E0);
      case 'half_day': return const Color(0xFFF3E8FF);
      case 'wfh': return const Color(0xFFE0F2FE);
      default: return const Color(0xFFE8F0F7);
    }
  }
}
