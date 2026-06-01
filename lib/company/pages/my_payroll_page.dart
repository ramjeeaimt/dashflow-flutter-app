import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class MyPayrollPage extends StatefulWidget {
  const MyPayrollPage({super.key});
  @override
  State<MyPayrollPage> createState() => _MyPayrollPageState();
}

class _MyPayrollPageState extends State<MyPayrollPage> {
  String _activeTab = 'ALL';
  String _selectedMonth = 'All Months';
  final _months = ['All Months','January','February','March','April','May','June','July','August','September','October','November','December'];
  final List<Map<String, dynamic>> _payrolls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(context, 'Payroll History'),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome, Employee. View your earnings summary.', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _statCard('YEAR TO DATE', '₹0', Icons.account_balance_wallet_outlined, kPrimary)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('LAST PAYOUT', '₹0', Icons.description_outlined, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('PENDING REVIEW', '0', Icons.timelapse_outlined, Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('CURRENT YEAR', '2026', Icons.calendar_today_outlined, Colors.purple)),
            ]),
          ])),
        Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(children: [
            Container(decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.all(4),
              child: Row(children: ['ALL','PAID','PENDING'].map((t) => Expanded(child: GestureDetector(
                onTap: () => setState(() => _activeTab = t),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: _activeTab == t ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(t, style: TextStyle(fontSize: 12, fontWeight: _activeTab == t ? FontWeight.bold : FontWeight.normal, color: _activeTab == t ? kPrimary : kSubText))))
              ).toList())),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
              child: DropdownButton<String>(value: _selectedMonth, isExpanded: true, underline: const SizedBox(), style: const TextStyle(fontSize: 13, color: kText),
                items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => _selectedMonth = v!))),
          ])),
        Expanded(child: _payrolls.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No payroll records match these filters.', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
            ]))
          : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _payrolls.length,
              itemBuilder: (_, i) {
                final p = _payrolls[i];
                return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.receipt_long_outlined, color: kPrimary, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p['period'] ?? '--', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText)),
                      Text('₹${p["amount"]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimary)),
                    ])),
                    StatusBadge(label: p['status'] ?? '--', color: p['status'] == 'PAID' ? Colors.green : Colors.orange),
                  ]));
              })),
      ]),
    );
  }

  Widget _statCard(String l, String v, IconData icon, Color c) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Icon(icon, color: c, size: 18), const SizedBox(height: 4),
      Text(v, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c), textAlign: TextAlign.center),
      Text(l, style: const TextStyle(fontSize: 8, color: kSubText, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
    ]));
}
