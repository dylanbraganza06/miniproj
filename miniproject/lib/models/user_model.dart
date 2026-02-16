class UserModel {
  final String id;
  final String email;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const UserModel({
    required this.id,
    required this.email,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }
}
