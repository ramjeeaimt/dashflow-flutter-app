import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:dashflow/core/api/api_service.dart';
import '../models/wfh_model.dart';
import 'new_wfh_screen.dart';

class WfhScreen extends StatefulWidget {
  const WfhScreen({super.key});

  @override
  State<WfhScreen> createState() => _WfhScreenState();
}

class _WfhScreenState extends State<WfhScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<WfhRequestModel> _allWfhRequests = [];
  bool _isLoading = true;
  String? _employeeId;
  String _userRole = "Employee";
  String _userName = "Employee";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadUserAndRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        _employeeId = user['employeeId'] ?? user['id']?.toString() ?? user['_id']?.toString();
        _userName = user['name'] ?? "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
        if (_userName.isEmpty) _userName = "Employee";

        if (user['roles'] != null) {
          if (user['roles'] is List && user['roles'].isNotEmpty) {
            final firstRole = user['roles'][0];
            if (firstRole is Map) {
              _userRole = firstRole['name'] ?? "Employee";
            } else {
              _userRole = firstRole.toString();
            }
          } else if (user['roles'] is String) {
            _userRole = user['roles'];
          }
        }
      }

      await _fetchWfhRequests();
    } catch (e) {
      debugPrint('Error loading user/requests: $e');
      setState(() => _isLoading = false);
    }
  }

  bool get _isAdminOrManager {
    final role = _userRole.toLowerCase();
    return role.contains('admin') || role.contains('manager');
  }

  Future<void> _fetchWfhRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getWfhRequests();
      setState(() {
        _allWfhRequests.clear();
        _allWfhRequests.addAll(
          data.map((item) => WfhRequestModel.fromJson(item, defaultEmployeeName: _userName)).toList(),
        );
        // Sort by createdAt descending
        _allWfhRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching WFH requests: $e');
      setState(() => _isLoading = false);
    }
  }

  List<WfhRequestModel> _getFilteredRequests(int tabIndex) {
    List<WfhRequestModel> baseList = _allWfhRequests;

    // Non-admins can only see their own requests
    if (!_isAdminOrManager && _employeeId != null) {
      baseList = baseList.where((r) => r.employeeId == _employeeId || r.userId == _employeeId).toList();
    }

    if (tabIndex == 1) {
      return baseList.where((r) => r.status == WfhStatus.pending).toList();
    } else if (tabIndex == 2) {
      return baseList.where((r) => r.status == WfhStatus.approved).toList();
    } else if (tabIndex == 3) {
      return baseList.where((r) => r.status == WfhStatus.rejected).toList();
    }
    return baseList;
  }

  int get _totalCount {
    if (!_isAdminOrManager && _employeeId != null) {
      return _allWfhRequests.where((r) => r.employeeId == _employeeId || r.userId == _employeeId).length;
    }
    return _allWfhRequests.length;
  }

  int get _approvedCount {
    final list = !_isAdminOrManager && _employeeId != null
        ? _allWfhRequests.where((r) => r.employeeId == _employeeId || r.userId == _employeeId)
        : _allWfhRequests;
    return list.where((r) => r.status == WfhStatus.approved).length;
  }

  int get _pendingCount {
    final list = !_isAdminOrManager && _employeeId != null
        ? _allWfhRequests.where((r) => r.employeeId == _employeeId || r.userId == _employeeId)
        : _allWfhRequests;
    return list.where((r) => r.status == WfhStatus.pending).length;
  }

  int get _rejectedCount {
    final list = !_isAdminOrManager && _employeeId != null
        ? _allWfhRequests.where((r) => r.employeeId == _employeeId || r.userId == _employeeId)
        : _allWfhRequests;
    return list.where((r) => r.status == WfhStatus.rejected).length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredRequests(_tabController.index);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSummaryCards(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF36617E),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF36617E),
                      onRefresh: _fetchWfhRequests,
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildWfhCard(filtered[index]);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WFH Requests',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '$_totalCount requests total ${_isAdminOrManager ? "(Admin Mode)" : ""}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewWfhScreen(employeeId: _employeeId ?? ''),
                    ),
                  );
                  if (result == true) {
                    _fetchWfhRequests();
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF36617E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          _summaryCard(
            label: 'Approved',
            count: _approvedCount,
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF137333),
            bgColor: const Color(0xFFE6F4EA),
          ),
          const SizedBox(width: 10),
          _summaryCard(
            label: 'Pending',
            count: _pendingCount,
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFB06000),
            bgColor: const Color(0xFFFEF7E0),
          ),
          const SizedBox(width: 10),
          _summaryCard(
            label: 'Rejected',
            count: _rejectedCount,
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFFC5221F),
            bgColor: const Color(0xFFFCE8E6),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required int count,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF36617E),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildWfhCard(WfhRequestModel request) {
    Color statusTxtColor;
    Color statusBg;
    String statusLabel = 'Pending';

    switch (request.status) {
      case WfhStatus.pending:
        statusTxtColor = const Color(0xFFB06000);
        statusBg = const Color(0xFFFEF7E0);
        statusLabel = 'Pending';
        break;
      case WfhStatus.approved:
        statusTxtColor = const Color(0xFF137333);
        statusBg = const Color(0xFFE6F4EA);
        statusLabel = 'Approved';
        break;
      case WfhStatus.rejected:
        statusTxtColor = const Color(0xFFC5221F);
        statusBg = const Color(0xFFFCE8E6);
        statusLabel = 'Rejected';
        break;
    }

    final isOwnRequest = request.employeeId == _employeeId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showWfhDetails(request),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF36617E).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_work_outlined, color: Color(0xFF36617E), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isAdminOrManager && !isOwnRequest
                            ? request.employeeName
                            : (request.totalDays == 1 ? '1 Day Application' : '${request.totalDays} Days Application'),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        request.dateRangeFormatted,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        request.reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusTxtColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF64748B),
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: Color(0xFF64748B),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No WFH requests found',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showWfhDetails(WfhRequestModel request) {
    Color statusTxtColor;
    Color statusBg;
    String statusLabel = 'Pending';
    IconData statusIcon;

    switch (request.status) {
      case WfhStatus.pending:
        statusTxtColor = const Color(0xFFB06000);
        statusBg = const Color(0xFFFEF7E0);
        statusLabel = 'Pending';
        statusIcon = Icons.access_time_filled_rounded;
        break;
      case WfhStatus.approved:
        statusTxtColor = const Color(0xFF137333);
        statusBg = const Color(0xFFE6F4EA);
        statusLabel = 'Approved';
        statusIcon = Icons.check_circle_rounded;
        break;
      case WfhStatus.rejected:
        statusTxtColor = const Color(0xFFC5221F);
        statusBg = const Color(0xFFFCE8E6);
        statusLabel = 'Rejected';
        statusIcon = Icons.cancel_rounded;
        break;
    }

    final isOwnRequest = request.employeeId == _employeeId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setStateSheet) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF36617E).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.home_work_outlined, color: Color(0xFF36617E), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.employeeName,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Applied on ${intl.DateFormat('dd MMM yyyy').format(request.createdAt)}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DETAILS',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailRow(Icons.calendar_month_outlined, 'Dates', request.dateRangeFormatted),
                    const SizedBox(height: 12),
                    _detailRow(Icons.timer_outlined, 'Duration', '${request.totalDays} Workday(s)'),
                    const SizedBox(height: 12),
                    _detailRow(Icons.notes_rounded, 'Reason', request.reason),
                    const SizedBox(height: 20),
                    const Text(
                      'STATUS',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusTxtColor, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusTxtColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (request.adminComment != null && request.adminComment!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'ADMIN COMMENT',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          request.adminComment!,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    if (_isAdminOrManager && request.status == WfhStatus.pending) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFC5221F),
                                side: const BorderSide(color: Color(0xFFC5221F)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _handleAdminAction(request.id, 'REJECTED'),
                              child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF137333),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _handleAdminAction(request.id, 'APPROVED'),
                              child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    ] else if (isOwnRequest && request.status == WfhStatus.pending) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC5221F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final confirm = await _showConfirmCancelDialog();
                            if (confirm == true) {
                              Navigator.pop(context); // close sheet
                              _deleteRequest(request.id);
                            }
                          },
                          child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String title, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              val,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool?> _showConfirmCancelDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this Work From Home request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Color(0xFFC5221F))),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRequest(String requestId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ApiService.deleteWfhRequest(wfhRequestId: requestId);
      if (mounted) {
        Navigator.pop(context); // Pop loading spinner
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request cancelled successfully'), backgroundColor: Colors.green),
        );
        _fetchWfhRequests();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading spinner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleAdminAction(String requestId, String newStatus) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus == 'APPROVED' ? 'Approve WFH Request' : 'Reject WFH Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter admin comment (optional):'),
            const SizedBox(height: 10),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'e.g. Approved. Please check in online.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'APPROVED' ? const Color(0xFF137333) : const Color(0xFFC5221F),
            ),
            onPressed: () {
              Navigator.pop(context); // close comment dialog
              Navigator.pop(context); // close sheet
              _updateStatus(requestId, newStatus, commentController.text);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String requestId, String status, String comment) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ApiService.updateWfhRequestStatus(
        wfhRequestId: requestId,
        status: status,
        adminComment: comment.trim().isEmpty ? null : comment.trim(),
      );
      if (mounted) {
        Navigator.pop(context); // Pop loading spinner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request status updated to $status!'), backgroundColor: Colors.green),
        );
        _fetchWfhRequests();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading spinner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
