import 'package:equatable/equatable.dart';

class DriverProfileEntity extends Equatable {
  final String driverId;
  final String fullName;
  final String plateNumber;
  final String licenseNumber;
  final double rating;
  final String status;
  final int completedTrips;
  final double totalEarnings;

  const DriverProfileEntity({
    required this.driverId,
    required this.fullName,
    required this.plateNumber,
    required this.licenseNumber,
    required this.rating,
    required this.status,
    required this.completedTrips,
    required this.totalEarnings,
  });

  @override
  List<Object?> get props => [
        driverId,
        fullName,
        plateNumber,
        licenseNumber,
        rating,
        status,
        completedTrips,
        totalEarnings,
      ];
}
