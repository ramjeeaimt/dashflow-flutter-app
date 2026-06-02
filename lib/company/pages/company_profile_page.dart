import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:dashflow/company/widgets/notif_badge.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  bool _isLoading = true;
  bool _isEditing = false;
  String? _companyId;

  Map<String, dynamic> _profileData = {};
  Map<String, dynamic> _gstData = {};

  // Controllers for general info
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _logoController = TextEditingController();

  // Controllers for GST & Bank
  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _branchNameController = TextEditingController();

  String _activeTab = 'General'; // General, GST & Bank

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _logoController.dispose();

    _gstNumberController.dispose();
    _panNumberController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        _companyId = user['company']?['id']?.toString();
      }

      if (_companyId != null) {
        final profile = await ApiService.getCompanyProfile(_companyId!);
        Map<String, dynamic> gst = {};
        try {
          gst = await ApiService.getCompanyGstDocs(_companyId!);
        } catch (e) {
          gst = {};
        }

        if (mounted) {
          setState(() {
            _profileData = profile;
            _gstData = gst;

            _nameController.text = _profileData['name']?.toString() ?? '';
            _websiteController.text = _profileData['website']?.toString() ?? '';
            _industryController.text = _profileData['industry']?.toString() ?? '';
            _emailController.text = _profileData['email']?.toString() ?? '';
            _phoneController.text = _profileData['phone']?.toString() ?? '';
            _addressController.text = _profileData['address']?.toString() ?? '';
            _cityController.text = _profileData['city']?.toString() ?? '';
            _postalCodeController.text = _profileData['postalCode']?.toString() ?? '';
            _countryController.text = _profileData['country']?.toString() ?? '';
            _logoController.text = _profileData['logo']?.toString() ?? '';

            _gstNumberController.text = _gstData['gstNumber']?.toString() ?? '';
            _panNumberController.text = _gstData['panNumber']?.toString() ?? '';
            _bankNameController.text = _gstData['bankName']?.toString() ?? '';
            _accountNameController.text = _gstData['accountName']?.toString() ?? '';
            _accountNumberController.text = _gstData['accountNumber']?.toString() ?? '';
            _ifscCodeController.text = _gstData['ifscCode']?.toString() ?? '';
            _branchNameController.text = _gstData['branchName']?.toString() ?? '';

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
          SnackBar(content: Text('Failed to load company profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_companyId == null) return;
    setState(() => _isLoading = true);

    try {
      final profilePayload = {
        'name': _nameController.text.trim(),
        'website': _websiteController.text.trim(),
        'industry': _industryController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
        if (_logoController.text.isNotEmpty) 'logo': _logoController.text.trim(),
      };

      final gstPayload = {
        'gstNumber': _gstNumberController.text.trim(),
        'panNumber': _panNumberController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'accountName': _accountNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'ifscCode': _ifscCodeController.text.trim(),
        'branchName': _branchNameController.text.trim(),
      };

      await ApiService.updateCompanyProfile(_companyId!, profilePayload);
      await ApiService.updateCompanyGstDocs(_companyId!, gstPayload);

      await _loadData();
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company profile updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = _profileData['name']?.toString() ?? 'Company Details';
    final companyIndustry = _profileData['industry']?.toString() ?? 'Industry not set';
    final companyLogo = _profileData['logo']?.toString() ?? '';

    return Scaffold(
      backgroundColor: kBg,
      appBar: crmAppBar(
        context,
        _isEditing ? 'Edit Profile' : 'Company Profile',
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: kPrimary),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _loadData(); // Revert edits
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: _saveChanges,
                ),
              ],
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Banner and Logo Row
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 140,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kPrimary, Color(0xFF5582A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -35,
                        left: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: companyLogo.isNotEmpty
                                ? Image.network(
                                    companyLogo,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderLogo(),
                                  )
                                : _buildPlaceholderLogo(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 45),

                  // Title Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyIndustry,
                            style: const TextStyle(
                              fontSize: 14,
                              color: kSubText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Selectors
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: ['General', 'GST & Bank'].map((t) {
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
                                    fontSize: 13,
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
                  ),
                  const SizedBox(height: 16),

                  // Tab Contents
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _activeTab == 'General'
                        ? _buildGeneralTab()
                        : _buildGstBankTab(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildPlaceholderLogo() {
    return Container(
      width: 80,
      height: 80,
      color: kPrimaryLight,
      child: const Icon(
        Icons.business,
        size: 40,
        color: kPrimary,
      ),
    );
  }

  Widget _buildGeneralTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildField('Company Name', _nameController, Icons.business, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Industry', _industryController, Icons.category_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Website', _websiteController, Icons.language_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Email', _emailController, Icons.email_outlined, enabled: _isEditing, keyboardType: TextInputType.emailAddress),
          const Divider(height: 24),
          _buildField('Phone', _phoneController, Icons.phone_outlined, enabled: _isEditing, keyboardType: TextInputType.phone),
          const Divider(height: 24),
          _buildField('Address', _addressController, Icons.location_on_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('City', _cityController, Icons.location_city_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Postal Code', _postalCodeController, Icons.pin_drop_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Country', _countryController, Icons.public_outlined, enabled: _isEditing),
          if (_isEditing) ...[
            const Divider(height: 24),
            _buildField('Logo Image URL', _logoController, Icons.image_outlined, enabled: true),
          ],
        ],
      ),
    );
  }

  Widget _buildGstBankTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taxation Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kPrimary),
          ),
          const SizedBox(height: 16),
          _buildField('GSTIN', _gstNumberController, Icons.receipt_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('PAN Number', _panNumberController, Icons.credit_card_outlined, enabled: _isEditing),
          const SizedBox(height: 24),
          const Text(
            'Bank Account Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kPrimary),
          ),
          const SizedBox(height: 16),
          _buildField('Account Holder Name', _accountNameController, Icons.person_outline, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Bank Name', _bankNameController, Icons.account_balance_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Account Number', _accountNumberController, Icons.numbers_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('IFSC Code', _ifscCodeController, Icons.code_outlined, enabled: _isEditing),
          const Divider(height: 24),
          _buildField('Branch Name', _branchNameController, Icons.map_outlined, enabled: _isEditing),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    if (!enabled) {
      final text = controller.text.isNotEmpty ? controller.text : '--';
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: kSubText, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kText),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: kText, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: kSubText),
        prefixIcon: Icon(icon, color: kPrimary, size: 20),
        border: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kPrimary)),
      ),
    );
  }
}