// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_insights_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneInsightsModel _$ZoneInsightsModelFromJson(Map<String, dynamic> json) =>
    ZoneInsightsModel(
      zoneId: (json['zoneId'] as num).toInt(),
      aiInsightText: json['aiInsightText'] as String?,
      demandGrowthPercentage: (json['demandGrowthPercentage'] as num?)
          ?.toDouble(),
      recommendedAction: json['recommendedAction'] as String?,
    );

Map<String, dynamic> _$ZoneInsightsModelToJson(ZoneInsightsModel instance) =>
    <String, dynamic>{
      'zoneId': instance.zoneId,
      'aiInsightText': instance.aiInsightText,
      'demandGrowthPercentage': instance.demandGrowthPercentage,
      'recommendedAction': instance.recommendedAction,
    };
