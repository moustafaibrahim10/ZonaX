import 'package:zona_x_16_4/features/simulation/data/models/simulation_zone.dart';

class SimulationStatus {
  final String status; // e.g., 'Running' or '1'
  final String currentTime;
  final double speedFactor;
  final List<SimulationZone> zones;

  SimulationStatus({
    required this.status,
    required this.currentTime,
    required this.speedFactor,
    this.zones = const [],
  });

  factory SimulationStatus.fromJson(Map<String, dynamic> json) {
    return SimulationStatus(
      status: json['status']?.toString() ?? 'Stopped',
      currentTime: json['currentTime']?.toString() ?? json['simulatedTime']?.toString() ?? '',
      speedFactor: (json['speedFactor'] as num?)?.toDouble() ?? 1.0,
      zones: (json['zones'] as List<dynamic>?)
              ?.map((e) => SimulationZone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  SimulationStatus copyWith({
    String? status,
    String? currentTime,
    double? speedFactor,
    List<SimulationZone>? zones,
  }) {
    return SimulationStatus(
      status: status ?? this.status,
      currentTime: currentTime ?? this.currentTime,
      speedFactor: speedFactor ?? this.speedFactor,
      zones: zones ?? this.zones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'currentTime': currentTime,
      'speedFactor': speedFactor,
      'zones': zones.map((e) => e.toJson()).toList(),
    };
  }
}
