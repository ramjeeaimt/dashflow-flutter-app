import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class MyLeavesPage extends StatefulWidget {
  const MyLeavesPage({super.key});
  @override
  State<MyLeavesPage> createState() => _MyLeavesPageState();
}

class _MyLeavesPageState extends State<MyLeavesPage> {
  String _leaveType = 'Casual Leave';
  DateTime? _fromDate;
  DateTime? _toDate;
  final _noteCtrl = TextEditingController();
  String _filterStatus = 'All Status';
  final List<Map<String, dynamic>> _leaves = [];
  final _leaveTypes = ['Casual Leave', 'Sick Leave', 'Annual Leave', 'Emergency Leave'];
  final _statusFilters = ['All Status', 'Approved', 'Pending', 'Rejected'];

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  Future<void> _pick(bool isFrom) async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2027),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: kPrimary)), child: child!));
    if (d != null) setState(() => isFrom ? _fromDate = d : _toDate = d);
  }

  void _submit() {
    if (_fromDate == null || _toDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select dates'), behavior: SnackBarBehavior.floating)); return; }
    setState(() {
      _leaves.insert(0, {'type': _leaveType, 'from': _fromDate!.toString().substring(0, 10), 'to': _toDate!.toString().substring(0, 10), 'note': _noteCtrl.text, 'status': 'Pending'});
      _fromDate = null; _toDate = null; _noteCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request submitted!'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final total = _leaves.length;
    final approved = _leaves.where((l) => l['status'] == 'Approved').length;
    final pending = _leaves.where((l) => l['status'] == 'Pending').length;
    final rejected = _leaves.where((l) => l['status'] == 'Rejected').length;
    final filtered = _leaves.where((l) => _filterStatus == 'All Status' || l['status'] == _filterStatus).toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(context, 'My Leave Dashboard'),
      body: SingleChildScrollView(child: Column(children: [
        // Stats
        Container(color: Colors.white, padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: _stat('TOTAL', '$total', kText)),
            Expanded(child: _stat('APPROVED', '$approved', Colors.green)),
            Expanded(child: _stat('PENDING', '$pending', Colors.orange)),
            Expanded(child: _stat('REJECTED', '$rejected', Colors.red)),
          ])),
        // Request form
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('REQUEST LEAVE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kText, letterSpacing: 0.5)),
            const SizedBox(height: 14),
            const Text('CATEGORY', style: TextStyle(fontSize: 10, color: kSubText, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
              child: DropdownButton<String>(value: _leaveType, isExpanded: true, underline: const SizedBox(), style: const TextStyle(fontSize: 14, color: kText),
                items: _leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _leaveType = v!))),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('FROM', style: TextStyle(fontSize: 10, color: kSubText, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                GestureDetector(onTap: () => _pick(true),
                  child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: kSubText), const SizedBox(width: 8),
                      Text(_fromDate != null ? _fromDate!.toString().substring(0, 10) : 'dd-mm-yyyy', style: TextStyle(fontSize: 13, color: _fromDate != null ? kText : kSubText)),
                    ]))),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TO', style: TextStyle(fontSize: 10, color: kSubText, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                GestureDetector(onTap: () => _pick(false),
                  child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: kSubText), const SizedBox(width: 8),
                      Text(_toDate != null ? _toDate!.toString().substring(0, 10) : 'dd-mm-yyyy', style: TextStyle(fontSize: 13, color: _toDate != null ? kText : kSubText)),
                    ]))),
              ])),
            ]),
            const SizedBox(height: 14),
            const Text('NOTE', style: TextStyle(fontSize: 10, color: kSubText, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            TextField(controller: _noteCtrl, maxLines: 3,
              decoration: InputDecoration(hintText: 'Type your reason...', hintStyle: const TextStyle(color: kSubText, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary)),
                contentPadding: const EdgeInsets.all(12))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F2937), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('SUBMIT APPLICATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)))),
          ])),
        // History
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(children: [
            Row(children: [
              Expanded(child: CrmSearchBar(hint: 'Search by reason or type...', onChanged: (_) {})),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
                child: DropdownButton<String>(value: _filterStatus, underline: const SizedBox(), style: const TextStyle(fontSize: 12, color: kText),
                  items: _statusFilters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _filterStatus = v!))),
            ]),
            const SizedBox(height: 12),
            filtered.isEmpty
                ? Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                    child: Center(child: Text('NO MATCHING RECORDS', style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w600, letterSpacing: 1))))
                : Column(children: filtered.map((l) {
                    Color sc;
                    switch (l['status']) { case 'Approved': sc = Colors.green; break; case 'Rejected': sc = Colors.red; break; default: sc = Colors.orange; }
                    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.calendar_month_outlined, color: kPrimary, size: 20)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l['type'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
                          Text('${l["from"]} → ${l["to"]}', style: const TextStyle(fontSize: 12, color: kSubText)),
                        ])),
                        StatusBadge(label: l['status'], color: sc),
                      ]));
                  }).toList()),
          ])),
      ])),
    );
  }

  Widget _stat(String l, String v, Color c) => Container(margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)),
      Text(l, style: const TextStyle(fontSize: 9, color: kSubText, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
    ]));
}
