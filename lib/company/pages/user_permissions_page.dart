import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class UserPermissionsScreen extends StatefulWidget {
  const UserPermissionsScreen({super.key});

  @override
  State<UserPermissionsScreen> createState() => _UserPermissionsScreenState();
}

class _UserPermissionsScreenState extends State<UserPermissionsScreen> {
  String _searchQuery = '';
  String _roleFilter = 'All Roles';

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'pritam kumar',
      'email': 'pritamcodeservir@gmail.com',
      'roles': ['MANAGER', 'CTO', 'EMPLOYEE'],
      'overlays': 0,
      'id': 'DIF0029',
    },
    {
      'name': 'anushka pandit',
      'email': 'anushk2026a@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 1,
      'id': 'DIF0013',
    },
    {
      'name': 'Harsh jaiswal',
      'email': 'harshjaiswal833@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 1,
      'id': 'DIF0010',
    },
    {
      'name': 'Krishna Kumar',
      'email': 'krishna6maurya@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 0,
      'id': 'DIF0024',
    },
    {
      'name': 'sadhna kumari',
      'email': 'sadhanachaudhary421@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 1,
      'id': 'DIF0011',
    },
    {
      'name': 'keshav pathak',
      'email': 'keshav2025p@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 0,
      'id': 'DIF0020',
    },
    {
      'name': 'Simran Kumari',
      'email': 'kumarisimran2018@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 0,
      'id': 'DIF0015',
    },
    {
      'name': 'Soni Verma',
      'email': 'sonivermasoni55@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 0,
      'id': 'DIF0017',
    },
    {
      'name': 'Ankur Gautam',
      'email': 'ankgau8714@gmail.com',
      'roles': ['EMPLOYEE'],
      'overlays': 1,
      'id': 'DIF0022',
    },
  ];

  final List<String> _roleFilters = ['All Roles', 'Admin', 'Manager', 'Employee'];

  List<Map<String, dynamic>> get _filtered {
    return _users.where((u) {
      final matchSearch = _searchQuery.isEmpty ||
          u['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchRole = _roleFilter == 'All Roles' ||
          (u['roles'] as List).any((r) => r.toString().toLowerCase() == _roleFilter.toLowerCase());
      return matchSearch && matchRole;
    }).toList();
  }

  int get _totalUsers => _users.length;
  int get _adminCount => _users.where((u) => (u['roles'] as List).contains('ADMIN')).length;
  int get _totalOverlays => _users.fold<int>(0, (sum, u) => sum + (u['overlays'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(context, 'User Permissions', actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_outlined, size: 16),
            label: const Text('Add User', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
      body: Column(
        children: [
          // Stats bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _statCard(
                    'TOTAL USER PROFILES',
                    '$_totalUsers',
                    Icons.people_alt_outlined,
                    kPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'SYSTEM ADMINISTRATORS',
                    '$_adminCount',
                    Icons.shield_outlined,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'CUSTOM DIRECT OVERLAYS',
                    '$_totalOverlays',
                    Icons.tune_outlined,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Search & role filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                CrmSearchBar(
                  hint: 'Search users by name or email...',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roleFilters
                        .map((r) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _roleFilter = r),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _roleFilter == r
                                        ? kPrimary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _roleFilter == r
                                          ? kPrimary
                                          : kBorder,
                                    ),
                                  ),
                                  child: Text(
                                    r,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _roleFilter == r
                                          ? Colors.white
                                          : kSubText,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // User list
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) =>
                        _buildUserTile(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 8, color: kSubText, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final roles = user['roles'] as List;
    final overlays = user['overlays'] as int;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _UserPermissionDetailScreen(user: user),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            AvatarInitials(name: user['name'], radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['name'],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kText)),
                  const SizedBox(height: 2),
                  Text(user['email'],
                      style: const TextStyle(fontSize: 11, color: kSubText)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ...roles.map((r) => _roleBadge(r.toString())),
                      if (overlays > 0)
                        _overlayBadge('+$overlays OVERLAYS'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: kSubText),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    Color c;
    switch (role) {
      case 'ADMIN': c = Colors.red; break;
      case 'MANAGER': c = Colors.blue; break;
      case 'CTO': c = Colors.purple; break;
      default: c = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(role,
          style: TextStyle(
              fontSize: 9, color: c, fontWeight: FontWeight.bold)),
    );
  }

  Widget _overlayBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 9, color: Colors.orange, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.vpn_key_outlined, size: 48, color: kPrimary),
          ),
          const SizedBox(height: 16),
          const Text('Select an Employee',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Choose an employee from the directory to configure their organizational security roles and individual permission overrides.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permission detail screen ─────────────────────────────────────────────────
class _UserPermissionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const _UserPermissionDetailScreen({required this.user});

  @override
  State<_UserPermissionDetailScreen> createState() =>
      _UserPermissionDetailScreenState();
}

class _UserPermissionDetailScreenState
    extends State<_UserPermissionDetailScreen> {
  late List<String> _assignedRoles;

  final List<Map<String, dynamic>> _availableRoles = [
    {'role': 'ADMIN', 'desc': 'Full system access — manage all settings, users, and data', 'color': Colors.red},
    {'role': 'MANAGER', 'desc': 'Team management — manage employees, approve leaves, view reports', 'color': Colors.blue},
    {'role': 'CTO', 'desc': 'Technical lead — access engineering tools and infrastructure', 'color': Colors.purple},
    {'role': 'HR', 'desc': 'HR access — manage recruitment, attendance, and onboarding', 'color': Colors.orange},
    {'role': 'EMPLOYEE', 'desc': 'Standard employee — access own profile, leaves, payslips', 'color': Colors.green},
    {'role': 'FINANCE', 'desc': 'Finance access — manage payroll, invoices, and budgets', 'color': Colors.teal},
  ];

  final List<Map<String, dynamic>> _permissionOverrides = [
    {'name': 'View All Employee Data', 'granted': false, 'module': 'HR'},
    {'name': 'Approve Leave Requests', 'granted': false, 'module': 'Attendance'},
    {'name': 'Generate Payroll', 'granted': false, 'module': 'Finance'},
    {'name': 'Post Job Listings', 'granted': false, 'module': 'Recruitment'},
    {'name': 'View Financial Reports', 'granted': false, 'module': 'Finance'},
    {'name': 'Manage System Settings', 'granted': false, 'module': 'Admin'},
    {'name': 'Export Employee Data', 'granted': false, 'module': 'HR'},
    {'name': 'Access Monitoring Dashboard', 'granted': false, 'module': 'Monitoring'},
  ];

  @override
  void initState() {
    super.initState();
    _assignedRoles = List<String>.from(widget.user['roles'] as List);
  }

  void _toggleRole(String role) {
    setState(() {
      if (_assignedRoles.contains(role)) {
        if (_assignedRoles.length > 1) _assignedRoles.remove(role);
      } else {
        _assignedRoles.add(role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(
        context,
        'User Permissions',
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permissions saved successfully!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(
                    color: kPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User identity card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
                ],
              ),
              child: Row(
                children: [
                  AvatarInitials(name: widget.user['name'], radius: 28, bg: kPrimary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user['name'],
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kText)),
                        const SizedBox(height: 2),
                        Text(widget.user['email'],
                            style: const TextStyle(
                                fontSize: 12, color: kSubText)),
                        const SizedBox(height: 4),
                        Text(widget.user['id'],
                            style: const TextStyle(
                                fontSize: 11,
                                color: kPrimary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Organizational roles section
            _sectionHeader(
              Icons.badge_outlined,
              'Organizational Roles',
              'Assign roles that define this employee\'s access level across the system.',
            ),
            const SizedBox(height: 12),
            ..._availableRoles.map((r) => _buildRoleToggle(r)),
            const SizedBox(height: 20),

            // Individual permission overrides
            _sectionHeader(
              Icons.tune_outlined,
              'Individual Permission Overrides',
              'Grant or restrict specific features beyond the assigned role defaults.',
            ),
            const SizedBox(height: 12),
            ..._permissionOverrides.asMap().entries.map((e) =>
                _buildPermissionToggle(e.key, e.value)),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _assignedRoles = ['EMPLOYEE'];
                        for (var p in _permissionOverrides) {
                          p['granted'] = false;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Revoke All',
                        style: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Permissions saved!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kPrimary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kText)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleToggle(Map<String, dynamic> r) {
    final role = r['role'] as String;
    final isActive = _assignedRoles.contains(role);
    final color = r['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isActive ? color.withValues(alpha: 0.4) : kBorder,
            width: isActive ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(role,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(r['desc'],
                style: const TextStyle(fontSize: 12, color: kSubText)),
          ),
          Switch(
            value: isActive,
            onChanged: (_) => _toggleRole(role),
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle(int index, Map<String, dynamic> perm) {
    final granted = perm['granted'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(perm['name'],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kText)),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(perm['module'],
                      style: const TextStyle(
                          fontSize: 9, color: kPrimary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: granted
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  granted ? '✓ Granted' : '✗ Denied',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: granted ? Colors.green : Colors.red.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: granted,
                onChanged: (v) => setState(
                    () => _permissionOverrides[index]['granted'] = v),
                activeColor: kPrimary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
