import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/features/admin/services/admin_api_service.dart';

class AdminLeavesScreen extends StatefulWidget {
  const AdminLeavesScreen({super.key});

  @override
  State<AdminLeavesScreen> createState() => _AdminLeavesScreenState();
}

class _AdminLeavesScreenState extends State<AdminLeavesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Leaves state
  List<Map<String, dynamic>> _leaves = [];
  bool _leavesLoading = true;
  String _leaveFilter = 'All';

  // WFH state
  List<Map<String, dynamic>> _wfh = [];
  bool _wfhLoading = true;
  String _wfhFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLeaves();
    _fetchWfh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaves() async {
    setState(() => _leavesLoading = true);
    final data = await AdminApiService.getAllLeaves();
    if (mounted) {
      setState(() {
        _leaves = data.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          ..sort((a, b) => _parseDate(b['createdAt'] ?? b['startDate'] ?? '').compareTo(_parseDate(a['createdAt'] ?? a['startDate'] ?? '')));
        _leavesLoading = false;
      });
    }
  }

  Future<void> _fetchWfh() async {
    setState(() => _wfhLoading = true);
    final data = await AdminApiService.getAllWfhRequests();
    if (mounted) {
      setState(() {
        _wfh = data.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          ..sort((a, b) => _parseDate(b['createdAt'] ?? b['startDate'] ?? '').compareTo(_parseDate(a['createdAt'] ?? a['startDate'] ?? '')));
        _wfhLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredLeaves {
    if (_leaveFilter == 'All') return _leaves;
    return _leaves.where((l) {
      final s = (l['status'] ?? '').toString().toUpperCase();
      if (_leaveFilter == 'Pending') return s == 'PENDING' || s == 'AWAITING';
      if (_leaveFilter == 'Approved') return s == 'APPROVED';
      if (_leaveFilter == 'Declined') return s == 'DECLINED' || s == 'REJECTED';
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredWfh {
    if (_wfhFilter == 'All') return _wfh;
    return _wfh.where((w) {
      final s = (w['status'] ?? '').toString().toUpperCase();
      if (_wfhFilter == 'Pending') return s == 'PENDING';
      if (_wfhFilter == 'Approved') return s == 'APPROVED';
      if (_wfhFilter == 'Declined') return s == 'DECLINED' || s == 'REJECTED';
      return true;
    }).toList();
  }

  int _countByStatus(List<Map<String, dynamic>> list, String filter) {
    return list.where((l) {
      final s = (l['status'] ?? '').toString().toUpperCase();
      if (filter == 'Pending') return s == 'PENDING' || s == 'AWAITING';
      if (filter == 'Approved') return s == 'APPROVED';
      if (filter == 'Declined') return s == 'DECLINED' || s == 'REJECTED';
      return true;
    }).length;
  }

  Future<void> _updateLeaveStatus(Map<String, dynamic> leave, String status) async {
    final id = leave['_id'] ?? leave['id'];
    if (id == null) return;

    _showLoading();
    final ok = await AdminApiService.updateLeaveStatus(id.toString(), status);
    if (mounted) {
      Navigator.pop(context); // close loading
      Navigator.pop(context); // close bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Leave $status successfully.' : 'Failed to update leave.'),
          backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (ok) _fetchLeaves();
    }
  }

  Future<void> _updateWfhStatus(Map<String, dynamic> wfh, String status) async {
    final id = wfh['_id'] ?? wfh['id'];
    if (id == null) return;

    _showLoading();
    final ok = await AdminApiService.updateWfhStatus(id.toString(), status);
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'WFH request $status.' : 'Failed to update WFH request.'),
          backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (ok) _fetchWfh();
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: kPrimary)),
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
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeavesTab(),
                  _buildWfhTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Requests', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kText)),
                Text(
                  '${_countByStatus(_leaves, 'Pending')} pending leave · ${_countByStatus(_wfh, 'Pending')} pending WFH',
                  style: const TextStyle(fontSize: 13, color: kSubText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, color: kText),
            onPressed: () {
              _fetchLeaves();
              _fetchWfh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 44,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(10)),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: kSubText,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.note, size: 14),
                const SizedBox(width: 6),
                Text('Leaves (${_leaves.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.home_2, size: 14),
                const SizedBox(width: 6),
                Text('WFH (${_wfh.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeavesTab() {
    return Column(
      children: [
        _buildSummaryRow(_leaves, _leaveFilter, (f) => setState(() => _leaveFilter = f)),
        _buildStatusFilter(_leaveFilter, (f) => setState(() => _leaveFilter = f)),
        Expanded(
          child: _leavesLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _filteredLeaves.isEmpty
                  ? _buildEmpty('No leave requests')
                  : RefreshIndicator(
                      color: kPrimary,
                      onRefresh: _fetchLeaves,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _filteredLeaves.length,
                        itemBuilder: (_, i) => _LeaveCard(
                          leave: _filteredLeaves[i],
                          onTap: () => _showLeaveDetail(_filteredLeaves[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildWfhTab() {
    return Column(
      children: [
        _buildSummaryRow(_wfh, _wfhFilter, (f) => setState(() => _wfhFilter = f)),
        _buildStatusFilter(_wfhFilter, (f) => setState(() => _wfhFilter = f)),
        Expanded(
          child: _wfhLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _filteredWfh.isEmpty
                  ? _buildEmpty('No WFH requests')
                  : RefreshIndicator(
                      color: kPrimary,
                      onRefresh: _fetchWfh,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _filteredWfh.length,
                        itemBuilder: (_, i) => _WfhCard(
                          wfh: _filteredWfh[i],
                          onTap: () => _showWfhDetail(_filteredWfh[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(List<Map<String, dynamic>> list, String current, ValueChanged<String> onSelect) {
    final statuses = [
      ('All', list.length, kPrimary),
      ('Pending', _countByStatus(list, 'Pending'), const Color(0xFFF59E0B)),
      ('Approved', _countByStatus(list, 'Approved'), const Color(0xFF10B981)),
      ('Declined', _countByStatus(list, 'Declined'), const Color(0xFFEF4444)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: statuses.map((s) {
          final (label, count, color) = s;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(label),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: current == label ? color.withValues(alpha: 0.12) : kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: current == label ? color : kBorder),
                ),
                child: Column(
                  children: [
                    Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: current == label ? color : kText)),
                    Text(label, style: TextStyle(fontSize: 10, color: current == label ? color : kSubText, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilter(String current, ValueChanged<String> onSelect) {
    return const SizedBox.shrink();
  }

  void _showLeaveDetail(Map<String, dynamic> leave) {
    final status = (leave['status'] ?? 'PENDING').toString().toUpperCase();
    final isPending = status == 'PENDING' || status == 'AWAITING';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestDetailSheet(
        title: 'Leave Request',
        icon: Iconsax.note,
        data: leave,
        isPending: isPending,
        onApprove: isPending ? () => _updateLeaveStatus(leave, 'APPROVED') : null,
        onDecline: isPending ? () => _updateLeaveStatus(leave, 'DECLINED') : null,
      ),
    );
  }

  void _showWfhDetail(Map<String, dynamic> wfh) {
    final status = (wfh['status'] ?? 'PENDING').toString().toUpperCase();
    final isPending = status == 'PENDING';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestDetailSheet(
        title: 'WFH Request',
        icon: Iconsax.home_2,
        data: wfh,
        isPending: isPending,
        onApprove: isPending ? () => _updateWfhStatus(wfh, 'APPROVED') : null,
        onDecline: isPending ? () => _updateWfhStatus(wfh, 'DECLINED') : null,
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: kCard, shape: BoxShape.circle, border: Border.all(color: kBorder)),
            child: const Icon(Iconsax.note_remove, color: kSubText, size: 36),
          ),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(fontSize: 15, color: kSubText)),
        ],
      ),
    );
  }

  DateTime _parseDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime(2000);
    }
  }
}

// ── Leave Card ────────────────────────────────────────────────────────────────
class _LeaveCard extends StatelessWidget {
  final Map<String, dynamic> leave;
  final VoidCallback onTap;
  const _LeaveCard({required this.leave, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final empName = _empName(leave);
    final type = (leave['type'] ?? 'Leave').toString();
    final start = _fmt(leave['startDate']?.toString() ?? '');
    final end = _fmt(leave['endDate']?.toString() ?? '');
    final status = (leave['status'] ?? 'PENDING').toString().toUpperCase();
    final Color statusColor;
    final IconData typeIcon;

    if (type.toLowerCase().contains('sick')) {
      typeIcon = Icons.medical_services_outlined;
    } else {
      typeIcon = Icons.beach_access_rounded;
    }

    if (status == 'APPROVED') {
      statusColor = const Color(0xFF10B981);
    } else if (status == 'DECLINED' || status == 'REJECTED') {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFFF59E0B);
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
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 2),
                  Text('$type · $start${start != end ? ' – $end' : ''}', style: const TextStyle(fontSize: 12, color: kSubText)),
                  if ((leave['reason'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      leave['reason'].toString(),
                      style: const TextStyle(fontSize: 11, color: kSubText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'AWAITING' ? 'PENDING' : status,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kSubText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _empName(Map<String, dynamic> l) {
    return _extractName(l['employee']) ??
        l['employeeName']?.toString() ??
        'Employee';
  }

  String? _extractName(dynamic emp) {
    if (emp is! Map) return null;
    // flat firstName/lastName
    var n = '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim();
    if (n.isNotEmpty) return n;
    // nested user object
    final u = emp['user'];
    if (u is Map) {
      n = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
      if (n.isNotEmpty) return n;
      final un = u['name']?.toString().trim() ?? '';
      if (un.isNotEmpty) return un;
    }
    // single name field or email fallback
    final name = emp['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
    return emp['email']?.toString();
  }

  String _fmt(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${m[d.month - 1]}';
    } catch (_) {
      return raw;
    }
  }
}

// ── WFH Card ──────────────────────────────────────────────────────────────────
class _WfhCard extends StatelessWidget {
  final Map<String, dynamic> wfh;
  final VoidCallback onTap;
  const _WfhCard({required this.wfh, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final empName = _empName(wfh);
    final start = _fmt(wfh['startDate']?.toString() ?? '');
    final end = _fmt(wfh['endDate']?.toString() ?? '');
    final status = (wfh['status'] ?? 'PENDING').toString().toUpperCase();
    final Color statusColor;

    if (status == 'APPROVED') {
      statusColor = const Color(0xFF10B981);
    } else if (status == 'DECLINED' || status == 'REJECTED') {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFFF59E0B);
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
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.home_2, color: Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 2),
                  Text('Work From Home · $start${start != end ? ' – $end' : ''}', style: const TextStyle(fontSize: 12, color: kSubText)),
                  if ((wfh['reason'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      wfh['reason'].toString(),
                      style: const TextStyle(fontSize: 11, color: kSubText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kSubText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _empName(Map<String, dynamic> w) {
    return _extractName(w['employee']) ??
        w['employeeName']?.toString() ??
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

  String _fmt(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${m[d.month - 1]}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Request Detail Bottom Sheet ───────────────────────────────────────────────
class _RequestDetailSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, dynamic> data;
  final bool isPending;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  const _RequestDetailSheet({
    required this.title,
    required this.icon,
    required this.data,
    required this.isPending,
    this.onApprove,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final empName = _empName(data);
    final status = (data['status'] ?? 'PENDING').toString().toUpperCase();
    final start = _fmt(data['startDate']?.toString() ?? '');
    final end = _fmt(data['endDate']?.toString() ?? '');
    final reason = data['reason']?.toString() ?? '';
    final type = data['type']?.toString() ?? title;

    Color statusColor;
    if (status == 'APPROVED') {
      statusColor = const Color(0xFF10B981);
    } else if (status == 'DECLINED' || status == 'REJECTED') {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFFF59E0B);
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
                      Text(empName, style: const TextStyle(fontSize: 13, color: kSubText)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status == 'AWAITING' ? 'PENDING' : status,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: kBorder),
            const SizedBox(height: 16),
            _Row(icon: Icons.calendar_today_rounded, label: 'Date Range', value: '$start – $end'),
            const SizedBox(height: 14),
            _Row(icon: Iconsax.profile_circle, label: 'Employee', value: empName),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('REASON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kSubText, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                child: Text(reason, style: const TextStyle(fontSize: 14, color: kText, height: 1.5)),
              ),
            ],
            const SizedBox(height: 28),
            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: onDecline,
                      child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFECFDF5),
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: onApprove,
                      child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
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

  String _empName(Map<String, dynamic> d) {
    return _extractName(d['employee']) ??
        d['employeeName']?.toString() ??
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

  String _fmt(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: kSubText),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: kSubText, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 14, color: kText, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
