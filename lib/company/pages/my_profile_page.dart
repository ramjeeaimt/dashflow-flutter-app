import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  final _nameCtrl = TextEditingController(text: 'Pritam Sharma');
  final _emailCtrl = TextEditingController(text: 'pritamcodeservir@gmail.com');
  final _phoneCtrl = TextEditingController(text: '+91 9519202509');
  final _deptCtrl = TextEditingController(text: 'Engineering');
  final _positionCtrl = TextEditingController(text: 'CTO');
  final _empIdCtrl = TextEditingController(text: 'DIF0029');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    _positionCtrl.dispose();
    _empIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kText),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('My Profile',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              }
              setState(() => _isEditing = !_isEditing);
            },
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined,
                size: 16, color: kPrimary),
            label: Text(_isEditing ? 'Save' : 'Edit',
                style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: kBorder)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: kPrimary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('PS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: kPrimary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Pritam Sharma',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kText)),
                  const SizedBox(height: 4),
                  const Text('Admin Workspace',
                      style: TextStyle(fontSize: 13, color: kSubText)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _badge('MANAGER', Colors.blue),
                      _badge('CTO', Colors.purple),
                      _badge('EMPLOYEE', Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            // Stats row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(child: _quickStat('Dept', 'Engineering')),
                  Container(width: 1, height: 40, color: kBorder),
                  Expanded(child: _quickStat('ID', 'DIF0029')),
                  Container(width: 1, height: 40, color: kBorder),
                  Expanded(child: _quickStat('Since', 'May 1, 2026')),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Personal info card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _infoCard(
                title: 'Personal Information',
                icon: Icons.person_outline,
                children: [
                  _fieldRow('Full Name', _nameCtrl, Icons.person_outline),
                  _fieldRow('Email Address', _emailCtrl, Icons.mail_outline),
                  _fieldRow('Phone Number', _phoneCtrl, Icons.phone_outlined),
                ],
              ),
            ),

            // Work info card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _infoCard(
                title: 'Work Information',
                icon: Icons.work_outline,
                children: [
                  _fieldRow('Employee ID', _empIdCtrl, Icons.badge_outlined,
                      readOnly: true),
                  _fieldRow('Department', _deptCtrl, Icons.layers_outlined,
                      readOnly: true),
                  _fieldRow('Position / Role', _positionCtrl,
                      Icons.star_outline,
                      readOnly: true),
                ],
              ),
            ),

            // Security card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _infoCard(
                title: 'Security',
                icon: Icons.security_outlined,
                children: [
                  _securityTile(Icons.lock_outline, 'Change Password',
                      'Last changed 30 days ago', () {}),
                  _securityTile(Icons.devices_outlined, 'Active Sessions',
                      'Manage your logged-in devices', () {}),
                  _securityTile(Icons.notifications_outlined,
                      'Notification Preferences',
                      'Manage alerts and emails', () {}),
                ],
              ),
            ),

            // Danger zone
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Actions',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: kText)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.logout, size: 16,
                            color: Colors.red.shade400),
                        label: Text('Sign Out',
                            style: TextStyle(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _quickStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: kText)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: kSubText)),
      ],
    );
  }

  Widget _infoCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: kPrimary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kText)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldRow(String label, TextEditingController ctrl, IconData icon,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: kSubText,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            enabled: _isEditing && !readOnly,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 16, color: kSubText),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kBorder)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kPrimary)),
              filled: readOnly || !_isEditing,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: TextStyle(
                fontSize: 13,
                color:
                    (_isEditing && !readOnly) ? kText : Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _securityTile(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: kBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: kSubText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kText)),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 11, color: kSubText)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: kSubText),
          ],
        ),
      ),
    );
  }
}
