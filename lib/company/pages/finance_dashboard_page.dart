import 'package:flutter/material.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  int _selectedPeriod = 1; // Default to 'Month'
  final List<String> periods = ['Week', 'Month', 'Year'];
  bool _isLoading = true;
  String? _companyId;

  // Live summary values
  double _accountBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  double _monthlyPayroll = 0.0;

  List<dynamic> _expenses = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        _companyId = user['company']?['id']?.toString();
      }

      if (_companyId != null) {
        final now = DateTime.now();
        // Fetch summary
        final summary = await ApiService.getFinanceSummary(
          _companyId!,
          month: _selectedPeriod == 1 ? now.month : null,
          year: _selectedPeriod == 1 ? now.year : (_selectedPeriod == 2 ? now.year : null),
        );

        // Fetch expenses
        final expensesList = await ApiService.getExpenses(_companyId!);

        if (mounted) {
          setState(() {
            _summary = summary;
            _expenses = expensesList;

            _accountBalance = double.tryParse(summary['netBalance']?.toString() ?? '') ?? 0.0;
            _monthlyIncome = double.tryParse(summary['totalCredit']?.toString() ?? '') ?? 0.0;
            _monthlyExpenses = double.tryParse(summary['totalExpenses']?.toString() ?? '') ?? 0.0;
            _monthlyPayroll = double.tryParse(summary['totalPayroll']?.toString() ?? '') ?? 0.0;
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
          SnackBar(content: Text('Failed to load finance data: $e')),
        );
      }
    }
  }

  void _showAddExpenseDialog() {
    final formKey = GlobalKey<FormState>();
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Utilities';
    String type = 'debit'; // debit = expense, credit = income

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(labelText: 'Transaction Type'),
                        items: const [
                          DropdownMenuItem(value: 'debit', child: Text('Expense (Debit)')),
                          DropdownMenuItem(value: 'credit', child: Text('Income (Credit)')),
                        ],
                        onChanged: (v) => setDialogState(() => type = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g. Office Supplies'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Amount (INR)', hintText: 'e.g. 5000'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: const [
                          DropdownMenuItem(value: 'Utilities', child: Text('Utilities')),
                          DropdownMenuItem(value: 'Transportation', child: Text('Transportation')),
                          DropdownMenuItem(value: 'Food & Dining', child: Text('Food & Dining')),
                          DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                          DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
                          DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                          DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                          DropdownMenuItem(value: 'Others', child: Text('Others')),
                        ],
                        onChanged: (v) => setDialogState(() => category = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (formKey.currentState!.validate() && _companyId != null) {
                      final desc = descController.text.trim();
                      final amt = double.parse(amountController.text.trim());
                      Navigator.pop(context);
                      setState(() => _isLoading = true);

                      try {
                        await ApiService.createExpense(
                          companyId: _companyId!,
                          description: desc,
                          amount: amt,
                          category: category,
                          status: 'approved',
                          date: DateTime.now().toIso8601String(),
                        );
                        _loadFinanceData();
                      } catch (e) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save transaction: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteExpense(String id) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteExpense(id);
      _loadFinanceData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _getPieData() {
    final Map<String, double> categorySums = {};
    double total = 0.0;
    for (var exp in _expenses) {
      final amt = double.tryParse(exp['amount']?.toString() ?? '') ?? 0.0;
      final cat = exp['category']?.toString() ?? 'Others';
      categorySums[cat] = (categorySums[cat] ?? 0.0) + amt;
      total += amt;
    }

    if (total == 0) {
      return [
        {'category': 'No Expenses', 'percentage': 100, 'amount': '₹0', 'color': Colors.grey}
      ];
    }

    final colors = [Colors.red, Colors.orange, Colors.purple, Colors.blue, Colors.teal, Colors.indigo, Colors.amber];
    int colorIdx = 0;

    return categorySums.entries.map((entry) {
      final percentage = ((entry.value / total) * 100).round();
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      return {
        'category': entry.key,
        'percentage': percentage,
        'amount': '₹${NumberFormat('#,##,###').format(entry.value)}',
        'color': color,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'label': 'Income (Credit)',
        'value': '₹${NumberFormat('#,##,###').format(_monthlyIncome)}',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'label': 'Expenses (Debit)',
        'value': '₹${NumberFormat('#,##,###').format(_monthlyExpenses)}',
        'icon': Icons.trending_down,
        'color': Colors.red,
      },
      {
        'label': 'Payroll (Paid)',
        'value': '₹${NumberFormat('#,##,###').format(_monthlyPayroll)}',
        'icon': Icons.account_balance,
        'color': Colors.blue,
      },
      {
        'label': 'Net Balance',
        'value': '₹${NumberFormat('#,##,###').format(_accountBalance)}',
        'icon': Icons.savings,
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Finance Dashboard',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadFinanceData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 20),

                  // Stats Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: stats.length,
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return _buildStatCard(
                          stat['label'] as String,
                          stat['value'] as String,
                          stat['icon'] as IconData,
                          stat['color'] as Color,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Period Selector & Trend
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Trend Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            children: List.generate(
                              periods.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() => _selectedPeriod = index);
                                  _loadFinanceData();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedPeriod == index ? Colors.blue.shade700 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    periods[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedPeriod == index ? Colors.white : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Monthly Trend Chart Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildChartCard(),
                  ),

                  const SizedBox(height: 24),

                  // Pie Chart Breakdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildExpenseBreakdownCard(),
                  ),

                  const SizedBox(height: 24),

                  // Recent Transactions list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transactions Log',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        _expenses.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                child: const Center(
                                  child: Text('No transactions recorded yet', style: TextStyle(color: Colors.grey)),
                                ),
                              )
                            : Column(
                                children: List.generate(
                                  _expenses.length > 5 ? 5 : _expenses.length,
                                  (index) {
                                    final transaction = _expenses[index];
                                    return _buildTransactionItem(transaction);
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showAddExpenseDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Transaction'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.wallet, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${NumberFormat('#,##,###.##').format(_accountBalance)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Corporate Vault', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  SizedBox(height: 4),
                  Text(
                    'DIFMO Technologies',
                    style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                child: const Text('Live Feed', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _buildChartCard() {
    final mockMonthlyData = [
      {'month': 'Jan', 'income': 18000, 'expense': 12000},
      {'month': 'Feb', 'income': 22000, 'expense': 15000},
      {'month': 'Mar', 'income': 20000, 'expense': 13000},
      {'month': 'Apr', 'income': 24000, 'expense': 16000},
      {'month': 'May', 'income': _monthlyIncome > 0 ? _monthlyIncome : 28000, 'expense': _monthlyExpenses + _monthlyPayroll},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: ChartPainter(mockMonthlyData),
              size: const Size(double.infinity, 200),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Credits', Colors.green.shade600),
              const SizedBox(width: 24),
              _buildLegendItem('Debits/Outgoing', Colors.red.shade600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownCard() {
    final pieData = _getPieData();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Category Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          if (_expenses.isNotEmpty) ...[
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: PieChartPainter(pieData),
                size: const Size(double.infinity, 150),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Column(
            children: List.generate(pieData.length, (index) {
              final expense = pieData[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: expense['color'],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense['category'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                          ),
                          Text(
                            '${expense['percentage']}%',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      expense['amount'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    final isIncome = tx['type']?.toString().toLowerCase() == 'credit' ||
        tx['category']?.toString().toLowerCase() == 'salary' ||
        tx['description']?.toString().toLowerCase().contains('salary') == true;
    final amtVal = double.tryParse(tx['amount']?.toString() ?? '') ?? 0.0;
    final amountStr = '${isIncome ? '+' : '-'}₹${NumberFormat('#,##,###').format(amtVal)}';
    final dateStr = tx['date'] != null ? DateFormat('d MMM').format(DateTime.parse(tx['date'])) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['description']?.toString() ?? 'Transaction',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  '${tx['category'] ?? 'General'} • $dateStr',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amountStr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Delete Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text('Are you sure you want to delete this transaction record?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteExpense(tx['id']?.toString() ?? '');
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade300),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..isAntiAlias = true;

    final incomeColor = Colors.green.shade600;
    const expenseColor = Color(0xFFEF5350);

    final width = size.width / data.length;
    const spacing = 20.0;

    double maxVal = 10000.0;
    for (var d in data) {
      final inc = double.tryParse(d['income']?.toString() ?? '') ?? 0.0;
      final exp = double.tryParse(d['expense']?.toString() ?? '') ?? 0.0;
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
    }

    for (int i = 0; i < data.length; i++) {
      final x = i * width + width / 2;

      final incAmt = double.tryParse(data[i]['income']?.toString() ?? '') ?? 0.0;
      final expAmt = double.tryParse(data[i]['expense']?.toString() ?? '') ?? 0.0;

      final incomeHeight = (incAmt / maxVal) * (size.height - spacing * 2);
      canvas.drawRect(
        Rect.fromLTWH(x - 12, size.height - spacing - incomeHeight, 10, incomeHeight),
        Paint()..color = incomeColor,
      );

      final expenseHeight = (expAmt / maxVal) * (size.height - spacing * 2);
      canvas.drawRect(
        Rect.fromLTWH(x + 2, size.height - spacing - expenseHeight, 10, expenseHeight),
        Paint()..color = expenseColor,
      );

      TextPainter(
        text: TextSpan(
          text: data[i]['month']?.toString() ?? '',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(x - 8, size.height - 15));
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> expenses;

  PieChartPainter(this.expenses);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 - 10;

    double startAngle = -90 * (3.14159 / 180);

    for (final expense in expenses) {
      final double percentage = double.tryParse(expense['percentage']?.toString() ?? '') ?? 0.0;
      final sweepAngle = (percentage / 100) * 2 * 3.14159;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()..color = expense['color'] as Color,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => true;
}
