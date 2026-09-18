import 'dart:convert';

enum ApplicationStatus { pending, approved, rejected }

class DriverApplication {
  String id;
  String fullName;
  String email;
  String phoneNumber;
  String licenseNumber;
  String vehicleMakeModel;
  String? licenseFileName;
  int? licenseFileSize;
  bool isPhoneVerified;
  ApplicationStatus status;
  DateTime? submittedAt;

  DriverApplication({
    String? id,
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.licenseNumber = '',
    this.vehicleMakeModel = '',
    this.licenseFileName,
    this.licenseFileSize,
    this.isPhoneVerified = false,
    this.status = ApplicationStatus.pending,
    this.submittedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  bool get hasLicenseDocument => licenseFileName != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'vehicleMakeModel': vehicleMakeModel,
      'licenseFileName': licenseFileName,
      'licenseFileSize': licenseFileSize,
      'isPhoneVerified': isPhoneVerified,
      'status': status.name,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  factory DriverApplication.fromJson(Map<String, dynamic> json) {
    return DriverApplication(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      vehicleMakeModel: json['vehicleMakeModel'] ?? '',
      licenseFileName: json['licenseFileName'],
      licenseFileSize: json['licenseFileSize'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
    );
  }
}