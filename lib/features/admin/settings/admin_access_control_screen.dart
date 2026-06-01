import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/features/admin/services/admin_api_service.dart';

class AdminAccessControlScreen extends StatefulWidget {
  const AdminAccessControlScreen({super.key});

  @override
  State<AdminAccessControlScreen> createState() => _AdminAccessControlScreenState();
}

class _AdminAccessControlScreenState extends State<AdminAccessControlScreen> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _selectedRole = 'All Roles';

  static const _roleFilters = ['All Roles', 'Admin', 'Manager', 'Employee'];

  static const _roleColors = {
    'admin': Color(0xFF7C3AED),
    'manager': Color(0xFF0891B2),
    'employee': Color(0xFF36617E),
    'cto': Color(0xFFD97706),
  };

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final data = await AdminApiService.getAllEmployees();
    final employees = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (mounted) {
      setState(() {
        _all = employees;
        _loading = false;
      });
      _applyFilter();
    }
  }

  String _getRole(Map<String, dynamic> e) =>
      (e['role'] ?? e['userType'] ?? 'employee').toString().toLowerCase();

  int _overlayCount(Map<String, dynamic> e) {
    final perms = e['customPermissions'] ?? e['permissionOverlays'];
    if (perms == null) return 0;
    return (perms as List).length;
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    setState(() {
      _filtered = _all.where((e) {
        final name = '${e['firstName'] ?? ''} ${e['lastName'] ?? ''}'.toLowerCase();
        final email = (e['email'] ?? '').toString().toLowerCase();
        final role = _getRole(e);
        final matchSearch = q.isEmpty || name.contains(q) || email.contains(q);
        final matchRole = _selectedRole == 'All Roles' || role == _selectedRole.toLowerCase();
        return matchSearch && matchRole;
      }).toList();
    });
  }

  int get _adminCount => _all.where((e) => _getRole(e) == 'admin').length;
  int get _totalOverlays => _all.fold(0, (sum, e) => sum + _overlayCount(e));

  void _showDetail(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailSheet(user: user, roleColors: _roleColors, getRole: _getRole, overlayCount: _overlayCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (!_loading) _buildStats(),
            _buildSearch(),
            _buildRoleFilter(),
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
                            itemBuilder: (_, i) => _UserCard(
                              user: _filtered[i],
                              getRole: _getRole,
                              overlayCount: _overlayCount,
                              roleColors: _roleColors,
                              onTap: () => _showDetail(_filtered[i]),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: const Icon(Iconsax.arrow_left, size: 20, color: kText),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.key, size: 15, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'User Access Control',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: kText),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Assign roles & manage permissions',
                  style: TextStyle(fontSize: 12, color: kSubText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, color: kText, size: 20),
            onPressed: _fetch,
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _StatPill(
            label: 'Total Profiles',
            value: _all.length.toString(),
            icon: Iconsax.profile_2user,
            color: const Color(0xFF36617E),
          ),
          const SizedBox(width: 10),
          _StatPill(
            label: 'System Admins',
            value: _adminCount.toString(),
            icon: Iconsax.shield_tick,
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(width: 10),
          _StatPill(
            label: 'Overlays',
            value: _totalOverlays.toString(),
            icon: Iconsax.setting_3,
            color: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CrmSearchBar(
        hint: 'Search by name or email…',
        onChanged: (v) {
          _search = v;
          _applyFilter();
        },
      ),
    );
  }

  Widget _buildRoleFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _roleFilters.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final r = _roleFilters[i];
          final selected = _selectedRole == r;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedRole = r);
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
                r,
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
          const Text('No users found', style: TextStyle(fontSize: 16, color: kSubText)),
        ],
      ),
    );
  }
}

// ── Stat pill ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 9, color: kSubText), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── User list card ────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final String Function(Map<String, dynamic>) getRole;
  final int Function(Map<String, dynamic>) overlayCount;
  final Map<String, Color> roleColors;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.getRole,
    required this.overlayCount,
    required this.roleColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    final email = user['email']?.toString() ?? '';
    final role = getRole(user);
    final roleColor = roleColors[role] ?? kPrimary;
    final oCount = overlayCount(user);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            AvatarInitials(name: name.isEmpty ? 'U' : name, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Unknown' : name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(email, style: const TextStyle(fontSize: 11, color: kSubText), overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _RoleBadge(label: role.toUpperCase(), color: roleColor),
                      if (oCount > 0) ...[
                        const SizedBox(width: 6),
                        _RoleBadge(label: '+$oCount OVERLAYS', color: const Color(0xFFD97706)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Iconsax.arrow_right_3, size: 16, color: kSubText),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RoleBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────────────────

class _UserDetailSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, Color> roleColors;
  final String Function(Map<String, dynamic>) getRole;
  final int Function(Map<String, dynamic>) overlayCount;

  const _UserDetailSheet({
    required this.user,
    required this.roleColors,
    required this.getRole,
    required this.overlayCount,
  });

  @override
  Widget build(BuildContext context) {
    final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    final email = user['email']?.toString() ?? '';
    final role = getRole(user);
    final roleColor = roleColors[role] ?? kPrimary;
    final dept = user['department']?.toString() ?? '';
    final designation = user['designation']?.toString() ?? '';
    final oCount = overlayCount(user);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),

            // User header
            Row(
              children: [
                AvatarInitials(name: name.isEmpty ? 'U' : name, radius: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Unknown' : name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText),
                      ),
                      if (designation.isNotEmpty)
                        Text(designation, style: const TextStyle(fontSize: 12, color: kSubText)),
                      if (email.isNotEmpty)
                        Text(email, style: const TextStyle(fontSize: 11, color: kSubText), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: kBorder),
            const SizedBox(height: 16),

            // Security role
            _DetailBlock(
              icon: Iconsax.shield_tick,
              iconColor: roleColor,
              label: 'Security Role',
              child: _RoleBadge(label: role.toUpperCase(), color: roleColor),
            ),
            const SizedBox(height: 14),

            if (dept.isNotEmpty) ...[
              _DetailBlock(
                icon: Iconsax.building,
                iconColor: kSubText,
                label: 'Department',
                child: Text(dept, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
              ),
              const SizedBox(height: 14),
            ],

            // Permission overlays card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.setting_3, size: 16, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Permission Overlays', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                        const SizedBox(height: 2),
                        Text(
                          oCount == 0
                              ? 'No custom overlays configured'
                              : '$oCount custom overlay${oCount > 1 ? 's' : ''} active',
                          style: const TextStyle(fontSize: 11, color: kSubText),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$oCount',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
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

class _DetailBlock extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;
  const _DetailBlock({required this.icon, required this.iconColor, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: kSubText, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ],
    );
  }
}
