import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PayslipDetailsScreen extends StatefulWidget {
  final String month;
  final String amount;

  const PayslipDetailsScreen({
    super.key,
    required this.month,
    required this.amount,
  });

  @override
  State<PayslipDetailsScreen> createState() => _PayslipDetailsScreenState();
}

class _PayslipDetailsScreenState extends State<PayslipDetailsScreen> {
  String userName = "Loading...";
  String userId = "ID-xxxx";
  String userRole = "Employee";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      setState(() {
        userName = "${user['firstName']} ${user['lastName']}".trim();
        userId = user['id'] != null ? user['id'].toString().toUpperCase() : "EMP-001";
        if (user['roles'] != null && user['roles'].isNotEmpty) {
          userRole = user['roles'][0]['name'] ?? "Employee";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payslip",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              widget.month,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tax code", style: TextStyle(color: Colors.grey)),
                Text("RID215225578912", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Card Number", style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    const Text("**** **** **** ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    Icon(Icons.credit_card, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              "${widget.month} Pay Slip",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF36617E)),
            ),
            const SizedBox(height: 20),

            // Bill to details
            const Text(
              "Bill to :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            
            _buildDetailRow("ID", userId),
            const SizedBox(height: 10),
            _buildDetailRow("Name", userName),
            const SizedBox(height: 10),
            _buildDetailRow("Role", userRole),

            const SizedBox(height: 30),
            _buildDottedDivider(),
            const SizedBox(height: 30),

            // Description
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

            _buildAmountRow("Gross pay", "₹90,000.00"),
            const SizedBox(height: 15),
            _buildAmountRow("5 Deductions", "- ₹10,200.00", isDeduction: true),
            const SizedBox(height: 15),
            _buildAmountRow("Overtime (120 m)", "+ ₹2,700.00"),
            
            const SizedBox(height: 20),
            _buildDottedDivider(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Net pay",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  widget.amount,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF36617E)),
                ),
              ],
            ),

            const Spacer(),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF36617E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Share", style: TextStyle(color: Color(0xFF36617E))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF36617E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Download", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAmountRow(String label, String amount, {bool isDeduction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDeduction ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDottedDivider() {
    return Row(
      children: List.generate(150 ~/ 2, (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? Colors.transparent : Colors.grey[300],
          height: 1,
        ),
      )),
    );
  }
}
