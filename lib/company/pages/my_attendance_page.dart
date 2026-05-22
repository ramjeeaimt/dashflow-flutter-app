import 'package:flutter/material.dart';

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  int _selectedPeriod = 0;
  final List<String> periods = ['Week', 'Month', 'Year'];

    final Map<String, dynamic> financialData = {
    'accountBalance': 25480.50,
    'monthlyIncome': 8500.00,
    'monthlyExpenses': 3200.50,
    'savingsRate': 62.5,
    'stats': [
      {
        'label': 'Income',
        'value': '\$8,500',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'label': 'Expenses',
        'value': '\$3,200',
        'icon': Icons.trending_down,
        'color': Colors.red,
      },
      {
        'label': 'Savings',
        'value': '\$5,300',
        'icon': Icons.savings,
        'color': Colors.blue,
      },
      {
        'label': 'Investments',
        'value': '\$12,480',
        'icon': Icons.trending_up,
        'color': Colors.orange,
      },
    ],
    'expenses': [
      {
        'category': 'Food & Dining',
        'percentage': 28,
        'amount': '\$900',
        'color': Colors.red,
      },
      {
        'category': 'Transportation',
        'percentage': 22,
        'color': Colors.orange,
        'amount': '\$700',
      },
      {
        'category': 'Shopping',
        'percentage': 25,
        'color': Colors.purple,
        'amount': '\$800',
      },
      {
        'category': 'Entertainment',
        'percentage': 15,
        'color': Colors.blue,
        'amount': '\$480',
      },
      {
        'category': 'Utilities',
        'percentage': 10,
        'color': Colors.teal,
        'amount': '\$320',
      },
    ],
    'monthlyData': [
      {'month': 'Jan', 'income': 8200, 'expense': 3100},
      {'month': 'Feb', 'income': 8500, 'expense': 3200},
      {'month': 'Mar', 'income': 8800, 'expense': 3100},
      {'month': 'Apr', 'income': 8500, 'expense': 3300},
      {'month': 'May', 'income': 9000, 'expense': 3200},
      {'month': 'Jun', 'income': 8500, 'expense': 3200},
    ],
    'budgets': [
      {
        'category': 'Food & Dining',
        'limit': 1000,
        'spent': 900,
        'icon': Icons.restaurant,
        'color': Colors.red,
      },
      {
        'category': 'Transportation',
        'limit': 800,
        'spent': 700,
        'icon': Icons.directions_car,
        'color': Colors.orange,
      },
      {
        'category': 'Entertainment',
        'limit': 600,
        'spent': 480,
        'icon': Icons.movie,
        'color': Colors.blue,
      },
      {
        'category': 'Shopping',
        'limit': 1200,
        'spent': 800,
        'icon': Icons.shopping_bag,
        'color': Colors.purple,
      },
    ],
    'transactions': [
      {
        'title': 'Salary Deposit',
        'category': 'Income',
        'amount': '+\$8,500',
        'date': 'Today',
        'icon': Icons.account_balance_wallet,
        'isIncome': true,
      },
      {
        'title': 'Grocery Shopping',
        'category': 'Food',
        'amount': '-\$125.50',
        'date': 'Yesterday',
        'icon': Icons.shopping_cart,
        'isIncome': false,
      },
      {
        'title': 'Electricity Bill',
        'category': 'Utilities',
        'amount': '-\$85.00',
        'date': 'Dec 15',
        'icon': Icons.bolt,
        'isIncome': false,
      },
      {
        'title': 'Restaurant',
        'category': 'Food',
        'amount': '-\$45.30',
        'date': 'Dec 14',
        'icon': Icons.restaurant,
        'isIncome': false,
      },
      {
        'title': 'Freelance Project',
        'category': 'Income',
        'amount': '+\$1,200',
        'date': 'Dec 13',
        'icon': Icons.work,
        'isIncome': true,
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
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Text(
          'Finance Dashboard',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            _buildBalanceCard(),

            const SizedBox(height: 20),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: financialData['stats'].length,
                itemBuilder: (context, index) {
                  final stat = financialData['stats'][index];
                  return _buildStatCard(
                    stat['label'],
                    stat['value'],
                    stat['icon'],
                    stat['color'],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Monthly Trend',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: List.generate(
                        periods.length,
                        (index) => GestureDetector(
                          onTap: () => setState(() => _selectedPeriod = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedPeriod == index
                                  ? Colors.blue.shade700
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              periods[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedPeriod == index
                                    ? Colors.white
                                    : Colors.grey.shade600,
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

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildChartCard(),
            ),

            const SizedBox(height: 24),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildExpenseBreakdownCard(),
            ),

            const SizedBox(height: 24),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(financialData['budgets'].length, (
                      index,
                    ) {
                      final budget = financialData['budgets'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildBudgetItem(budget),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(
                      financialData['transactions'].length,
                      (index) {
                        final transaction =
                            financialData['transactions'][index];
                        return _buildTransactionItem(transaction);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add Income'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.remove),
                      label: const Text('Add Expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account Balance',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.visibility, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${financialData['accountBalance'].toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
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
                    'Card Number',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '•••• •••• •••• 4892',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Expiry',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '12/28',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
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
            child: Icon(icon, color: color, size: 24),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
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
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: ChartPainter(financialData['monthlyData']),
              size: const Size(double.infinity, 200),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Income', Colors.green.shade600),
              const SizedBox(width: 24),
              _buildLegendItem('Expenses', Colors.red.shade600),
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownCard() {
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
            'Expense Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: PieChartPainter(financialData['expenses']),
              size: const Size(double.infinity, 150),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(financialData['expenses'].length, (index) {
              final expense = financialData['expenses'][index];
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
                            expense['category'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${expense['percentage']}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      expense['amount'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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

  Widget _buildBudgetItem(Map<String, dynamic> budget) {
    final spent = budget['spent'] as int;
    final limit = budget['limit'] as int;
    final percentage = (spent / limit * 100).toStringAsFixed(0);
    final remaining = limit - spent;

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: budget['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(budget['icon'], color: budget['color']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget['category'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$$spent of \$$limit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: spent / limit,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(budget['color']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(transaction['icon'], color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${transaction['category']} • ${transaction['date']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            transaction['amount'],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: transaction['isIncome'] ? Colors.green : Colors.red,
            ),
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
    final maxValue = 10000.0;

    for (int i = 0; i < data.length; i++) {
      final x = i * width + width / 2;

      
      final incomeHeight =
          (data[i]['income'] / maxValue) * (size.height - spacing * 2);
      canvas.drawRect(
        Rect.fromLTWH(
          x - 12,
          size.height - spacing - incomeHeight,
          10,
          incomeHeight,
        ),
        Paint()..color = incomeColor,
      );

      
      final expenseHeight =
          (data[i]['expense'] / maxValue) * (size.height - spacing * 2);
      canvas.drawRect(
        Rect.fromLTWH(
          x + 2,
          size.height - spacing - expenseHeight,
          10,
          expenseHeight,
        ),
        Paint()..color = expenseColor,
      );

      
      TextPainter(
          text: TextSpan(
            text: data[i]['month'],
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, Offset(x - 8, size.height - 15));
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => false;
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
      final sweepAngle = (expense['percentage'] / 100) * 2 * 3.14159;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()..color = expense['color'],
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => false;
}
