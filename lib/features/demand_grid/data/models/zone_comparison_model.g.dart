// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_comparison_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneComparisonModel _$ZoneComparisonModelFromJson(Map<String, dynamic> json) =>
    ZoneComparisonModel(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      expectedRevenue6H: (json['expectedRevenue6H'] as num).toDouble(),
      stockoutProbability: (json['stockoutProbability'] as num).toDouble(),
    );

Map<String, dynamic> _$ZoneComparisonModelToJson(
  ZoneComparisonModel instance,
) => <String, dynamic>{
  'totalRevenue': instance.totalRevenue,
  'expectedRevenue6H': instance.expectedRevenue6H,
  'stockoutProbability': instance.stockoutProbability,
};
