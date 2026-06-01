class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final String? companyId;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.companyId,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String parsedRole = 'employee';
    if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final firstRole = json['roles'][0];
      if (firstRole is Map) {
        parsedRole = firstRole['name']?.toString().toLowerCase() ?? 'employee';
      } else {
        parsedRole = firstRole.toString().toLowerCase();
      }
    } else if (json['role'] != null) {
      if (json['role'] is Map) {
        parsedRole = json['role']['name']?.toString().toLowerCase() ?? 'employee';
      } else {
        parsedRole = json['role'].toString().toLowerCase();
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      role: parsedRole,
      companyId: json['companyId']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    final data = {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
    };
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    if (companyId != null && companyId!.isNotEmpty) {
      data['companyId'] = companyId as String;
    }
    return data;
  }
}
