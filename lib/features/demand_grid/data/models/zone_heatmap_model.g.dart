// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_heatmap_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneHeatmapModel _$ZoneHeatmapModelFromJson(Map<String, dynamic> json) =>
    ZoneHeatmapModel(
      zoneId: (json['zoneId'] as num).toInt(),
      zoneName: json['zoneName'] as String,
      centerLatitude: (json['centerLatitude'] as num).toDouble(),
      centerLongitude: (json['centerLongitude'] as num).toDouble(),
      predictedTripCount: (json['predictedTripCount'] as num).toInt(),
      predictedStockoutProbability:
          (json['predictedStockoutProbability'] as num).toDouble(),
      demandPrediction: (json['demandPrediction'] as num).toDouble(),
      revenuePrediction: (json['revenuePrediction'] as num).toDouble(),
      surgeMultiplier: (json['surgeMultiplier'] as num).toDouble(),
      demandLevel: json['demandLevel'] as String,
    );

Map<String, dynamic> _$ZoneHeatmapModelToJson(ZoneHeatmapModel instance) =>
    <String, dynamic>{
      'zoneId': instance.zoneId,
      'zoneName': instance.zoneName,
      'centerLatitude': instance.centerLatitude,
      'centerLongitude': instance.centerLongitude,
      'predictedTripCount': instance.predictedTripCount,
      'predictedStockoutProbability': instance.predictedStockoutProbability,
      'demandPrediction': instance.demandPrediction,
      'revenuePrediction': instance.revenuePrediction,
      'surgeMultiplier': instance.surgeMultiplier,
      'demandLevel': instance.demandLevel,
    };
