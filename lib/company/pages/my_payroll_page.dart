import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Pay Slips', 'Advances'];
  int _selectedPaySlipIndex = 0;

  
  final Map<String, dynamic> payrollData = {
    'salaryInfo': {
      'ctc': 60000.00,
      'grossSalary': 50000.00,
      'netSalary': 41250.00,
      'paymentDate': '25th of every month',
      'paymentMethod': 'Bank Transfer',
      'accountNumber': 'XXXX XXXX XXXX 4892',
    },
    'currentPayslip': {
      'month': 'December 2024',
      'payPeriod': '01 Dec - 31 Dec 2024',
      'grossSalary': 50000.00,
      'earnings': [
        {'name': 'Basic Salary', 'amount': 30000.00},
        {'name': 'House Rent Allowance', 'amount': 12000.00},
        {'name': 'Dearness Allowance', 'amount': 5000.00},
        {'name': 'Performance Bonus', 'amount': 3000.00},
      ],
      'deductions': [
        {'name': 'Income Tax', 'amount': 5000.00},
        {'name': 'Provident Fund (PF)', 'amount': 2250.00},
        {'name': 'Professional Tax', 'amount': 200.00},
        {'name': 'Health Insurance', 'amount': 1300.00},
      ],
      'totalDeductions': 8750.00,
      'netSalary': 41250.00,
      'issuedOn': '2024-12-01',
    },
    'payslips': [
      {
        'month': 'December 2024',
        'payPeriod': '01 Dec - 31 Dec 2024',
        'grossSalary': 50000.00,
        'deductions': 8750.00,
        'netSalary': 41250.00,
        'issuedOn': '2024-12-01',
        'status': 'Paid',
      },
      {
        'month': 'November 2024',
        'payPeriod': '01 Nov - 30 Nov 2024',
        'grossSalary': 50000.00,
        'deductions': 8750.00,
        'netSalary': 41250.00,
        'issuedOn': '2024-11-01',
        'status': 'Paid',
      },
      {
        'month': 'October 2024',
        'payPeriod': '01 Oct - 31 Oct 2024',
        'grossSalary': 50000.00,
        'deductions': 8750.00,
        'netSalary': 41250.00,
        'issuedOn': '2024-10-01',
        'status': 'Paid',
      },
      {
        'month': 'September 2024',
        'payPeriod': '01 Sep - 30 Sep 2024',
        'grossSalary': 49000.00,
        'deductions': 8575.00,
        'netSalary': 40425.00,
        'issuedOn': '2024-09-01',
        'status': 'Paid',
      },
      {
        'month': 'August 2024',
        'payPeriod': '01 Aug - 31 Aug 2024',
        'grossSalary': 50000.00,
        'deductions': 8750.00,
        'netSalary': 41250.00,
        'issuedOn': '2024-08-01',
        'status': 'Paid',
      },
      {
        'month': 'July 2024',
        'payPeriod': '01 Jul - 31 Jul 2024',
        'grossSalary': 50000.00,
        'deductions': 8750.00,
        'netSalary': 41250.00,
        'issuedOn': '2024-07-01',
        'status': 'Paid',
      },
    ],
    'salaryBreakdown': {
      'basic': 30000.00,
      'hra': 12000.00,
      'da': 5000.00,
      'bonus': 3000.00,
      'grossSalary': 50000.00,
    },
    'taxInfo': {
      'financialYear': '2024-2025',
      'incomeTax': 60000.00,
      'pfContribution': 27000.00,
      'professionalTax': 2400.00,
      'totalTaxDeductions': 89400.00,
    },
    'advances': [
      {
        'id': 'ADV001',
        'amount': 5000.00,
        'appliedDate': DateTime.now().subtract(const Duration(days: 15)),
        'approvalDate': DateTime.now().subtract(const Duration(days: 14)),
        'disbursementDate': DateTime.now().subtract(const Duration(days: 13)),
        'status': 'Approved',
        'statusColor': Colors.green,
        'repaymentMonths': 3,
        'remainingEMI': 0,
      },
      {
        'id': 'ADV002',
        'amount': 10000.00,
        'appliedDate': DateTime.now().subtract(const Duration(days: 5)),
        'approvalDate': null,
        'disbursementDate': null,
        'status': 'Pending',
        'statusColor': Colors.orange,
        'repaymentMonths': 4,
        'remainingEMI': 4,
      },
      {
        'id': 'ADV003',
        'amount': 7500.00,
        'appliedDate': DateTime.now().subtract(const Duration(days: 30)),
        'approvalDate': DateTime.now().subtract(const Duration(days: 25)),
        'disbursementDate': DateTime.now().subtract(const Duration(days: 24)),
        'status': 'Rejected',
        'statusColor': Colors.red,
        'repaymentMonths': 0,
        'remainingEMI': 0,
        'rejectionReason': 'Limit exceeded for this quarter',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payroll',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == index
                              ? Colors.blue.shade700
                              : Colors.transparent,
                          borderRadius: _selectedTab == index
                              ? BorderRadius.circular(8)
                              : BorderRadius.zero,
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == index
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          
          Expanded(
            child: _selectedTab == 0
                ? _buildOverviewTab()
                : _selectedTab == 1
                ? _buildPaySlipsTab()
                : _buildAdvancesTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final salaryInfo = payrollData['salaryInfo'];
    final currentPayslip = payrollData['currentPayslip'];

    return SingleChildScrollView(
      child: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSalaryCard(),
          ),

          const SizedBox(height: 24),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Salary Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryStatCard(
                        'Gross Salary',
                        '\$${salaryInfo['grossSalary'].toStringAsFixed(2)}',
                        Colors.green,
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryStatCard(
                        'Deductions',
                        '\$${currentPayslip['totalDeductions'].toStringAsFixed(2)}',
                        Colors.red,
                        Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryStatCard(
                        'Net Salary',
                        '\$${salaryInfo['netSalary'].toStringAsFixed(2)}',
                        Colors.blue,
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryStatCard(
                        'CTC',
                        '\$${salaryInfo['ctc'].toStringAsFixed(2)}',
                        Colors.purple,
                        Icons.monetization_on,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCurrentPayslipCard(),
          ),

          const SizedBox(height: 24),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPaymentInfoCard(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSalaryCard() {
    final salaryInfo = payrollData['salaryInfo'];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Net Salary',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${salaryInfo['netSalary'].toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Date',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salaryInfo['paymentDate'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salaryInfo['paymentMethod'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPayslipCard() {
    final currentPayslip = payrollData['currentPayslip'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Pay Slip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentPayslip['month'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPayslipBreakdownRow(
            'Gross Salary',
            '\$${currentPayslip['grossSalary'].toStringAsFixed(2)}',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildPayslipBreakdownRow(
            'Total Deductions',
            '-\$${currentPayslip['totalDeductions'].toStringAsFixed(2)}',
            Colors.red,
          ),
          const SizedBox(height: 12),
          Container(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),
          _buildPayslipBreakdownRow(
            'Net Salary',
            '\$${currentPayslip['netSalary'].toStringAsFixed(2)}',
            Colors.blue,
            isBold: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pay slip downloading...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showPayslipDetails();
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipBreakdownRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard() {
    final salaryInfo = payrollData['salaryInfo'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentInfoRow(
            Icons.account_balance_wallet,
            'Account Number',
            salaryInfo['accountNumber'],
          ),
          const Divider(height: 20),
          _buildPaymentInfoRow(
            Icons.calendar_today,
            'Payment Frequency',
            'Monthly',
          ),
          const Divider(height: 20),
          _buildPaymentInfoRow(
            Icons.payment,
            'Payment Mode',
            salaryInfo['paymentMethod'],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaySlipsTab() {
    final payslips = payrollData['payslips'] as List;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(payslips.length, (index) {
            final payslip = payslips[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPayslipListCard(payslip, index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPayslipListCard(Map<String, dynamic> payslip, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payslip['month'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    payslip['payPeriod'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  payslip['status'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gross',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    '\$${payslip['grossSalary'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deductions',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    '\$${payslip['deductions'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    '\$${payslip['netSalary'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('View Details'),
                    onTap: () {
                      setState(() => _selectedPaySlipIndex = index);
                      _showPayslipDetails();
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('Download'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pay slip downloading...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancesTab() {
    final advances = payrollData['advances'] as List;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAdvanceRequestDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Request Advance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(advances.length, (index) {
                final advance = advances[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAdvanceCard(advance),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvanceCard(Map<String, dynamic> advance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request ID: ${advance['id']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Amount: \$${advance['amount'].toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: advance['statusColor'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  advance['status'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: advance['statusColor'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAdvanceTimeline(advance),
          const SizedBox(height: 12),
          if (advance['status'] == 'Approved' && advance['remainingEMI'] > 0)
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Remaining EMI: ${advance['remainingEMI']} months',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (advance['status'] == 'Rejected' &&
              advance['rejectionReason'] != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reason: ${advance['rejectionReason']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdvanceTimeline(Map<String, dynamic> advance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineItem(
          'Applied',
          DateFormat('MMM d, yyyy').format(advance['appliedDate']),
          Colors.blue,
        ),
        if (advance['approvalDate'] != null)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  height: 16,
                  child: VerticalDivider(color: Colors.grey.shade300),
                ),
              ),
              _buildTimelineItem(
                advance['status'] == 'Rejected' ? 'Rejected' : 'Approved',
                DateFormat('MMM d, yyyy').format(advance['approvalDate']),
                advance['status'] == 'Rejected' ? Colors.red : Colors.green,
              ),
            ],
          ),
        if (advance['disbursementDate'] != null)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  height: 16,
                  child: VerticalDivider(color: Colors.grey.shade300),
                ),
              ),
              _buildTimelineItem(
                'Disbursed',
                DateFormat('MMM d, yyyy').format(advance['disbursementDate']),
                Colors.green,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTimelineItem(String label, String date, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              date,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  void _showPayslipDetails() {
    final currentPayslip = payrollData['currentPayslip'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pay Slip',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        currentPayslip['month'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Earnings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...(currentPayslip['earnings'] as List).map(
                (earning) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        earning['name'],
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '\$${earning['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 16),
              const Text(
                'Deductions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...(currentPayslip['deductions'] as List).map(
                (deduction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        deduction['name'],
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '-\$${deduction['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Salary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '\$${currentPayslip['netSalary'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pay slip downloading...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvanceRequestDialog() {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Salary Advance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty &&
                  reasonController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Advance request submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
