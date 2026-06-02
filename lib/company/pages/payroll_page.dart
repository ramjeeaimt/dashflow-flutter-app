import 'package:flutter/material.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  int _selectedTab = 0;
  bool _isLoading = true;
  List<dynamic> _payrolls = [];
  String? _employeeId;

  // Active / selected payroll details
  double _basicSalary = 0;
  double _netSalary = 0;
  double _deductions = 0;
  double _allowances = 0;
  String _monthYearStr = '';

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
            if (_payrolls.isNotEmpty) {
              final latest = _payrolls.first;
              _basicSalary = double.tryParse(latest['basicSalary']?.toString() ?? '') ?? 0.0;
              _netSalary = double.tryParse(latest['netSalary']?.toString() ?? '') ?? 0.0;
              _deductions = double.tryParse(latest['deductions']?.toString() ?? '') ?? 0.0;
              _allowances = double.tryParse(latest['allowances']?.toString() ?? '') ?? 0.0;
              final month = latest['month'] ?? 1;
              final year = latest['year'] ?? 2026;
              final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              _monthYearStr = '${months[month - 1]} $year';
            } else {
              // Fallback default mock values if no payroll generated yet
              _basicSalary = 75000.0;
              _netSalary = 63500.0;
              _deductions = 11500.0;
              _allowances = 0.0;
              _monthYearStr = 'Current Salary';
            }
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
          SnackBar(content: Text('Failed to load payroll data: $e')),
        );
      }
    }
  }

  String _getMonthName(int monthNum) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    if (monthNum >= 1 && monthNum <= 12) {
      return months[monthNum - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Payroll',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadPayrollData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSalaryCard(),
                  const SizedBox(height: 24),
                  _buildTabNavigation(),
                  const SizedBox(height: 16),
                  _selectedTab == 0 ? _buildBreakdownTab() : _buildPaymentHistoryTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildSalaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _monthYearStr,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,###').format(_basicSalary)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'gross salary per month',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSalaryInfo('Net Pay', '₹${NumberFormat('#,##,###').format(_netSalary)}', Colors.white),
              _buildSalaryInfo('Total Deductions', '₹${NumberFormat('#,##,###').format(_deductions)}', Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 ? Colors.green[50] : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 0 ? Colors.green : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    'Breakdown',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 0 ? Colors.green : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1 ? Colors.green[50] : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 1 ? Colors.green : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    'History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 1 ? Colors.green : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownTab() {
    // Breakdown calculations
    final hra = _basicSalary * 0.20;
    final da = _basicSalary * 0.133;
    final pf = _basicSalary * 0.05;
    final tax = _deductions - pf;

    final earnings = [
      {'label': 'Base Salary', 'amount': '₹${NumberFormat('#,##,###').format(_basicSalary - hra - da)}', 'icon': '💰'},
      {'label': 'House Rent Allowance', 'amount': '₹${NumberFormat('#,##,###').format(hra)}', 'icon': '🏠'},
      {'label': 'Dearness Allowance', 'amount': '₹${NumberFormat('#,##,###').format(da)}', 'icon': '📈'},
    ];

    final deductionsList = [
      if (tax > 0) {'label': 'Income Tax', 'amount': '₹${NumberFormat('#,##,###').format(tax)}', 'icon': '🧾'},
      {'label': 'Provident Fund', 'amount': '₹${NumberFormat('#,##,###').format(pf)}', 'icon': '🏦'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...earnings.map((e) => _buildBreakdownItem(
            e['label']!,
            e['amount']!,
            e['icon']!,
            Colors.green,
          )),
          const SizedBox(height: 20),
          const Text(
            'Deductions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...deductionsList.map((d) => _buildBreakdownItem(
            d['label']!,
            d['amount']!,
            d['icon']!,
            Colors.red,
          )),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earnings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##,###').format(_basicSalary)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Deductions',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##,###').format(_deductions)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Pay',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##,###').format(_netSalary)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    String amount,
    String icon,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    if (_payrolls.isEmpty) {
      // Mock history if no data returned yet
      final paymentHistory = [
        {'date': 'May 31, 2026', 'amount': '₹63,500', 'status': 'Paid'},
        {'date': 'April 30, 2026', 'amount': '₹63,500', 'status': 'Paid'},
        {'date': 'March 31, 2026', 'amount': '₹63,500', 'status': 'Paid'},
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ...paymentHistory.map((payment) => _buildPaymentHistoryItem(
              payment['date']!,
              payment['amount']!,
              payment['status']!,
            )),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ..._payrolls.map((payroll) {
            final month = payroll['month'] ?? 1;
            final year = payroll['year'] ?? 2026;
            final dateStr = '${_getMonthName(month)} $year';
            final netVal = double.tryParse(payroll['netSalary']?.toString() ?? '') ?? 0.0;
            final amountStr = '₹${NumberFormat('#,##,###').format(netVal)}';
            final statusStr = payroll['status']?.toString().toUpperCase() ?? 'UNPAID';

            return _buildPaymentHistoryItem(
              dateStr,
              amountStr,
              statusStr,
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem(String date, String amount, String status) {
    final isPaid = status.toLowerCase() == 'paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Salary Payment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}