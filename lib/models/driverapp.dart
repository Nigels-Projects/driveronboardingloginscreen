import 'dart:convert';

class DriverApplication {
  String fullName;
  String email;
  String phoneNumber;
  String licenseNumber;
  String vehicleMakeModel;
  String? licenseFileName;
  int? licenseFileSize;

  // Unnamed constructor with default values
  DriverApplication({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.licenseNumber = '',
    this.vehicleMakeModel = '',
    this.licenseFileName,
    this.licenseFileSize,
  });

  bool get hasLicenseDocument => licenseFileName != null;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'vehicleMakeModel': vehicleMakeModel,
      'licenseFileName': licenseFileName,
      'licenseFileSize': licenseFileSize,
    };
  }

  factory DriverApplication.fromJson(Map<String, dynamic> json) {
    return DriverApplication(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      vehicleMakeModel: json['vehicleMakeModel'] ?? '',
      licenseFileName: json['licenseFileName'],
      licenseFileSize: json['licenseFileSize'],
    );
  }
}