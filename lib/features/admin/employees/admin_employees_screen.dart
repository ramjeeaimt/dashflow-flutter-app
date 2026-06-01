import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/features/admin/services/admin_api_service.dart';

// ── Field extractors (handle both flat and nested API structures) ─────────────

String _empName(Map<String, dynamic> e) {
  // 1. Top-level firstName / lastName
  final first = e['firstName']?.toString().trim() ?? '';
  final last = e['lastName']?.toString().trim() ?? '';
  if (first.isNotEmpty || last.isNotEmpty) return '$first $last'.trim();

  // 2. Nested user object
  final u = e['user'];
  if (u is Map<String, dynamic>) {
    final uf = u['firstName']?.toString().trim() ?? '';
    final ul = u['lastName']?.toString().trim() ?? '';
    if (uf.isNotEmpty || ul.isNotEmpty) return '$uf $ul'.trim();
    final un = u['name']?.toString().trim() ?? '';
    if (un.isNotEmpty) return un;
  }

  // 3. Direct name field
  return e['name']?.toString().trim() ?? '';
}

String _empEmail(Map<String, dynamic> e) {
  final direct = e['email']?.toString() ?? '';
  if (direct.isNotEmpty) return direct;
  final u = e['user'];
  if (u is Map<String, dynamic>) return u['email']?.toString() ?? '';
  return '';
}

String _empPhone(Map<String, dynamic> e) {
  final direct = e['phone']?.toString() ?? '';
  if (direct.isNotEmpty) return direct;
  final u = e['user'];
  if (u is Map<String, dynamic>) return u['phone']?.toString() ?? '';
  return '';
}

String _empDesignation(Map<String, dynamic> e) {
  return e['designation']?.toString() ?? e['jobTitle']?.toString() ?? 'Employee';
}

String _empDept(Map<String, dynamic> e) {
  final d = e['department'];
  if (d == null) return '';
  if (d is String) return d;
  if (d is Map<String, dynamic>) return d['name']?.toString() ?? '';
  return '';
}

String _empId(Map<String, dynamic> e) =>
    (e['_id'] ?? e['id'] ?? e['employeeId'] ?? '--').toString();

// ─────────────────────────────────────────────────────────────────────────────

class AdminEmployeesScreen extends StatefulWidget {
  const AdminEmployeesScreen({super.key});

  @override
  State<AdminEmployeesScreen> createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _selectedDept = 'All';
  List<String> _departments = ['All'];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final data = await AdminApiService.getAllEmployees();
    final employees = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    final depts = <String>{'All'};
    for (final e in employees) {
      final d = _empDept(e);
      if (d.isNotEmpty) depts.add(d);
    }

    if (mounted) {
      setState(() {
        _all = employees;
        _departments = depts.toList();
        _loading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    setState(() {
      _filtered = _all.where((e) {
        final name = _empName(e).toLowerCase();
        final designation = _empDesignation(e).toLowerCase();
        final dept = _empDept(e);
        final matchSearch = q.isEmpty || name.contains(q) || designation.contains(q);
        final matchDept = _selectedDept == 'All' || dept == _selectedDept;
        return matchSearch && matchDept;
      }).toList();
    });
  }

  Future<void> _confirmDelete(Map<String, dynamic> employee) async {
    final id = _empId(employee);
    if (id == '--') return;
    final name = _empName(employee).isEmpty ? 'this employee' : _empName(employee);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Employee', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove $name from the system? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      final success = await AdminApiService.deleteEmployee(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '$name removed.' : 'Failed to remove employee.'),
            backgroundColor: success ? kPrimary : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (success) _fetch();
      }
    }
  }

  void _showDetail(Map<String, dynamic> employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmployeeDetailSheet(employee: employee),
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
            _buildSearch(),
            _buildDeptFilter(),
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
                            itemBuilder: (_, i) => _EmployeeCard(
                              employee: _filtered[i],
                              onTap: () => _showDetail(_filtered[i]),
                              onDelete: () => _confirmDelete(_filtered[i]),
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
                const Text(
                  'Employees',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kText),
                ),
                Text(
                  _loading ? 'Loading...' : '${_filtered.length} of ${_all.length} members',
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

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CrmSearchBar(
        hint: 'Search by name or designation…',
        onChanged: (v) {
          _search = v;
          _applyFilter();
        },
      ),
    );
  }

  Widget _buildDeptFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _departments.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final dept = _departments[i];
          final selected = _selectedDept == dept;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDept = dept);
              _applyFilter();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? kPrimary : kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? kPrimary : kBorder),
              ),
              child: Text(
                dept,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : kSubText,
                ),
              ),
            ),
          );
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
            child: const Icon(Iconsax.profile_2user, color: kSubText, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No employees found', style: TextStyle(fontSize: 16, color: kSubText)),
        ],
      ),
    );
  }
}

// ── Employee card ─────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EmployeeCard({required this.employee, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = _empName(employee);
    final designation = _empDesignation(employee);
    final dept = _empDept(employee);
    final email = _empEmail(employee);
    final phone = _empPhone(employee);
    final displayName = name.isEmpty ? 'Unknown' : name;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            AvatarInitials(name: displayName, radius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText),
                  ),
                  const SizedBox(height: 2),
                  Text(designation, style: const TextStyle(fontSize: 12, color: kSubText)),
                  if (dept.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(dept, style: const TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Iconsax.sms, size: 11, color: kSubText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(email, style: const TextStyle(fontSize: 11, color: kSubText), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                  if (phone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Iconsax.call, size: 11, color: kSubText),
                        const SizedBox(width: 4),
                        Text(phone, style: const TextStyle(fontSize: 11, color: kSubText)),
                      ],
                    ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Iconsax.arrow_right_3, color: kSubText, size: 16),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.trash, size: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────

class _EmployeeDetailSheet extends StatelessWidget {
  final Map<String, dynamic> employee;
  const _EmployeeDetailSheet({required this.employee});

  @override
  Widget build(BuildContext context) {
    final name = _empName(employee);
    final displayName = name.isEmpty ? 'Unknown' : name;
    final designation = _empDesignation(employee);
    final dept = _empDept(employee);
    final email = _empEmail(employee);
    final phone = _empPhone(employee);
    final empId = _empId(employee);
    final joinDate = _formatDate(
      employee['joiningDate']?.toString() ?? employee['createdAt']?.toString() ?? '',
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 24),
            Center(child: AvatarInitials(name: displayName, radius: 36)),
            const SizedBox(height: 14),
            Center(
              child: Text(
                displayName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText),
              ),
            ),
            Center(child: Text(designation, style: const TextStyle(fontSize: 14, color: kSubText))),
            if (dept.isNotEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(dept, style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 28),
            const Divider(color: kBorder),
            const SizedBox(height: 20),
            _DetailRow(icon: Iconsax.sms, label: 'Email', value: email.isEmpty ? '--' : email),
            const SizedBox(height: 16),
            _DetailRow(icon: Iconsax.call, label: 'Phone', value: phone.isEmpty ? '--' : phone),
            const SizedBox(height: 16),
            _DetailRow(icon: Iconsax.card, label: 'Employee ID', value: empId),
            const SizedBox(height: 16),
            _DetailRow(icon: Iconsax.calendar, label: 'Joined', value: joinDate),
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

  String _formatDate(String raw) {
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: kSubText),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: kSubText, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: kText, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
