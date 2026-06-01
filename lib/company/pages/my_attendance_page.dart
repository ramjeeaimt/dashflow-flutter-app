import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class MyAttendancePage extends StatefulWidget {
  const MyAttendancePage({super.key});
  @override
  State<MyAttendancePage> createState() => _MyAttendancePageState();
}

class _MyAttendancePageState extends State<MyAttendancePage> {
  String _month = 'June';
  String _year = '2026';
  String _tab = 'ATTENDANCE LOGS';
  final _months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  final _wfhRequests = [{'from': '2026-06-01', 'to': '2026-06-03', 'status': 'PENDING', 'reason': 'Work from home request'}];

  Future<void> _pickDate(bool isFrom) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kText), onPressed: () => Navigator.maybePop(context)),
        title: const Text('My Attendance', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
        actions: [
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.home_work_outlined, size: 16, color: kPrimary), label: const Text('WFH', style: TextStyle(fontSize: 11, color: kPrimary))),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined, size: 16, color: kText), label: const Text('Export', style: TextStyle(fontSize: 11, color: kText))),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kBorder)),
      ),
      body: Column(children: [
        // Period picker
        Container(color: Colors.white, padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Text('Period:', style: TextStyle(fontSize: 13, color: kSubText)),
            const SizedBox(width: 12),
            Expanded(child: _drop(_month, _months, (v) => setState(() => _month = v!))),
            const SizedBox(width: 10),
            Expanded(child: _drop(_year, ['2024','2025','2026'], (v) => setState(() => _year = v!))),
          ])),
        // Stats
        Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(children: [
            Expanded(child: _stat('MONTHLY PRESENT', '0', 'Days on-time', Colors.green)),
            const SizedBox(width: 10),
            Expanded(child: _stat('LATE ARRIVALS', '0', 'After 10:00 AM', Colors.orange)),
            const SizedBox(width: 10),
            Expanded(child: _stat('TOTAL HOURS', '0.0', 'Working time', Colors.purple)),
            const SizedBox(width: 10),
            Expanded(child: _stat('WORKING DAYS', '0', 'In this month', Colors.blue)),
          ])),
        // Tab
        Container(color: Colors.white,
          child: Row(children: ['ATTENDANCE LOGS', 'WFH REQUESTS'].map((t) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = t),
              child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab == t ? kPrimary : Colors.transparent, width: 2))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(t == 'ATTENDANCE LOGS' ? Icons.calendar_month_outlined : Icons.home_work_outlined, size: 14, color: _tab == t ? kPrimary : kSubText),
                  const SizedBox(width: 6),
                  Text(t, style: TextStyle(fontSize: 11, fontWeight: _tab == t ? FontWeight.bold : FontWeight.normal, color: _tab == t ? kPrimary : kSubText)),
                ]),
              ),
            ))).toList())),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16),
          child: _tab == 'ATTENDANCE LOGS' ? _buildLogs() : _buildWFH())),
      ]),
    );
  }

  Widget _buildLogs() {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Column(children: [
        Row(children: const [
          Expanded(flex: 2, child: Text('LOG DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kSubText, letterSpacing: 0.5))),
          Expanded(flex: 2, child: Text('SHIFT STATUS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kSubText, letterSpacing: 0.5))),
          Expanded(flex: 2, child: Text('TIMING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kSubText, letterSpacing: 0.5))),
          Expanded(child: Text('DURATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kSubText, letterSpacing: 0.5))),
        ]),
        const SizedBox(height: 30),
        Text('No attendance history found for this period.', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
      ]));
  }

  Widget _buildWFH() {
    return Column(children: [
      ..._wfhRequests.map((w) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
        child: Row(children: [
          const Icon(Icons.home_work_outlined, color: kPrimary, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${w["from"]} to ${w["to"]}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
            Text(w['reason']!, style: const TextStyle(fontSize: 12, color: kSubText)),
          ])),
          StatusBadge(label: w['status']!, color: Colors.orange),
        ]))),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity,
        child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 18), label: const Text('New WFH Request'),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
    ]);
  }

  Widget _stat(String l, String v, String s, Color c) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)),
      Text(l, style: const TextStyle(fontSize: 8, color: kSubText, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      Text(s, style: const TextStyle(fontSize: 8, color: kSubText), textAlign: TextAlign.center),
    ]));

  Widget _drop(String v, List<String> items, ValueChanged<String?> cb) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
    child: DropdownButton<String>(value: v, isExpanded: true, underline: const SizedBox(), style: const TextStyle(fontSize: 13, color: kText),
      items: items.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: cb));
}
