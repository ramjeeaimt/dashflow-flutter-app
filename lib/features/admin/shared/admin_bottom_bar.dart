import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dashflow/features/admin/dashboard/admin_home_screen.dart';
import 'package:dashflow/features/admin/employees/admin_employees_screen.dart';
import 'package:dashflow/features/admin/leaves/admin_leaves_screen.dart';
import 'package:dashflow/features/admin/attendance/admin_attendance_screen.dart';
import 'package:dashflow/features/profile/pages/profile.dart';

class AdminBottomBarWidget extends StatefulWidget {
  const AdminBottomBarWidget({super.key});

  @override
  State<AdminBottomBarWidget> createState() => _AdminBottomBarWidgetState();
}

class _AdminBottomBarWidgetState extends State<AdminBottomBarWidget> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    AdminHomeScreen(),
    AdminEmployeesScreen(),
    AdminLeavesScreen(),
    AdminAttendanceScreen(),
    ProfilePage(),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _onBackPressed() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF36617E).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.logout, color: Color(0xFF36617E), size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Exit App?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to exit\nthe application?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF36617E), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF36617E), fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36617E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if ((shouldExit ?? false) && mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Iconsax.home, activeIcon: Iconsax.home_15, label: 'Home', index: 0, selected: _selectedIndex, onTap: _onNavTapped),
              _NavItem(icon: Iconsax.profile_2user, activeIcon: Iconsax.profile_2user5, label: 'Employees', index: 1, selected: _selectedIndex, onTap: _onNavTapped),
              _NavItem(icon: Iconsax.note, activeIcon: Iconsax.note5, label: 'Requests', index: 2, selected: _selectedIndex, onTap: _onNavTapped),
              _NavItem(icon: Iconsax.clock, activeIcon: Iconsax.clock5, label: 'Attendance', index: 3, selected: _selectedIndex, onTap: _onNavTapped),
              _NavItem(icon: Iconsax.profile_circle, activeIcon: Iconsax.profile_circle5, label: 'Profile', index: 4, selected: _selectedIndex, onTap: _onNavTapped),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF36617E).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF36617E) : Colors.grey.shade400,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF36617E),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
