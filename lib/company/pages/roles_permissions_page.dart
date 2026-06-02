import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  String _activeTab = 'Roles';
  bool _isLoading = true;
  List<dynamic> _roles = [];
  List<dynamic> _permissions = [];
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        _companyId = user['company']?['id']?.toString();
      }

      if (_companyId != null) {
        final rolesList = await ApiService.getRoles(_companyId!);
        final permissionsList = await ApiService.getPermissions();

        if (mounted) {
          setState(() {
            _roles = rolesList;
            _permissions = permissionsList;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load access control data: $e')),
        );
      }
    }
  }

  Future<void> _deleteRole(String id) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteRole(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role deleted successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete role: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getRoleColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('admin')) return Colors.red;
    if (lower.contains('manager')) return Colors.blue;
    if (lower.contains('employee')) return Colors.green;
    if (lower.contains('hr')) return Colors.orange;
    if (lower.contains('finance')) return Colors.teal;
    return Colors.purple;
  }

  IconData _getRoleIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('admin')) return Icons.admin_panel_settings_outlined;
    if (lower.contains('manager')) return Icons.manage_accounts_outlined;
    if (lower.contains('employee')) return Icons.person_outline;
    if (lower.contains('hr')) return Icons.people_outline;
    if (lower.contains('finance')) return Icons.account_balance_outlined;
    return Icons.shield_outlined;
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : Column(
              children: [
                // Tab switcher
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
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
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 4)]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
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
                  child: _activeTab == 'Roles' ? _buildRolesList() : _buildPermissionMatrix(),
                ),
              ],
            ),
    );
  }

  Widget _buildRolesList() {
    if (_roles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No roles defined yet', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _roles.length,
      itemBuilder: (_, i) => _buildRoleCard(_roles[i]),
    );
  }

  Widget _buildRoleCard(dynamic role) {
    final name = (role['name'] ?? '').toString();
    final description = (role['description'] ?? '').toString();
    final isSystem = role['company'] == null || role['companyId'] == null;
    final List<dynamic> permsList = role['permissions'] ?? [];
    final permsCount = permsList.length;
    final Color c = _getRoleColor(name);
    final IconData icon = _getRoleIcon(name);
    final roleId = role['id']?.toString() ?? '';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _RoleDetailScreen(role: role, allPermissions: _permissions),
          ),
        );
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
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
                  child: Icon(icon, color: c, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
                          const SizedBox(width: 8),
                          if (isSystem)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
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
                      Text(description, style: const TextStyle(fontSize: 11, color: kSubText)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: kSubText),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _metaChip(Icons.lock_open_outlined, '$permsCount permissions', c),
                const Spacer(),
                if (!isSystem) ...[
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _RoleDetailScreen(role: role, allPermissions: _permissions),
                        ),
                      );
                      _loadData();
                    },
                    child: const Icon(Icons.edit_outlined, size: 18, color: kSubText),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Delete Role', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: Text('Are you sure you want to delete the role "$name"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel', style: TextStyle(color: kSubText)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _deleteRole(roleId);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
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
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPermissionMatrix() {
    if (_permissions.isEmpty || _roles.isEmpty) {
      return const Center(child: Text('No matrix data available'));
    }

    final visibleRoles = _roles.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Permission Matrix', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
            Text('Quick check of role privileges', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 180),
                      ...visibleRoles.map((role) {
                        final name = (role['name'] ?? '').toString();
                        final Color c = _getRoleColor(name);
                        return Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ],
                  ),
                  const Divider(height: 1),
                  ..._permissions.map((perm) {
                    final permName = '${perm['action']} : ${perm['resource']}';
                    final permId = perm['id']?.toString() ?? '';

                    return Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Text(permName, style: const TextStyle(fontSize: 11, color: kText)),
                          ),
                        ),
                        ...visibleRoles.map((role) {
                          final List<dynamic> grantedList = role['permissions'] ?? [];
                          final hasAccess = grantedList.any((p) => p['id']?.toString() == permId);
                          final Color c = _getRoleColor(role['name']?.toString() ?? '');

                          return SizedBox(
                            width: 80,
                            child: Center(
                              child: Icon(
                                hasAccess ? Icons.check_circle : Icons.remove_circle_outline,
                                size: 18,
                                color: hasAccess ? c : Colors.grey.shade200,
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoleSheet() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create New Role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 16),
            _sheet_field(nameCtrl, 'Role name (e.g. Sales Lead)'),
            const SizedBox(height: 10),
            _sheet_field(descCtrl, 'Description'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && _companyId != null) {
                    Navigator.pop(ctx);
                    setState(() => _isLoading = true);
                    try {
                      await ApiService.createRole(
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        companyId: _companyId!,
                        permissionIds: [],
                      );
                      _loadData();
                    } catch (e) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create role: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Create Role', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _RoleDetailScreen extends StatefulWidget {
  final dynamic role;
  final List<dynamic> allPermissions;
  const _RoleDetailScreen({required this.role, required this.allPermissions});

  @override
  State<_RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends State<_RoleDetailScreen> {
  late List<String> _grantedPermIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final List<dynamic> permsList = widget.role['permissions'] ?? [];
    _grantedPermIds = permsList.map((p) => p['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final roleId = widget.role['id']?.toString() ?? '';
      final roleName = widget.role['name']?.toString() ?? '';
      final roleDesc = widget.role['description']?.toString() ?? '';

      await ApiService.updateRole(
        roleId,
        name: roleName,
        description: roleDesc,
        permissionIds: _grantedPermIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update permissions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.role['name'] ?? '').toString();
    final description = (widget.role['description'] ?? '').toString();
    final isSystem = widget.role['company'] == null || widget.role['companyId'] == null;
    final Color c = Colors.blue;

    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(
        context,
        name,
        actions: [
          if (!isSystem)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                : TextButton(
                    onPressed: _saveChanges,
                    child: const Text('Save', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.shield_outlined, color: c, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
                        const SizedBox(height: 2),
                        Text(description, style: const TextStyle(fontSize: 12, color: kSubText)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _infoPill('${_grantedPermIds.length} permissions', c),
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
            const Text('Role Permissions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 4),
            Text(
              isSystem ? 'System roles have fixed permissions.' : 'Toggle permissions for this role.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ...widget.allPermissions.map((perm) {
              final permId = perm['id']?.toString() ?? '';
              final permName = '${perm['action']} : ${perm['resource']}';
              final desc = perm['description']?.toString() ?? 'Allows ${perm['action']} on ${perm['resource']}';
              final granted = _grantedPermIds.contains(permId);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      granted ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: granted ? Colors.green : Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(permName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: granted ? kText : Colors.grey.shade500)),
                          Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    if (!isSystem)
                      Switch(
                        value: granted,
                        onChanged: (v) {
                          setState(() {
                            if (v) {
                              _grantedPermIds.add(permId);
                            } else {
                              _grantedPermIds.remove(permId);
                            }
                          });
                        },
                        activeThumbColor: kPrimary,
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
