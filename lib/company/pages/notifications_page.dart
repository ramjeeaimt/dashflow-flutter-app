import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> _notifications = [];
  Set<String> _readIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedReadIds = prefs.getStringList('read_notification_ids') ?? [];
      _readIds = savedReadIds.toSet();

      final list = await ApiService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsRead();
      final prefs = await SharedPreferences.getInstance();
      final allIds = _notifications.map((n) => n['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();
      await prefs.setStringList('read_notification_ids', allIds);
      if (mounted) {
        setState(() {
          _readIds.addAll(allIds);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark all as read: $e')),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    try {
      await ApiService.clearNotifications();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('read_notification_ids');
      if (mounted) {
        setState(() {
          _notifications.clear();
          _readIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inbox cleared successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear inbox: $e')),
        );
      }
    }
  }

  Future<void> _markSingleRead(String id) async {
    if (_readIds.contains(id)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _readIds.add(id);
      });
      await prefs.setStringList('read_notification_ids', _readIds.toList());
    } catch (e) {
      debugPrint('Error marking single read: $e');
    }
  }

  int get _unreadCount => _notifications.where((n) {
    final id = n['id']?.toString() ?? '';
    return !_readIds.contains(id);
  }).length;

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('d MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
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
        title: const Text('My Notifications', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
        actions: [
          TextButton.icon(
            onPressed: _isLoading || _notifications.isEmpty ? null : _markAllAsRead,
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
                if (!_isLoading && _unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('$_unreadCount unread', style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          if (!_isLoading && _notifications.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(right: 16, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _clearAll,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : _notifications.isEmpty
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
                          final id = n['id']?.toString() ?? '';
                          final unread = !_readIds.contains(id);
                          final title = (n['title'] ?? '').toString();
                          final body = (n['message'] ?? n['body'] ?? '').toString();
                          final timeStr = _formatDateTime(n['createdAt'] ?? n['time']);

                          return GestureDetector(
                            onTap: () => _markSingleRead(id),
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
                                          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kText))),
                                          if (unread) Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                            child: const Text('Unread', style: TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w600)),
                                          ),
                                        ]),
                                        const SizedBox(height: 4),
                                        Text(body, style: const TextStyle(fontSize: 12, color: kSubText, height: 1.4)),
                                        const SizedBox(height: 6),
                                        Text(timeStr, style: const TextStyle(fontSize: 11, color: kSubText)),
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
