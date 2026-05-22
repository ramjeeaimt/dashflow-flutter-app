import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Permissions',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const UserPermissionsScreen(),
    );
  }
}

class UserPermissionsScreen extends StatefulWidget {
  const UserPermissionsScreen({super.key});

  @override
  State<UserPermissionsScreen> createState() => _UserPermissionsScreenState();
}

class _UserPermissionsScreenState extends State<UserPermissionsScreen> {
  int _selectedTab = 0;
  String? _selectedUserId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<UserModel> users = [
    UserModel(
      id: '1',
      name: 'John Smith',
      email: 'john.smith@company.com',
      avatar: 'JS',
      role: 'Admin',
      roleColor: Colors.red,
      status: 'Active',
      lastLogin: '2024-05-21 10:30 AM',
      permissions: [
        UserPermissionModel(
          'View Dashboard',
          'Access main dashboard',
          true,
          true,
        ),
        UserPermissionModel(
          'Manage Users',
          'Add/edit/delete users',
          true,
          true,
        ),
        UserPermissionModel(
          'Manage Roles',
          'Create and modify roles',
          true,
          true,
        ),
        UserPermissionModel('View Reports', 'Access all reports', true, true),
        UserPermissionModel(
          'Export Data',
          'Download data in various formats',
          true,
          true,
        ),
        UserPermissionModel(
          'System Settings',
          'Modify system configuration',
          true,
          true,
        ),
        UserPermissionModel('Audit Logs', 'View system audit logs', true, true),
        UserPermissionModel(
          'Payroll Access',
          'Access payroll system',
          true,
          true,
        ),
      ],
    ),
    UserModel(
      id: '2',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@company.com',
      avatar: 'SJ',
      role: 'Manager',
      roleColor: Colors.blue,
      status: 'Active',
      lastLogin: '2024-05-21 09:15 AM',
      permissions: [
        UserPermissionModel(
          'View Dashboard',
          'Access main dashboard',
          true,
          true,
        ),
        UserPermissionModel(
          'Manage Users',
          'Add/edit team users only',
          true,
          true,
        ),
        UserPermissionModel('Manage Roles', 'View roles only', false, true),
        UserPermissionModel('View Reports', 'Access team reports', true, true),
        UserPermissionModel('Export Data', 'Download team data', true, true),
        UserPermissionModel(
          'System Settings',
          'View settings only',
          true,
          false,
        ),
        UserPermissionModel('Audit Logs', 'View team logs only', false, true),
        UserPermissionModel(
          'Payroll Access',
          'View payroll reports',
          true,
          true,
        ),
      ],
    ),
    UserModel(
      id: '3',
      name: 'Michael Brown',
      email: 'michael.brown@company.com',
      avatar: 'MB',
      role: 'HR Specialist',
      roleColor: Colors.orange,
      status: 'Active',
      lastLogin: '2024-05-20 04:45 PM',
      permissions: [
        UserPermissionModel(
          'View Dashboard',
          'Access main dashboard',
          true,
          true,
        ),
        UserPermissionModel(
          'Manage Users',
          'Manage employee records',
          true,
          true,
        ),
        UserPermissionModel('Manage Roles', 'View roles only', false, false),
        UserPermissionModel('View Reports', 'Access HR reports', true, true),
        UserPermissionModel('Export Data', 'Download HR data', true, true),
        UserPermissionModel(
          'System Settings',
          'Modify HR settings',
          true,
          true,
        ),
        UserPermissionModel('Audit Logs', 'View HR logs', true, true),
        UserPermissionModel(
          'Payroll Access',
          'Full payroll access',
          true,
          true,
        ),
      ],
    ),
    UserModel(
      id: '4',
      name: 'Emily Davis',
      email: 'emily.davis@company.com',
      avatar: 'ED',
      role: 'Employee',
      roleColor: Colors.green,
      status: 'Active',
      lastLogin: '2024-05-21 08:20 AM',
      permissions: [
        UserPermissionModel(
          'View Dashboard',
          'Access main dashboard',
          true,
          true,
        ),
        UserPermissionModel('Manage Users', 'No access', false, false),
        UserPermissionModel('Manage Roles', 'View roles only', false, false),
        UserPermissionModel('View Reports', 'View own reports', true, true),
        UserPermissionModel('Export Data', 'Download own data', true, true),
        UserPermissionModel(
          'System Settings',
          'Modify own settings',
          true,
          true,
        ),
        UserPermissionModel('Audit Logs', 'No access', false, false),
        UserPermissionModel('Payroll Access', 'View own payroll', true, true),
      ],
    ),
    UserModel(
      id: '5',
      name: 'Robert Wilson',
      email: 'robert.wilson@company.com',
      avatar: 'RW',
      role: 'Manager',
      roleColor: Colors.blue,
      status: 'Inactive',
      lastLogin: '2024-05-10 03:30 PM',
      permissions: [
        UserPermissionModel(
          'View Dashboard',
          'Access main dashboard',
          false,
          true,
        ),
        UserPermissionModel('Manage Users', 'No access', false, false),
        UserPermissionModel('Manage Roles', 'View roles only', false, false),
        UserPermissionModel('View Reports', 'View team reports', true, true),
        UserPermissionModel('Export Data', 'Download team data', false, false),
        UserPermissionModel('System Settings', 'No access', false, false),
        UserPermissionModel('Audit Logs', 'No access', false, false),
        UserPermissionModel(
          'Payroll Access',
          'View payroll reports',
          true,
          true,
        ),
      ],
    ),
    UserModel(
      id: '6',
      name: 'Jessica Martinez',
      email: 'jessica.martinez@company.com',
      avatar: 'JM',
      role: 'Employee',
      roleColor: Colors.green,
      status: 'Active',
      lastLogin: '2024-05-21 11:00 AM',
      permissions: [
        UserPermissionModel(
          'View Dashboard',
          'Access main dashboard',
          true,
          true,
        ),
        UserPermissionModel('Manage Users', 'No access', false, false),
        UserPermissionModel('Manage Roles', 'View roles only', false, false),
        UserPermissionModel('View Reports', 'View own reports', true, true),
        UserPermissionModel('Export Data', 'Download own data', true, true),
        UserPermissionModel(
          'System Settings',
          'Modify own settings',
          true,
          true,
        ),
        UserPermissionModel('Audit Logs', 'No access', false, false),
        UserPermissionModel('Payroll Access', 'View own payroll', true, true),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedUserId = users[0].id;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> get filteredUsers {
    if (_searchQuery.isEmpty) return users;
    return users
        .where(
          (user) =>
              user.name.toLowerCase().contains(_searchQuery) ||
              user.email.toLowerCase().contains(_searchQuery) ||
              user.role.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'User Permissions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.indigo),
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
            _selectedTab == 0 ? _buildUsersTab() : _buildPermissionsTab(),
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
                        ? Colors.indigo[50]
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 0
                            ? Colors.indigo
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    'Users',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 0
                          ? Colors.indigo
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
                        ? Colors.indigo[50]
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 1
                            ? Colors.indigo
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
                          ? Colors.indigo
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

  Widget _buildUsersTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, email or role...',
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${filteredUsers.length} users',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          ...filteredUsers.map((user) => _buildUserCard(user)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  Widget _buildUserCard(UserModel user) {
    final isSelected = _selectedUserId == user.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedUserId = user.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: user.roleColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user.avatar,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: user.roleColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: user.status == 'Active'
                                ? Colors.green[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: user.status == 'Active'
                                  ? Colors.green[700]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: user.roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: user.roleColor,
                            ),
                          ),
                        ),
                        Text(
                          user.lastLogin,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Colors.indigo, size: 24),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPermissionsTab() {
    final currentUser = users.firstWhere((u) => u.id == _selectedUserId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: currentUser.roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: currentUser.roleColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: currentUser.roleColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    currentUser.avatar,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: currentUser.roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentUser.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Role: ${currentUser.role}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: currentUser.roleColor,
                        ),
                      ),
                    ],
                  ),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${currentUser.permissions.where((p) => p.isGranted).length}/${currentUser.permissions.length} Granted',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...currentUser.permissions.asMap().entries.map((entry) {
            UserPermissionModel permission = entry.value;
            return _buildUserPermissionItem(permission, currentUser);
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.indigo),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Revoke All',
                    style: TextStyle(
                      color: Colors.indigo,
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
                    backgroundColor: Colors.indigo,
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

  Widget _buildUserPermissionItem(
    UserPermissionModel permission,
    UserModel user,
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
          _buildPermissionToggle(permission),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle(UserPermissionModel permission) {
    return Row(
      children: [
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
              color: permission.isGranted ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
          },
          child: Icon(
            permission.isGranted
                ? Icons.toggle_on_outlined
                : Icons.toggle_off_outlined,
            color: permission.isGranted ? Colors.green : Colors.grey,
            size: 24,
          ),
        ),
      ],
    );
  }
}
class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String role;
  final Color roleColor;
  final String status;
  final String lastLogin;
  final List<UserPermissionModel> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    required this.roleColor,
    required this.status,
    required this.lastLogin,
    required this.permissions,
  });
}
class UserPermissionModel {
  final String name;
  final String description;
  bool isGranted;
  final bool canModify;
  UserPermissionModel(
    this.name,
    this.description,
    this.isGranted,
    this.canModify,
  );
}