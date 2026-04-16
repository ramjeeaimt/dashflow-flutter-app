import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/features/auth/pages/login_screen.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userRole = "Employee";
  String department = "IT Department";
  String employeeId = "---";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        setState(() {
          userName = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
          if (userName.isEmpty) userName = "User";
          
          if (user['roles'] != null && user['roles'].isNotEmpty) {
            userRole = user['roles'][0]['name'] ?? "Employee";
          }
          
          // Try to get department from user data if it exists
          if (user['department'] != null) {
            department = user['department']['name'] ?? "IT Department";
          } else if (user['branch'] != null) {
             department = user['branch']['name'] ?? "IT Department";
          }

          employeeId = user['employeeId'] ?? user['id']?.toString() ?? "---";
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Identity Hub
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Stack(
                     alignment: Alignment.bottomRight,
                     children: [
                       const CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage('assets/images/ranjeet.jpg'), // Default user image
                          backgroundColor: Colors.grey,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF36617E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)
                          ),
                          child: const Icon(Iconsax.camera, color: Colors.white, size: 16),
                        )
                     ],
                   ),
                  const SizedBox(height: 15),
                  Text(
                    isLoading ? "Loading..." : userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoading ? "Fetching details..." : '$userRole | $department',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF36617E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLoading ? "---" : 'EMP ID: $employeeId', 
                      style: const TextStyle(color: Color(0xFF36617E), fontWeight: FontWeight.bold)
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Quick Links Hub
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Quick Links",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1F2937)),
              ),
            ),
            const SizedBox(height: 10),
            
            _buildActionItem(
              context,
              icon: Iconsax.receipt_2,
              title: "My Payslip",
              subtitle: "View and download your salary slips",
              iconColor: Colors.blue.shade600,
            ),
            _buildActionItem(
              context,
              icon: Iconsax.archive,
              title: "My Archives",
              subtitle: "Past documents and records",
              iconColor: Colors.purple.shade500,
            ),

            const SizedBox(height: 30),

            // Security Hub
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Security Settings",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1F2937)),
              ),
            ),
            const SizedBox(height: 10),

             _buildActionItem(
              context,
              icon: Iconsax.lock,
              title: "Password Reset",
              subtitle: "Change or update your password",
              iconColor: Colors.orange.shade500,
            ),
             _buildActionItem(
              context,
              icon: Iconsax.finger_scan,
              title: "Biometric Login",
               subtitle: "Enable Face ID or Fingerprint",
              iconColor: Colors.green.shade500,
              trailing: Switch(
                value: true, 
                onChanged: (val) {},
                activeThumbColor: const Color(0xFF36617E),
              )
            ),

            const SizedBox(height: 30),

            // Log Out
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Iconsax.logout),
                    SizedBox(width: 8),
                    Text(
                      'Log Out securely',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.04),
             blurRadius: 10,
             offset: const Offset(0, 4)
           )
        ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1F2937))),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          if (trailing == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Routing to $title...")));
          }
        },
      ),
    );
  }
}
