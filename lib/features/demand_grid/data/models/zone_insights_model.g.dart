// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_insights_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneInsightsModel _$ZoneInsightsModelFromJson(Map<String, dynamic> json) =>
    ZoneInsightsModel(
      avgWaitTimeMinutes: (json['avgWaitTimeMinutes'] as num).toInt(),
      peakPeriodName: json['peakPeriodName'] as String,
      driverEfficiencyScore: (json['driverEfficiencyScore'] as num).toDouble(),
    );

Map<String, dynamic> _$ZoneInsightsModelToJson(ZoneInsightsModel instance) =>
    <String, dynamic>{
      'avgWaitTimeMinutes': instance.avgWaitTimeMinutes,
      'peakPeriodName': instance.peakPeriodName,
      'driverEfficiencyScore': instance.driverEfficiencyScore,
    };
