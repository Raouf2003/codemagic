class Employee {
  final String id;
  final String employeeNumber;
  final String fullName;
  final String role;
  final bool isActive;
  final bool fingerprintRegistered;
  final bool faceEnrolled;

  Employee({
    required this.id,
    required this.employeeNumber,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.fingerprintRegistered = false,
    this.faceEnrolled = false,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? json['_id'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'employee',
      isActive: json['isActive'] ?? true,
      fingerprintRegistered: json['fingerprintRegistered'] ?? false,
      faceEnrolled: json['faceEnrolled'] ?? false,
    );
  }
}
