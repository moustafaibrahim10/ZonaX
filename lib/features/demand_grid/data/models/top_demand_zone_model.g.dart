// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_demand_zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopDemandZoneModel _$TopDemandZoneModelFromJson(Map<String, dynamic> json) =>
    TopDemandZoneModel(
      zoneId: (json['zoneId'] as num).toInt(),
      zoneName: json['zoneName'] as String,
      centerLatitude: (json['centerLatitude'] as num).toDouble(),
      centerLongitude: (json['centerLongitude'] as num).toDouble(),
      demandPrediction: (json['demandPrediction'] as num).toInt(),
      percentageOfTotalPredicted: (json['percentageOfTotalPredicted'] as num)
          .toDouble(),
    );

Map<String, dynamic> _$TopDemandZoneModelToJson(TopDemandZoneModel instance) =>
    <String, dynamic>{
      'zoneId': instance.zoneId,
      'zoneName': instance.zoneName,
      'centerLatitude': instance.centerLatitude,
      'centerLongitude': instance.centerLongitude,
      'demandPrediction': instance.demandPrediction,
      'percentageOfTotalPredicted': instance.percentageOfTotalPredicted,
    };
