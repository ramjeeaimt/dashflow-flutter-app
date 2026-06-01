import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});
  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  String _search = '';
  String _filter = 'Active';

  final List<Map<String, dynamic>> _emps = [
    {'name': 'Ankur Gautam', 'email': 'ankgau8714@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'May 8, 2026', 'id': 'DIF0022'},
    {'name': 'Harsh jaiswal', 'email': 'harshjaiswal833@gmail.com', 'dept': 'Human Resources', 'status': 'Active', 'hired': 'Apr 23, 2026', 'id': 'DIF0010'},
    {'name': 'Simran Kumari', 'email': 'kumarisimran2018@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'Apr 24, 2026', 'id': 'DIF0015'},
    {'name': 'Soni Verma', 'email': 'sonivermasoni55@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'Apr 30, 2026', 'id': 'DIF0017'},
    {'name': 'anushka pandit', 'email': 'anushk2026a@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'Apr 23, 2026', 'id': 'DIF0013'},
    {'name': 'keshav pathak', 'email': 'keshav2025p@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'Apr 23, 2026', 'id': 'DIF0020'},
    {'name': 'pritam kumar', 'email': 'pritamcodeservir@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'May 1, 2026', 'id': 'DIF0029'},
    {'name': 'sadhna kumari', 'email': 'sadhanachaudhary421@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'Apr 23, 2026', 'id': 'DIF0011'},
    {'name': 'test user', 'email': 'hackswift165@gmail.com', 'dept': 'Engineering', 'status': 'Active', 'hired': 'May 26, 2026', 'id': 'DIF0035'},
    {'name': 'test user2', 'email': 'cvfgbhnfgh@gmail.com', 'dept': 'Engineering', 'status': 'In-Active', 'hired': 'May 26, 2026', 'id': 'DIF0036'},
  ];

  List<Map<String, dynamic>> get _filtered => _emps.where((e) {
    final ms = _search.isEmpty || e['name'].toString().toLowerCase().contains(_search.toLowerCase()) || e['email'].toString().toLowerCase().contains(_search.toLowerCase());
    final mf = _filter == 'All' || e['status'] == _filter;
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
            child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kBorder)),
      ),
      body: Column(children: [
        // Stats
        Container(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            _pill('${_emps.length}', 'Total', Colors.grey), const SizedBox(width: 14),
            _pill('${_emps.where((e) => e["status"] == "Active").length}', 'Active', Colors.green), const SizedBox(width: 14),
            _pill('0', 'Pending', Colors.orange), const SizedBox(width: 14),
            _pill('${_emps.where((e) => e["status"] == "In-Active").length}', 'Inactive', Colors.grey),
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
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final e = _filtered[i];
            final active = e['status'] == 'Active';
            return Container(
              margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
              child: Row(children: [
                AvatarInitials(name: e['name'].toString(), radius: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e['name'].toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
                  Text(e['email'].toString(), style: const TextStyle(fontSize: 11, color: kSubText)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Text(e['dept'].toString(), style: const TextStyle(fontSize: 10, color: kSubText))),
                    const SizedBox(width: 6),
                    Text('Hired ${e["hired"]}', style: const TextStyle(fontSize: 10, color: kSubText)),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusBadge(label: e['status'].toString(), color: active ? Colors.green : Colors.grey),
                  const SizedBox(height: 8),
                  Row(children: [
                    GestureDetector(onTap: () {}, child: const Icon(Icons.visibility_outlined, size: 18, color: kSubText)),
                    const SizedBox(width: 8),
                    GestureDetector(onTap: () {}, child: const Icon(Icons.edit_outlined, size: 18, color: kSubText)),
                    const SizedBox(width: 8),
                    GestureDetector(onTap: () {}, child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300)),
                  ]),
                ]),
              ]),
            );
          })),
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
