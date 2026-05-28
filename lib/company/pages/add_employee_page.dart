import 'package:flutter/material.dart';

class AddEmployeePageEnhanced extends StatefulWidget {
  const AddEmployeePageEnhanced({Key? key}) : super(key: key);

  @override
  State<AddEmployeePageEnhanced> createState() =>
      _AddEmployeePageEnhancedState();
}

class _AddEmployeePageEnhancedState extends State<AddEmployeePageEnhanced> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _departments = [
    'IT',
    'HR',
    'Finance',
    'Sales',
    'Marketing',
    'Operations',
    'Customer Support',
    'Management',
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _joiningDateController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _joiningDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDepartment != null) {
      setState(() => _isLoading = true);

      try {
        await Future.delayed(const Duration(seconds: 2));

        final employeeData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'position': _positionController.text,
          'department': _selectedDepartment,
          'gender': _selectedGender,
          'salary': '₹${_salaryController.text}',
          'joining_date': _joiningDateController.text,
          'address': _addressController.text,
          'qualification': _qualificationController.text,
        };

        if (mounted) {
          _showSuccessDialog(employeeData);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया विभाग चुनें'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessDialog(Map<String, dynamic> employeeData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'कर्मचारी सफलतापूर्वक जोड़ा गया!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${employeeData['name']} को सूची में जोड़ा जा रहा है...',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, employeeData);
            },
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('नया कर्मचारी जोड़ें'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'फॉर्म पूरा करें',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Personal Information
                _buildSectionHeader('व्यक्तिगत जानकारी', Icons.person),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _nameController,
                  label: 'पूरा नाम',
                  hint: 'कर्मचारी का नाम दर्ज करें',
                  icon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'कृपया कर्मचारी का नाम दर्ज करें';
                    }
                    if (value!.length < 3) {
                      return 'नाम कम से कम 3 अक्षर का होना चाहिए';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _emailController,
                  label: 'ईमेल पता',
                  hint: 'example@company.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'कृपया ईमेल पता दर्ज करें';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                      return 'कृपया सही ईमेल पता दर्ज करें';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _phoneController,
                  label: 'फोन नंबर',
                  hint: '+91 XXXXX XXXXX',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'कृपया फोन नंबर दर्ज करें';
                    }
                    if (value!.length < 10) {
                      return 'फोन नंबर कम से कम 10 अंकों का होना चाहिए';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                _buildGenderSelector(),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _addressController,
                  label: 'पता',
                  hint: 'अपना पता दर्ज करें',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'कृपया पता दर्ज करें';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Section 2: Job Information
                _buildSectionHeader('कार्य जानकारी', Icons.work),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _positionController,
                  label: 'पद',
                  hint: 'जैसे, सॉफ्टवेयर इंजीनियर',
                  icon: Icons.work,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'कृपया पद दर्ज करें';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department Dropdown
                _buildDepartmentDropdown(),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _qualificationController,
                  label: 'योग्यता',
                  hint: 'जैसे, B.Tech, MBA',
                  icon: Icons.school,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'कृपया योग्यता दर्ज करें';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _salaryController,
                  label: 'वार्षिक वेतन',
                  hint: 'वेतन राशि दर्ज करें',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'कृपया वेतन दर्ज करें';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'कृपया सही संख्या दर्ज करें';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                _buildDatePicker(),
                const SizedBox(height: 32),

                // Buttons
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'कर्मचारी जोड़ें',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.blue.shade700),
                  ),
                  child: Text(
                    'फॉर्म साफ़ करें',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const Expanded(child: Divider(indent: 16)),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        decoration: InputDecoration(
          labelText: 'विभाग',
          prefixIcon: Icon(Icons.business, color: Colors.blue.shade700),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: _departments.map((String department) {
          return DropdownMenuItem<String>(
            value: department,
            child: Text(department),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() => _selectedDepartment = newValue);
        },
        validator: (value) {
          if (value == null) {
            return 'कृपया विभाग चुनें';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'लिंग',
          prefixIcon: Icon(Icons.person_outline, color: Colors.blue.shade700),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: _genders.map((String gender) {
          return DropdownMenuItem<String>(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() => _selectedGender = newValue);
        },
        validator: (value) {
          if (value == null) {
            return 'कृपया लिंग चुनें';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextFormField(
            controller: _joiningDateController,
            decoration: InputDecoration(
              labelText: 'शामिल होने की तारीख',
              hintText: 'तारीख चुनें',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: Colors.blue.shade700,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'कृपया शामिल होने की तारीख चुनें';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _positionController.clear();
    _salaryController.clear();
    _joiningDateController.clear();
    _addressController.clear();
    _qualificationController.clear();
    setState(() {
      _selectedDepartment = null;
      _selectedGender = null;
      _selectedDate = null;
      _currentStep = 0;
    });
  }
}
