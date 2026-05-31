import 'package:equatable/equatable.dart';

class DriverLocationEntity extends Equatable {
  final double lat;
  final double lng;
  final DateTime timestamp;
  final bool isOffline;

  const DriverLocationEntity({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [lat, lng, timestamp, isOffline];
}
