import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/features/admin/services/admin_api_service.dart';
import 'package:dashflow/features/admin/settings/admin_access_control_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _adminName = 'Admin';
  int _totalEmployees = 0;
  int _pendingLeaves = 0;
  int _pendingWfh = 0;
  int _presentToday = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _recentLeaves = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _loadAdminName();
    await Future.wait([_loadEmployees(), _loadLeaves(), _loadAttendance(), _loadWfh()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadAdminName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        final first = user['firstName'] ?? user['name'] ?? 'Admin';
        if (mounted) setState(() => _adminName = first.toString().split(' ').first);
      }
    } catch (_) {}
  }

  Future<void> _loadEmployees() async {
    final data = await AdminApiService.getAllEmployees();
    if (mounted) setState(() => _totalEmployees = data.length);
  }

  Future<void> _loadLeaves() async {
    final data = await AdminApiService.getAllLeaves();
    final pending = data.where((l) {
      final s = (l['status'] ?? '').toString().toUpperCase();
      return s == 'PENDING' || s == 'AWAITING';
    }).toList();
    if (mounted) {
      setState(() {
        _pendingLeaves = pending.length;
        _recentLeaves = data
            .take(5)
            .map((l) => Map<String, dynamic>.from(l as Map))
            .toList();
      });
    }
  }

  Future<void> _loadAttendance() async {
    final data = await AdminApiService.getAllAttendance();
    final today = DateTime.now();
    final presentCount = data.where((a) {
      final dateStr = a['checkIn'] ?? a['date'] ?? a['createdAt'] ?? '';
      if (dateStr.isEmpty) return false;
      try {
        final d = DateTime.parse(dateStr.toString()).toLocal();
        return d.year == today.year && d.month == today.month && d.day == today.day;
      } catch (_) {
        return false;
      }
    }).length;
    if (mounted) setState(() => _presentToday = presentCount);
  }

  Future<void> _loadWfh() async {
    final data = await AdminApiService.getAllWfhRequests();
    final pending = data.where((w) {
      final s = (w['status'] ?? '').toString().toUpperCase();
      return s == 'PENDING';
    }).length;
    if (mounted) setState(() => _pendingWfh = pending);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _today() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: RefreshIndicator(
        color: kPrimary,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentLeaves(),
                  const SizedBox(height: 24),
                  _buildInsightBanner(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: kPrimary,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A4F65), kPrimary, Color(0xFF4D8AA8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, $_adminName 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _today(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminAccessControlScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Iconsax.key, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Iconsax.notification, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatData('Total Employees', '$_totalEmployees', Iconsax.profile_2user, const Color(0xFF36617E), 'Team members'),
      _StatData('Present Today', '$_presentToday', Iconsax.clock, const Color(0xFF10B981), 'Checked in'),
      _StatData('Pending Leaves', '$_pendingLeaves', Iconsax.note, const Color(0xFFF59E0B), 'Awaiting review'),
      _StatData('WFH Requests', '$_pendingWfh', Iconsax.home_2, const Color(0xFF8B5CF6), 'Pending approval'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 12),
        _loading
            ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: kPrimary)))
            : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.65,
                children: stats.map((s) => _StatTile(data: s)).toList(),
              ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionTile(icon: Iconsax.user_add, label: 'Add Employee', color: kPrimary, onTap: () {}),
            const SizedBox(width: 10),
            _ActionTile(icon: Iconsax.document_text, label: 'View Leaves', color: const Color(0xFFF59E0B), onTap: () {}),
            const SizedBox(width: 10),
            _ActionTile(icon: Iconsax.clock, label: 'Attendance', color: const Color(0xFF10B981), onTap: () {}),
            const SizedBox(width: 10),
            _ActionTile(icon: Iconsax.chart, label: 'Reports', color: const Color(0xFF8B5CF6), onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentLeaves() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Leave Requests', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
            if (_recentLeaves.isNotEmpty)
              Text('${_recentLeaves.length} total', style: const TextStyle(fontSize: 13, color: kSubText)),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const SizedBox.shrink()
        else if (_recentLeaves.isEmpty)
          _EmptyCard(icon: Iconsax.note_remove, message: 'No leave requests yet')
        else
          Column(children: _recentLeaves.map(_buildLeaveItem).toList()),
      ],
    );
  }

  Widget _buildLeaveItem(Map<String, dynamic> leave) {
    final status = (leave['status'] ?? 'PENDING').toString().toUpperCase();
    final empName = _getEmployeeName(leave);
    final type = (leave['type'] ?? 'Leave').toString();
    final start = _formatDate(leave['startDate']?.toString() ?? '');
    Color statusColor;
    if (status == 'APPROVED') {
      statusColor = const Color(0xFF10B981);
    } else if (status == 'DECLINED' || status == 'REJECTED') {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          AvatarInitials(name: empName, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
                const SizedBox(height: 2),
                Text('$type · $start', style: const TextStyle(fontSize: 12, color: kSubText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status == 'AWAITING' ? 'PENDING' : status,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary.withValues(alpha: 0.08), kPrimary.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage your team efficiently', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
                const SizedBox(height: 4),
                Text('Review pending items and keep operations smooth.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Iconsax.chart_21, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  String _getEmployeeName(Map<String, dynamic> leave) {
    final emp = leave['employee'];
    if (emp is Map) {
      var name = '${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}'.trim();
      if (name.isNotEmpty) return name;
      final u = emp['user'];
      if (u is Map) {
        name = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
        if (name.isNotEmpty) return name;
        final un = u['name']?.toString().trim() ?? '';
        if (un.isNotEmpty) return un;
      }
      return emp['name']?.toString() ?? emp['email']?.toString() ?? 'Employee';
    }
    return leave['employeeName']?.toString() ?? 'Employee';
  }

  String _formatDate(String raw) {
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

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String sub;
  const _StatData(this.label, this.value, this.icon, this.color, this.sub);
}

class _StatTile extends StatelessWidget {
  final _StatData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 16),
              ),
              Text(data.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.label, style: const TextStyle(fontSize: 10, color: kSubText, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              Text(data.sub, style: const TextStyle(fontSize: 9, color: kSubText), overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: kSubText, size: 32),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: kSubText, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
