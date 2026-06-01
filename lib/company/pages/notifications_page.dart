import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> _notifications = [
    {'title': 'Difmo Pvt Ltd: New Work From Home Request', 'body': 'test has requested Work From Home from 2026-06-01 to 2026-06-03.', 'time': '1 Jun 2026, 04:29 pm', 'unread': true},
    {'title': 'Difmo Pvt Ltd: Leave Request Approved', 'body': 'Leave request for test has been approved.', 'time': '1 Jun 2026, 03:48 pm', 'unread': true},
    {'title': 'Difmo Pvt Ltd: New Leave Request', 'body': 'test has applied for leave from 2026-06-02 to 2026-06-04.', 'time': '1 Jun 2026, 03:47 pm', 'unread': true},
    {'title': 'Difmo Pvt Ltd: Leave Request Approved', 'body': 'Leave request for test has been approved.', 'time': '29 May 2026, 12:44 pm', 'unread': true},
    {'title': 'Difmo Pvt Ltd: Attendance Alert', 'body': 'keshav pathak checked in late at 10:17 AM.', 'time': '28 May 2026, 10:20 am', 'unread': false},
    {'title': 'Difmo Pvt Ltd: New Leave Request', 'body': 'Rajdeep Maurya has applied for sick leave.', 'time': '26 May 2026, 11:00 am', 'unread': false},
  ];

  int get _unreadCount => _notifications.where((n) => n['unread'] == true).length;

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
        title: const Text('My Notifications', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() { for (var n in _notifications) n['unread'] = false; }),
            icon: const Icon(Icons.done_all, size: 16, color: kPrimary),
            label: const Text('Mark all', style: TextStyle(fontSize: 12, color: kPrimary)),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kBorder)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                Expanded(child: Text('Stay on top of alerts, payroll updates, and workflow activity.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.5))),
                if (_unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('$_unreadCount unread', style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(right: 16, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _notifications.clear()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 14, color: Colors.red.shade400),
                      const SizedBox(width: 4),
                      Text('Clear inbox', style: TextStyle(fontSize: 12, color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _notifications.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.notifications_none_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Inbox is empty', style: TextStyle(fontSize: 15, color: Colors.grey.shade400)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, i) {
                      final n = _notifications[i];
                      final unread = n['unread'] == true;
                      return GestureDetector(
                        onTap: () => setState(() => _notifications[i]['unread'] = false),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: unread ? kPrimary.withValues(alpha: 0.04) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: unread ? kPrimary.withValues(alpha: 0.2) : kBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: unread ? kPrimary.withValues(alpha: 0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.notifications_outlined, color: unread ? kPrimary : kSubText, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(child: Text(n['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kText))),
                                      if (unread) Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                        child: const Text('Unread', style: TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w600)),
                                      ),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(n['body'], style: const TextStyle(fontSize: 12, color: kSubText, height: 1.4)),
                                    const SizedBox(height: 6),
                                    Text(n['time'], style: const TextStyle(fontSize: 11, color: kSubText)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
