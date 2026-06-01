import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/features/admin/services/admin_api_service.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final data = await AdminApiService.getAllAttendance();
    if (mounted) {
      final records = data.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        ..sort((a, b) => _parseDate(b['checkIn'] ?? b['createdAt'] ?? '').compareTo(_parseDate(a['checkIn'] ?? a['createdAt'] ?? '')));
      setState(() {
        _all = records;
        _loading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    setState(() {
      _filtered = _all.where((r) {
        final name = _empName(r).toLowerCase();
        final matchSearch = q.isEmpty || name.contains(q);
        final status = _recordStatus(r);
        final matchStatus = _statusFilter == 'All' || status == _statusFilter;
        return matchSearch && matchStatus;
      }).toList();
    });
  }

  String _recordStatus(Map<String, dynamic> r) {
    final wfh = r['isWorkFromHome'] == true || r['workMode']?.toString().toLowerCase() == 'wfh' || r['isWfh'] == true;
    if (wfh) return 'WFH';
    final checkIn = r['checkIn']?.toString() ?? '';
    if (checkIn.isEmpty) return 'Absent';
    try {
      final d = DateTime.parse(checkIn).toLocal();
      if (d.hour > 9 || (d.hour == 9 && d.minute > 30)) return 'Late';
    } catch (_) {}
    return 'Present';
  }

  int _countStatus(String status) {
    return _all.where((r) => _recordStatus(r) == status).length;
  }

  DateTime _parseDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime(2000);
    }
  }

  String _empName(Map<String, dynamic> r) {
    return _extractName(r['employee']) ??
        r['employeeName']?.toString() ??
        'Employee';
  }

  String? _extractName(dynamic emp) {
    if (emp is! Map) return null;
    var n = '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim();
    if (n.isNotEmpty) return n;
    final u = emp['user'];
    if (u is Map) {
      n = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
      if (n.isNotEmpty) return n;
      final un = u['name']?.toString().trim() ?? '';
      if (un.isNotEmpty) return un;
    }
    final name = emp['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
    return emp['email']?.toString();
  }

  void _showDetail(Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttendanceDetailSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStats(),
            _buildSearchAndFilter(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: kPrimary,
                          onRefresh: _fetch,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _AttendanceCard(
                              record: _filtered[i],
                              onTap: () => _showDetail(_filtered[i]),
                              empName: _empName(_filtered[i]),
                              status: _recordStatus(_filtered[i]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Attendance', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kText)),
                Text(
                  _loading ? 'Loading...' : '${_filtered.length} records',
                  style: const TextStyle(fontSize: 13, color: kSubText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, color: kText),
            onPressed: _fetch,
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final statuses = [
      ('Present', _countStatus('Present'), const Color(0xFF10B981)),
      ('Late', _countStatus('Late'), const Color(0xFFF59E0B)),
      ('WFH', _countStatus('WFH'), const Color(0xFF8B5CF6)),
      ('Absent', _countStatus('Absent'), const Color(0xFFEF4444)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: statuses.map((s) {
          final (label, count, color) = s;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _statusFilter = _statusFilter == label ? 'All' : label);
                _applyFilter();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _statusFilter == label ? color.withValues(alpha: 0.12) : kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusFilter == label ? color : kBorder),
                ),
                child: Column(
                  children: [
                    Text('$count', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _statusFilter == label ? color : kText)),
                    Text(label, style: TextStyle(fontSize: 9, color: _statusFilter == label ? color : kSubText, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: CrmSearchBar(
        hint: 'Search by employee name…',
        onChanged: (v) {
          _search = v;
          _applyFilter();
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: kCard, shape: BoxShape.circle, border: Border.all(color: kBorder)),
            child: const Icon(Iconsax.clock, color: kSubText, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No attendance records', style: TextStyle(fontSize: 15, color: kSubText)),
        ],
      ),
    );
  }
}

// ── Attendance Card ───────────────────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final String empName;
  final String status;
  final VoidCallback onTap;

  const _AttendanceCard({
    required this.record,
    required this.empName,
    required this.status,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case 'Present':
        return const Color(0xFF10B981);
      case 'Late':
        return const Color(0xFFF59E0B);
      case 'WFH':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFFEF4444);
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case 'Present':
        return Iconsax.tick_circle;
      case 'Late':
        return Iconsax.clock;
      case 'WFH':
        return Iconsax.home_2;
      default:
        return Iconsax.close_circle;
    }
  }

  String _fmt(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--';
    }
  }

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = record['checkIn']?.toString() ?? '';
    final checkOut = record['checkOut']?.toString() ?? '';
    final date = _fmtDate(checkIn.isNotEmpty ? checkIn : record['date']?.toString() ?? record['createdAt']?.toString() ?? '');
    final inTime = _fmt(checkIn);
    final outTime = _fmt(checkOut);

    // Calculate hours worked
    String hoursWorked = '--';
    if (checkIn.isNotEmpty && checkOut.isNotEmpty) {
      try {
        final inDt = DateTime.parse(checkIn);
        final outDt = DateTime.parse(checkOut);
        final diff = outDt.difference(inDt);
        final h = diff.inHours;
        final m = diff.inMinutes % 60;
        hoursWorked = '${h}h ${m}m';
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 2),
                  Text(date, style: const TextStyle(fontSize: 12, color: kSubText)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _TimeChip(label: 'IN', time: inTime, color: const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _TimeChip(label: 'OUT', time: outTime, color: const Color(0xFFEF4444)),
                      if (hoursWorked != '--') ...[
                        const SizedBox(width: 8),
                        _TimeChip(label: '', time: hoursWorked, color: kPrimary),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _statusColor)),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kSubText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  const _TimeChip({required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.isNotEmpty ? '$label $time' : time,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Attendance Detail Sheet ───────────────────────────────────────────────────
class _AttendanceDetailSheet extends StatelessWidget {
  final Map<String, dynamic> record;
  const _AttendanceDetailSheet({required this.record});

  String _empName() {
    final emp = record['employee'];
    if (emp is Map) {
      var n = '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim();
      if (n.isNotEmpty) return n;
      final u = emp['user'];
      if (u is Map) {
        n = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
        if (n.isNotEmpty) return n;
      }
      return emp['name']?.toString() ?? emp['email']?.toString() ?? 'Employee';
    }
    return record['employeeName']?.toString() ?? 'Employee';
  }

  String _fmtTime(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final d = DateTime.parse(raw).toLocal();
      final h = d.hour;
      final m = d.minute.toString().padLeft(2, '0');
      final ampm = h >= 12 ? 'PM' : 'AM';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      return '$h12:$m $ampm';
    } catch (_) {
      return '--';
    }
  }

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final d = DateTime.parse(raw).toLocal();
      const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _empName();
    final checkIn = record['checkIn']?.toString() ?? '';
    final checkOut = record['checkOut']?.toString() ?? '';
    final location = record['location']?.toString() ?? '';
    final notes = record['notes']?.toString() ?? '';
    final wfh = record['isWorkFromHome'] == true || record['workMode']?.toString().toLowerCase() == 'wfh' || record['isWfh'] == true;
    final date = _fmtDate(checkIn.isNotEmpty ? checkIn : record['date']?.toString() ?? record['createdAt']?.toString() ?? '');

    String hoursWorked = '--';
    if (checkIn.isNotEmpty && checkOut.isNotEmpty) {
      try {
        final diff = DateTime.parse(checkOut).difference(DateTime.parse(checkIn));
        hoursWorked = '${diff.inHours}h ${diff.inMinutes % 60}m';
      } catch (_) {}
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 20),
            Center(child: AvatarInitials(name: name, radius: 30)),
            const SizedBox(height: 12),
            Center(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText))),
            const SizedBox(height: 4),
            Center(child: Text(date, style: const TextStyle(fontSize: 13, color: kSubText))),
            if (wfh) ...[
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.home_2, size: 13, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 4),
                      Text('Work From Home', style: TextStyle(fontSize: 12, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(color: kBorder),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _TimeBlock(label: 'Check In', time: _fmtTime(checkIn), color: const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _TimeBlock(label: 'Check Out', time: _fmtTime(checkOut), color: const Color(0xFFEF4444))),
                const SizedBox(width: 12),
                Expanded(child: _TimeBlock(label: 'Duration', time: hoursWorked, color: kPrimary)),
              ],
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Iconsax.location, size: 16, color: kSubText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location', style: TextStyle(fontSize: 11, color: kSubText, fontWeight: FontWeight.w500)),
                        Text(location, style: const TextStyle(fontSize: 13, color: kText, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('NOTES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kSubText, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                child: Text(notes, style: const TextStyle(fontSize: 13, color: kText, height: 1.5)),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  const _TimeBlock({required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
