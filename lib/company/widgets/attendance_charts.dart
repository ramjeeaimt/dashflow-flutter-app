import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Charts',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const AttendanceChartScreen(),
    );
  }
}

class AttendanceChartScreen extends StatefulWidget {
  const AttendanceChartScreen({super.key});

  @override
  State<AttendanceChartScreen> createState() => _AttendanceChartScreenState();
}

class _AttendanceChartScreenState extends State<AttendanceChartScreen> {
  int _selectedTab = 0;
  String _selectedPeriod = 'Month';

  final attendanceData = {
    'Month': [
      {'day': 'Mon', 'percentage': 95, 'status': 'Present'},
      {'day': 'Tue', 'percentage': 100, 'status': 'Present'},
      {'day': 'Wed', 'percentage': 85, 'status': 'Late'},
      {'day': 'Thu', 'percentage': 90, 'status': 'Present'},
      {'day': 'Fri', 'percentage': 0, 'status': 'Absent'},
      {'day': 'Sat', 'percentage': 100, 'status': 'Present'},
      {'day': 'Sun', 'percentage': 95, 'status': 'Present'},
    ],
    'Quarter': [
      {'month': 'Jan', 'percentage': 92},
      {'month': 'Feb', 'percentage': 88},
      {'month': 'Mar', 'percentage': 95},
      {'month': 'Apr', 'percentage': 87},
    ],
    'Year': [
      {'month': 'Jan', 'percentage': 92},
      {'month': 'Feb', 'percentage': 88},
      {'month': 'Mar', 'percentage': 95},
      {'month': 'Apr', 'percentage': 87},
      {'month': 'May', 'percentage': 91},
      {'month': 'Jun', 'percentage': 93},
      {'month': 'Jul', 'percentage': 89},
      {'month': 'Aug', 'percentage': 94},
      {'month': 'Sep', 'percentage': 90},
      {'month': 'Oct', 'percentage': 92},
      {'month': 'Nov', 'percentage': 88},
      {'month': 'Dec', 'percentage': 96},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Attendance Charts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.teal),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAttendanceSummary(),
            const SizedBox(height: 24),
        
            _buildPeriodSelector(),
            const SizedBox(height: 24),
          
            _buildTabNavigation(),
            const SizedBox(height: 16),
         
            _selectedTab == 0 ? _buildBarChartTab() : _buildPieChartTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[700]!, Colors.teal[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
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
              'Current Month Attendance',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '92%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Days Present', '20', Colors.white),
                _buildSummaryItem('Days Late', '2', Colors.white70),
                _buildSummaryItem('Days Absent', '1', Colors.white70),
              ],
            ),
            const SizedBox(height: 16),
          
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: FractionallySizedBox(
                    widthFactor: 0.92,
                    alignment: Alignment.centerLeft,
                    child: Container(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'View by',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: ['Month', 'Quarter', 'Year'].map((period) {
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal[100] : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.teal[800] : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
                    color: _selectedTab == 0
                        ? Colors.teal[50]
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 0
                            ? Colors.teal
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    'Bar Chart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 0 ? Colors.teal : Colors.grey[600],
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
                    color: _selectedTab == 1
                        ? Colors.teal[50]
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTab == 1
                            ? Colors.teal
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    'Overview',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 1 ? Colors.teal : Colors.grey[600],
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

  Widget _buildBarChartTab() {
    final data = attendanceData[_selectedPeriod] ?? [];
    final maxHeight = 200.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Percentage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: maxHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: data.map((item) {
                      final percentage = (item['percentage'] as int).toDouble();
                      final label = _selectedPeriod == 'Month'
                          ? item['day']
                          : item['month'];

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: double.infinity,
                              height: (percentage / 100) * maxHeight,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal[700]!,
                                    Colors.teal[400]!,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${percentage.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                             Text(
                              label ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              
                Container(height: 1, color: Colors.grey[300]),
              ],
            ),
          ),
          const SizedBox(height: 24),
        
          _buildStatisticsCards(data),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(List<dynamic> data) {
    double avgPercentage = 0;
    int totalDays = 0;
    int totalPresent = 0;

    for (var item in data) {
      final percentage = item['percentage'] as int;
      if (percentage > 0) totalPresent++;
      totalDays++;
      avgPercentage += percentage;
    }
    avgPercentage = avgPercentage / totalDays;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average',
            '${avgPercentage.toStringAsFixed(1)}%',
            Colors.blue,
            '📊',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Present Days',
            '$totalPresent',
            Colors.green,
            '✓',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Absent Days',
            '${totalDays - totalPresent}',
            Colors.red,
            '✗',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, String icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
              
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: PieChartPainter(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '92%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Overall',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Legend
                Column(
                  children: [
                    _buildLegendItem('Present (92%)', Colors.teal),
                    const SizedBox(height: 12),
                    _buildLegendItem('Late (5%)', Colors.orange),
                    const SizedBox(height: 12),
                    _buildLegendItem('Absent (3%)', Colors.red),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Summary Cards
          Row(
            children: [
              Expanded(child: _buildStatusCard('Present', 20, Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatusCard('Late', 1, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatusCard('Absent', 1, Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      5.29,
      true,
      Paint()
        ..color = Colors.teal
        ..style = PaintingStyle.fill,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.72,
      0.31,
      true,
      Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      4.03,
      0.19,
      true,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => false;
}
