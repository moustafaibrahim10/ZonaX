import 'package:equatable/equatable.dart';

class DriverProfileEntity extends Equatable {
  final String driverId;
  final String fullName;
  final String plateNumber;
  final String licenseNumber;
  final double rating;
  final String status;
  final String? phoneNumber;
  final String? email;
  final int completedTrips;
  final int activeTrips;
  final double totalEarnings;
  final String? lastTripEndedAt;

  const DriverProfileEntity({
    required this.driverId,
    required this.fullName,
    required this.plateNumber,
    required this.licenseNumber,
    required this.rating,
    required this.status,
    this.phoneNumber,
    this.email,
    required this.completedTrips,
    required this.activeTrips,
    required this.totalEarnings,
    this.lastTripEndedAt,
  });

  @override
  List<Object?> get props => [
        driverId,
        fullName,
        plateNumber,
        licenseNumber,
        rating,
        status,
        phoneNumber,
        email,
        completedTrips,
        activeTrips,
        totalEarnings,
        lastTripEndedAt,
      ];
}
