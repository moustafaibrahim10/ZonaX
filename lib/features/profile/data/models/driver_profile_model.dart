import '../../domain/entities/driver_profile_entity.dart';

class DriverProfileModel extends DriverProfileEntity {
  const DriverProfileModel({
    required super.driverId,
    required super.fullName,
    required super.plateNumber,
    required super.licenseNumber,
    required super.rating,
    required super.status,
    required super.completedTrips,
    required super.totalEarnings,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      driverId: json['driverId'] ?? '',
      fullName: json['fullName'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      completedTrips: json['completedTrips'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
    );
  }
}
