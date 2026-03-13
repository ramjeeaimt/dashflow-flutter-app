import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_application_difmo/features/dashboard/pages/homepage.dart';
import 'package:flutter_application_difmo/features/activities/pages/activity.dart';
import 'package:flutter_application_difmo/features/projects/pages/projects_tab.dart';
import 'package:flutter_application_difmo/features/profile/pages/profile.dart';

class BottomBarWidget extends StatefulWidget {
  const BottomBarWidget({super.key});

  @override
  State<BottomBarWidget> createState() => _BottomBarWidgetState();
}

class _BottomBarWidgetState extends State<BottomBarWidget> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const DashboardPage(),
    ActivityPage(),
    const ProjectsTab(),
    const ProfilePage(),
  ];

  void onNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF36617E),
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: onNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            activeIcon: Icon(Iconsax.home5),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.clock),
            activeIcon: Icon(Iconsax.clock5),
            label: "Activity",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.folder_2),
            activeIcon: Icon(Iconsax.folder_25),
            label: "Projects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle),
            activeIcon: Icon(Iconsax.profile_circle5),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
