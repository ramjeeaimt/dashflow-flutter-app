import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MyPayrollPage extends StatefulWidget {
  const MyPayrollPage({super.key});
  @override
  State<MyPayrollPage> createState() => _MyPayrollPageState();
}

class _MyPayrollPageState extends State<MyPayrollPage> {
  String _activeTab = 'ALL';
  String _selectedMonth = 'All Months';
  final _months = [
    'All Months',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<dynamic> _payrolls = [];
  bool _isLoading = true;
  String? _employeeId;

  double _yearToDate = 0;
  double _lastPayout = 0;
  int _pendingReviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPayrollData();
  }

  Future<void> _loadPayrollData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        _employeeId = user['id'] ?? user['employeeId'];
      }

      if (_employeeId != null) {
        final list = await ApiService.getPayroll(employeeId: _employeeId);
        if (mounted) {
          setState(() {
            _payrolls = list;
            _calculateStats();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payroll data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _calculateStats() {
    double ytd = 0;
    double last = 0;
    int pending = 0;
    bool foundLast = false;

    // Sort payrolls by year and month descending to get the latest first
    _payrolls.sort((a, b) {
      final yearA = a['year'] ?? 0;
      final yearB = b['year'] ?? 0;
      if (yearA != yearB) return yearB.compareTo(yearA);
      final monthA = a['month'] ?? 0;
      final monthB = b['month'] ?? 0;
      return monthB.compareTo(monthA);
    });

    for (final p in _payrolls) {
      final netVal = double.tryParse(p['netSalary']?.toString() ?? '') ?? 0.0;
      final status = p['status']?.toString().toLowerCase() ?? '';

      if (status == 'paid') {
        final year = p['year'] ?? 2026;
        if (year == DateTime.now().year) {
          ytd += netVal;
        }
        if (!foundLast) {
          last = netVal;
          foundLast = true;
        }
      } else {
        pending++;
      }
    }

    _yearToDate = ytd;
    _lastPayout = last;
    _pendingReviewCount = pending;
  }

  String _getMonthName(int month) {
    if (month < 1 || month > 12) return 'January';
    return _months[month];
  }

  Future<void> _downloadSlip(String payrollId, String periodName) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('${ApiService.baseUrl}/finance/payroll/$payrollId/slip');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/payslip_$periodName.pdf');
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payslip downloaded to: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download payslip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter payrolls
    final filteredPayrolls = _payrolls.where((p) {
      final status = p['status']?.toString().toUpperCase() ?? 'PENDING';
      if (_activeTab != 'ALL' && status != _activeTab) return false;

      if (_selectedMonth != 'All Months') {
        final monthInt = p['month'] ?? 1;
        final monthName = _getMonthName(monthInt);
        if (monthName != _selectedMonth) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(context, 'Payroll History'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Employee. View your earnings summary.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              'YEAR TO DATE',
                              '₹${NumberFormat('#,##,###').format(_yearToDate)}',
                              Icons.account_balance_wallet_outlined,
                              kPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              'LAST PAYOUT',
                              '₹${NumberFormat('#,##,###').format(_lastPayout)}',
                              Icons.description_outlined,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              'PENDING REVIEW',
                              '$_pendingReviewCount',
                              Icons.timelapse_outlined,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              'CURRENT YEAR',
                              '${DateTime.now().year}',
                              Icons.calendar_today_outlined,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: ['ALL', 'PAID', 'PENDING'].map((t) {
                            final isSel = _activeTab == t;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _activeTab = t),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      color: isSel ? kPrimary : kSubText,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: kBorder),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedMonth,
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: const TextStyle(fontSize: 13, color: kText),
                          items: _months
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedMonth = v!),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredPayrolls.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No payroll records match these filters.',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredPayrolls.length,
                          itemBuilder: (_, i) {
                            final p = filteredPayrolls[i];
                            final month = p['month'] ?? 1;
                            final year = p['year'] ?? 2026;
                            final period = '${_getMonthName(month)} $year';
                            final netVal = double.tryParse(p['netSalary']?.toString() ?? '') ?? 0.0;
                            final amountStr = NumberFormat('#,##,###').format(netVal);
                            final status = p['status']?.toString().toUpperCase() ?? 'PENDING';
                            final isPaid = status == 'PAID';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: kBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: kPrimary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      color: kPrimary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          period,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: kText,
                                          ),
                                        ),
                                        Text(
                                          '₹$amountStr',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      StatusBadge(
                                        label: status,
                                        color: isPaid ? Colors.green : Colors.orange,
                                      ),
                                      if (isPaid && p['id'] != null) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.download_for_offline_outlined,
                                            color: kPrimary,
                                            size: 24,
                                          ),
                                          onPressed: () => _downloadSlip(
                                            p['id'].toString(),
                                            '${_getMonthName(month)}_$year',
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _statCard(String l, String v, IconData icon, Color c) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 18),
            const SizedBox(height: 4),
            Text(
              v,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c),
              textAlign: TextAlign.center,
            ),
            Text(
              l,
              style: const TextStyle(
                fontSize: 8,
                color: kSubText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
