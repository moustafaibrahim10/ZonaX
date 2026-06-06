// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendedZoneModel _$RecommendedZoneModelFromJson(
  Map<String, dynamic> json,
) => RecommendedZoneModel(
  zoneName: json['zoneName'] as String,
  recommendationScore: (json['recommendationScore'] as num).toDouble(),
  demandSupplyRatio: (json['demandSupplyRatio'] as num).toDouble(),
  predictedRevenueYield: (json['predictedRevenueYield'] as num).toDouble(),
  reason: json['reason'] as String,
  avgFare: (json['avgFare'] as num).toDouble(),
  centerLatitude: (json['centerLatitude'] as num).toDouble(),
  centerLongitude: (json['centerLongitude'] as num).toDouble(),
);

Map<String, dynamic> _$RecommendedZoneModelToJson(
  RecommendedZoneModel instance,
) => <String, dynamic>{
  'zoneName': instance.zoneName,
  'recommendationScore': instance.recommendationScore,
  'demandSupplyRatio': instance.demandSupplyRatio,
  'predictedRevenueYield': instance.predictedRevenueYield,
  'reason': instance.reason,
  'avgFare': instance.avgFare,
  'centerLatitude': instance.centerLatitude,
  'centerLongitude': instance.centerLongitude,
};
