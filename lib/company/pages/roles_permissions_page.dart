import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  String _activeTab = 'Roles';

  final List<Map<String, dynamic>> _roles = [
    {
      'name': 'Admin',
      'description': 'Full system access — all modules, settings, and user management',
      'color': Colors.red,
      'icon': Icons.admin_panel_settings_outlined,
      'userCount': 1,
      'isSystem': true,
      'permissions': [
        'Dashboard', 'Employee Management', 'Leave Requests', 'Attendance',
        'Payroll', 'Finance', 'Projects', 'Tasks', 'Recruitment',
        'Monitoring', 'Settings', 'User Permissions',
      ],
    },
    {
      'name': 'Manager',
      'description': 'Team management — approve leaves, manage attendance, view reports',
      'color': Colors.blue,
      'icon': Icons.manage_accounts_outlined,
      'userCount': 3,
      'isSystem': true,
      'permissions': [
        'Dashboard', 'Employee Management', 'Leave Requests', 'Attendance',
        'Projects', 'Tasks', 'Reports',
      ],
    },
    {
      'name': 'Employee',
      'description': 'Standard access — own profile, leaves, payslips, and attendance',
      'color': Colors.green,
      'icon': Icons.person_outline,
      'userCount': 15,
      'isSystem': true,
      'permissions': [
        'My Attendance', 'My Leaves', 'My Payroll', 'My Profile',
      ],
    },
    {
      'name': 'HR Specialist',
      'description': 'HR access — manage recruitment, onboarding, and employee records',
      'color': Colors.orange,
      'icon': Icons.people_outline,
      'userCount': 2,
      'isSystem': false,
      'permissions': [
        'Dashboard', 'Employee Management', 'Leave Requests',
        'Attendance', 'Recruitment', 'Reports',
      ],
    },
    {
      'name': 'Finance Officer',
      'description': 'Finance access — payroll generation, invoices, and financial reports',
      'color': Colors.teal,
      'icon': Icons.account_balance_outlined,
      'userCount': 1,
      'isSystem': false,
      'permissions': [
        'Dashboard', 'Payroll', 'Finance Dashboard', 'Reports',
      ],
    },
  ];

  final List<Map<String, dynamic>> _allPermissions = [
    {'module': 'OVERVIEW', 'perms': ['View Dashboard', 'Notifications', 'Email Templates']},
    {'module': 'PEOPLE', 'perms': ['Employee Directory', 'Leave Requests (Admin)', 'Attendance (Admin)', 'My Attendance', 'My Leaves', 'My Payroll']},
    {'module': 'OPERATIONS', 'perms': ['Projects', 'Tasks', 'Time Tracking', 'Monitoring']},
    {'module': 'RECRUITMENT', 'perms': ['Jobs Hub', 'Clients / CRM']},
    {'module': 'FINANCE', 'perms': ['Payroll Management', 'Finance Dashboard']},
    {'module': 'ADMIN', 'perms': ['Company Settings', 'Roles & Permissions', 'User Permissions']},
  ];

  String? _selectedRoleId;

  Map<String, dynamic>? get _selectedRole =>
      _selectedRoleId == null
          ? null
          : _roles.firstWhere((r) => r['name'] == _selectedRoleId,
              orElse: () => _roles.first);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(
        context,
        'Roles & Permissions',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: _showCreateRoleSheet,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Role', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab switcher
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                  color: kBg, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: ['Roles', 'Permission Matrix'].map((t) {
                  final sel = _activeTab == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.07),
                                      blurRadius: 4)
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                            color: sel ? kPrimary : kSubText,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _activeTab == 'Roles'
                ? _buildRolesList()
                : _buildPermissionMatrix(),
          ),
        ],
      ),
    );
  }

  // ── Roles list ───────────────────────────────────────────────────────────
  Widget _buildRolesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _roles.length,
      itemBuilder: (_, i) => _buildRoleCard(_roles[i]),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role) {
    final Color c = role['color'] as Color;
    final bool isSystem = role['isSystem'] as bool;
    final perms = (role['permissions'] as List).length;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRoleId = role['name']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => _RoleDetailScreen(role: role)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(role['icon'] as IconData, color: c, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(role['name'],
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: kText)),
                          const SizedBox(width: 8),
                          if (isSystem)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('SYSTEM',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(role['description'],
                          style: const TextStyle(
                              fontSize: 11, color: kSubText)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: kSubText),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _metaChip(Icons.people_outline,
                    '${role['userCount']} users', kSubText),
                const SizedBox(width: 10),
                _metaChip(Icons.lock_open_outlined, '$perms permissions', c),
                const Spacer(),
                if (!isSystem) ...[
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.edit_outlined,
                        size: 18, color: kSubText),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _roles.remove(role)),
                    child: Icon(Icons.delete_outline,
                        size: 18, color: Colors.red.shade300),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Permission matrix ─────────────────────────────────────────────────────
  Widget _buildPermissionMatrix() {
    final roleNames =
        _roles.map((r) => r['name'] as String).take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permission Matrix',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kText)),
                Text('Overview of permissions per role',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 16),
                // Header row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role header
                      Row(
                        children: [
                          const SizedBox(width: 160),
                          ...roleNames.map((r) {
                            final role =
                                _roles.firstWhere((ro) => ro['name'] == r);
                            final c = role['color'] as Color;
                            return Container(
                              width: 70,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: c.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                        role['icon'] as IconData,
                                        color: c,
                                        size: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(r,
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: c),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const Divider(height: 1),
                      // Permission rows
                      ..._allPermissions.expand((mod) {
                        return [
                          // Module header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Text(
                              mod['module'],
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: kSubText,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          // Permission rows
                          ...(mod['perms'] as List<String>).map((perm) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 4),
                                    child: Text(perm,
                                        style: const TextStyle(
                                            fontSize: 11, color: kText)),
                                  ),
                                ),
                                ...roleNames.map((r) {
                                  final role = _roles
                                      .firstWhere((ro) => ro['name'] == r);
                                  final hasAccess =
                                      (role['permissions'] as List)
                                          .contains(perm);
                                  final c = role['color'] as Color;
                                  return SizedBox(
                                    width: 70,
                                    child: Center(
                                      child: Icon(
                                        hasAccess
                                            ? Icons.check_circle
                                            : Icons.remove_circle_outline,
                                        size: 18,
                                        color: hasAccess
                                            ? c
                                            : Colors.grey.shade200,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                        ];
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRoleSheet() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    Color selectedColor = kPrimary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create New Role',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kText)),
              const SizedBox(height: 16),
              _sheet_field(nameCtrl, 'Role name (e.g. Sales Lead)'),
              const SizedBox(height: 10),
              _sheet_field(descCtrl, 'Description'),
              const SizedBox(height: 10),
              const Text('Role Color',
                  style: TextStyle(
                      fontSize: 12, color: kSubText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  Colors.red, Colors.blue, Colors.green, Colors.orange,
                  Colors.purple, Colors.teal, const Color(0xFF36617E),
                ].map((c) => GestureDetector(
                  onTap: () => setModal(() => selectedColor = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == c ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: selectedColor == c
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      setState(() {
                        _roles.add({
                          'name': nameCtrl.text,
                          'description': descCtrl.text,
                          'color': selectedColor,
                          'icon': Icons.shield_outlined,
                          'userCount': 0,
                          'isSystem': false,
                          'permissions': <String>[],
                        });
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create Role',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheet_field(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kSubText, fontSize: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kPrimary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

// ── Role detail / edit screen ────────────────────────────────────────────────
class _RoleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> role;
  const _RoleDetailScreen({required this.role});

  @override
  State<_RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends State<_RoleDetailScreen> {
  final List<Map<String, dynamic>> _allModules = [
    {'module': 'OVERVIEW', 'perms': ['View Dashboard', 'Notifications', 'Email Templates']},
    {'module': 'PEOPLE', 'perms': ['Employee Directory', 'Leave Requests (Admin)', 'Attendance (Admin)', 'My Attendance', 'My Leaves', 'My Payroll']},
    {'module': 'OPERATIONS', 'perms': ['Projects', 'Tasks', 'Time Tracking', 'Monitoring']},
    {'module': 'RECRUITMENT', 'perms': ['Jobs Hub', 'Clients / CRM']},
    {'module': 'FINANCE', 'perms': ['Payroll Management', 'Finance Dashboard']},
    {'module': 'ADMIN', 'perms': ['Company Settings', 'Roles & Permissions', 'User Permissions']},
  ];

  late List<String> _grantedPerms;

  @override
  void initState() {
    super.initState();
    _grantedPerms = List<String>.from(widget.role['permissions'] as List);
  }

  @override
  Widget build(BuildContext context) {
    final Color c = widget.role['color'] as Color;
    final isSystem = widget.role['isSystem'] as bool;

    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(
        context,
        widget.role['name'],
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Role permissions saved!'),
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
            // Role card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.role['icon'] as IconData, color: c, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.role['name'],
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: c)),
                        const SizedBox(height: 2),
                        Text(widget.role['description'],
                            style: const TextStyle(
                                fontSize: 12, color: kSubText)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _infoPill('${widget.role['userCount']} users', kText),
                            const SizedBox(width: 8),
                            _infoPill(
                                '${_grantedPerms.length} permissions', c),
                            if (isSystem) ...[
                              const SizedBox(width: 8),
                              _infoPill('SYSTEM ROLE', Colors.grey),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Module Permissions',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kText)),
            const SizedBox(height: 4),
            Text(
              isSystem
                  ? 'System roles have fixed permissions. Create a custom role to modify.'
                  : 'Toggle permissions for this role. Changes apply to all users with this role.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),

            ..._allModules.map((mod) => _buildModuleSection(mod, isSystem)),
            const SizedBox(height: 24),

            if (!isSystem)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _grantedPerms.clear()),
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
                            content: Text('Role saved!'),
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

  Widget _buildModuleSection(Map<String, dynamic> mod, bool readOnly) {
    final perms = mod['perms'] as List<String>;
    final grantedCount =
        perms.where((p) => _grantedPerms.contains(p)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          // Module header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(mod['module'],
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: kSubText,
                        letterSpacing: 0.5)),
                const Spacer(),
                Text('$grantedCount/${perms.length}',
                    style: const TextStyle(
                        fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...perms.map((perm) {
            final granted = _grantedPerms.contains(perm);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    granted ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: granted ? Colors.green : Colors.grey.shade300,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(perm,
                        style: TextStyle(
                            fontSize: 13,
                            color: granted ? kText : Colors.grey.shade400)),
                  ),
                  if (!readOnly)
                    Switch(
                      value: granted,
                      onChanged: (v) {
                        setState(() {
                          v
                              ? _grantedPerms.add(perm)
                              : _grantedPerms.remove(perm);
                        });
                      },
                      activeColor: kPrimary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: granted
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        granted ? 'Allowed' : 'Denied',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color:
                              granted ? Colors.green : Colors.grey.shade400,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _infoPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold)),
    );
  }
}
