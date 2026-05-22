import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roles & Permissions',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: const RolesPermissionsScreen(),
    );
  }
}

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  int _selectedTab = 0;
  String? _selectedRole;

  final List<RoleModel> roles = [
    RoleModel(
      id: '1',
      name: 'Admin',
      description: 'Full system access',
      icon: '👨‍💼',
      color: Colors.red,
      userCount: 3,
      permissions: [
        PermissionModel('User Management', 'Manage all users', true),
        PermissionModel('Role Management', 'Create and modify roles', true),
        PermissionModel('Payroll Management', 'Access payroll system', true),
        PermissionModel('Reports', 'View all reports', true),
        PermissionModel('Settings', 'Modify system settings', true),
        PermissionModel('Audit Logs', 'View system logs', true),
      ],
    ),
    RoleModel(
      id: '2',
      name: 'Manager',
      description: 'Team management access',
      icon: '👔',
      color: Colors.blue,
      userCount: 12,
      permissions: [
        PermissionModel('User Management', 'Manage team users', true),
        PermissionModel('Role Management', 'View roles only', false),
        PermissionModel('Payroll Management', 'View payroll reports', true),
        PermissionModel('Reports', 'View team reports', true),
        PermissionModel('Settings', 'Modify team settings', false),
        PermissionModel('Audit Logs', 'View team logs', false),
      ],
    ),
    RoleModel(
      id: '3',
      name: 'Employee',
      description: 'Basic user access',
      icon: '👤',
      color: Colors.green,
      userCount: 85,
      permissions: [
        PermissionModel('User Management', 'View profile', false),
        PermissionModel('Role Management', 'View roles only', false),
        PermissionModel('Payroll Management', 'View own payroll', true),
        PermissionModel('Reports', 'View own reports', true),
        PermissionModel('Settings', 'Modify own settings', true),
        PermissionModel('Audit Logs', 'No access', false),
      ],
    ),
    RoleModel(
      id: '4',
      name: 'HR Specialist',
      description: 'HR department access',
      icon: '👩‍💼',
      color: Colors.orange,
      userCount: 5,
      permissions: [
        PermissionModel('User Management', 'Manage employees', true),
        PermissionModel('Role Management', 'View roles only', false),
        PermissionModel('Payroll Management', 'Full access', true),
        PermissionModel('Reports', 'View HR reports', true),
        PermissionModel('Settings', 'Modify HR settings', true),
        PermissionModel('Audit Logs', 'View HR logs', true),
      ],
    ),
  ];
  @override
  void initState() {
    super.initState();
    _selectedRole = roles[0].id;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Roles & Permissions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTabNavigation(),
            const SizedBox(height: 16),
            _selectedTab == 0 ? _buildRolesTab() : _buildPermissionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0
                        ? Colors.purple[50]
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 0
                            ? Colors.purple
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    'Roles',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 0
                          ? Colors.purple
                          : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1
                        ? Colors.purple[50]
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 1
                            ? Colors.purple
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    'Permissions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 1
                          ? Colors.purple
                          : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Roles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...roles.map((role) => _buildRoleCard(role)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRoleCard(RoleModel role) {
    final isSelected = _selectedRole == role.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? role.color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: role.color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: role.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(role.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          role.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: role.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${role.userCount} users',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: role.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: role.color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPermissionsTab() {
    final currentRole = roles.firstWhere((r) => r.id == _selectedRole);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: currentRole.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: currentRole.color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(currentRole.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentRole.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentRole.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentRole.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Permissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${currentRole.permissions.where((p) => p.isGranted).length}/${currentRole.permissions.length} Active',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...currentRole.permissions.asMap().entries.map((entry) {
            int idx = entry.key;
            PermissionModel permission = entry.value;
            return _buildPermissionItem(permission, idx, currentRole);
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  Widget _buildPermissionItem(
    PermissionModel permission,
    int index,
    RoleModel role,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  permission.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: permission.isGranted ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              permission.isGranted ? '✓ Granted' : '✗ Denied',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: permission.isGranted
                    ? Colors.green[700]
                    : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class RoleModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final int userCount;
  final List<PermissionModel> permissions;
  RoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.userCount,
    required this.permissions,
  });
}
class PermissionModel {
  final String name;
  final String description;
  final bool isGranted;
  PermissionModel(this.name, this.description, this.isGranted);
}
