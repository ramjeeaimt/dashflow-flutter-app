import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:dashflow/company/pages/add_employee_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});
  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  String _search = '';
  String _filter = 'All';
  List<dynamic> _emps = [];
  bool _isLoading = true;
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        _companyId = user['company']?['id']?.toString();
      }

      final list = await ApiService.getEmployees(companyId: _companyId);
      if (mounted) {
        setState(() {
          _emps = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load employees: $e')),
        );
      }
    }
  }

  Future<void> _deleteEmp(String id) async {
    try {
      await ApiService.deleteEmployee(id);
      _loadEmployees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee deleted successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete employee: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<dynamic> get _filtered => _emps.where((e) {
    final name = (e['user']?['name'] ?? e['name'] ?? '').toString().toLowerCase();
    final email = (e['user']?['email'] ?? e['email'] ?? '').toString().toLowerCase();
    final ms = _search.isEmpty || name.contains(_search.toLowerCase()) || email.contains(_search.toLowerCase());
    
    final status = (e['status'] ?? 'Active').toString().toLowerCase();
    final filterLower = _filter.toLowerCase();
    
    // Normalize mapping
    String displayFilter = filterLower;
    if (filterLower == 'in-active') displayFilter = 'inactive';
    
    final mf = _filter == 'All' || status == displayFilter || (status == 'in-active' && displayFilter == 'inactive');
    return ms && mf;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kText), onPressed: () => Navigator.maybePop(context)),
        title: const Text('Employee Management', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
        actions: [
          Container(margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEmployeePage()),
                );
                if (result != null) {
                  _loadEmployees();
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              )
            )
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kBorder)),
      ),
      body: Column(children: [
        // Stats
        Container(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            _pill('${_emps.length}', 'Total', Colors.grey), const SizedBox(width: 14),
            _pill('${_emps.where((e) => (e["status"]?.toString().toLowerCase() == "active")).length}', 'Active', Colors.green), const SizedBox(width: 14),
            _pill('${_emps.where((e) => (e["status"]?.toString().toLowerCase() == "pending")).length}', 'Pending', Colors.orange), const SizedBox(width: 14),
            _pill('${_emps.where((e) => (e["status"]?.toString().toLowerCase() == "inactive" || e["status"]?.toString().toLowerCase() == "in-active")).length}', 'Inactive', Colors.grey),
          ])),
        // Search & filter
        Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(children: [
            CrmSearchBar(hint: 'Search by name, email, or ID...', onChanged: (v) => setState(() => _search = v)),
            const SizedBox(height: 10),
            SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: Row(children: ['All', 'Active', 'In-Active', 'Terminated'].map((s) =>
                Padding(padding: const EdgeInsets.only(right: 8),
                  child: CrmTabButton(label: s, selected: _filter == s, onTap: () => setState(() => _filter = s)))).toList())),
          ])),
        // List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('No employees found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final e = _filtered[i];
                        final name = (e['user']?['name'] ?? e['name'] ?? '').toString();
                        final email = (e['user']?['email'] ?? e['email'] ?? '').toString();
                        final dept = (e['department']?['name'] ?? e['dept'] ?? 'Unassigned').toString();
                        final statusStr = (e['status'] ?? 'Active').toString();
                        final active = statusStr.toLowerCase() == 'active';
                        final hired = (e['hireDate'] ?? e['hired'] ?? '').toString();
                        final id = e['id']?.toString() ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
                          child: Row(children: [
                            AvatarInitials(name: name, radius: 22),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
                              Text(email, style: const TextStyle(fontSize: 11, color: kSubText)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                  child: Text(dept, style: const TextStyle(fontSize: 10, color: kSubText))),
                                const SizedBox(width: 6),
                                if (hired.isNotEmpty)
                                  Text('Hired ${hired.contains("T") ? hired.split("T")[0] : hired}', style: const TextStyle(fontSize: 10, color: kSubText)),
                              ]),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              StatusBadge(label: statusStr, color: active ? Colors.green : Colors.grey),
                              const SizedBox(height: 8),
                              Row(children: [
                                GestureDetector(
                                  onTap: () {
                                    // Visualise employee details if desired
                                  },
                                  child: const Icon(Icons.visibility_outlined, size: 18, color: kSubText)
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    // Edit employee if desired
                                  },
                                  child: const Icon(Icons.edit_outlined, size: 18, color: kSubText)
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: const Text('Delete Employee', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: Text('Are you sure you want to delete $name? This cannot be undone.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: kSubText))),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _deleteEmp(id);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300)
                                ),
                              ]),
                            ]),
                          ]),
                        );
                      }
                    ),
        ),
      ]),
    );
  }

  Widget _pill(String v, String l, Color c) => Column(children: [
    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
      const SizedBox(width: 4),
      Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    ]),
    Text(l, style: const TextStyle(fontSize: 10, color: kSubText)),
  ]);
}
