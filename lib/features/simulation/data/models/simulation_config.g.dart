// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimulationConfig _$SimulationConfigFromJson(Map<String, dynamic> json) =>
    SimulationConfig(
      durationHours: (json['durationHours'] as num).toInt(),
      speedFactor: (json['speedFactor'] as num).toInt(),
      totalDrivers: (json['totalDrivers'] as num).toInt(),
      zoneCount: (json['zoneCount'] as num).toInt(),
      startTime: json['startTime'] as String?,
    );

Map<String, dynamic> _$SimulationConfigToJson(SimulationConfig instance) =>
    <String, dynamic>{
      'durationHours': instance.durationHours,
      'speedFactor': instance.speedFactor,
      'totalDrivers': instance.totalDrivers,
      'zoneCount': instance.zoneCount,
      'startTime': instance.startTime,
    };
