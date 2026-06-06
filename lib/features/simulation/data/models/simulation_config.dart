import 'package:json_annotation/json_annotation.dart';

part 'simulation_config.g.dart';

@JsonSerializable()
class SimulationConfig {
  final int durationHours;
  final int speedFactor;
  final int totalDrivers;
  final int zoneCount;
  final String? startTime;

  SimulationConfig({
    required this.durationHours,
    required this.speedFactor,
    required this.totalDrivers,
    required this.zoneCount,
    this.startTime,
  });

  factory SimulationConfig.fromJson(Map<String, dynamic> json) =>
      _$SimulationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SimulationConfigToJson(this);
}
