// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_distribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverDistributionModel _$DriverDistributionModelFromJson(
  Map<String, dynamic> json,
) => DriverDistributionModel(
  zoneId: (json['zoneId'] as num).toInt(),
  activeDriversCount: (json['activeDriversCount'] as num).toInt(),
  availableDriversCount: (json['availableDriversCount'] as num).toInt(),
  onTripDriversCount: (json['onTripDriversCount'] as num).toInt(),
  centerLatitude: (json['centerLatitude'] as num).toDouble(),
  centerLongitude: (json['centerLongitude'] as num).toDouble(),
  areaSizeProxy: (json['areaSizeProxy'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$DriverDistributionModelToJson(
  DriverDistributionModel instance,
) => <String, dynamic>{
  'zoneId': instance.zoneId,
  'activeDriversCount': instance.activeDriversCount,
  'availableDriversCount': instance.availableDriversCount,
  'onTripDriversCount': instance.onTripDriversCount,
  'centerLatitude': instance.centerLatitude,
  'centerLongitude': instance.centerLongitude,
  'areaSizeProxy': instance.areaSizeProxy,
};
