import 'package:json_annotation/json_annotation.dart';

part 'zone_insights_model.g.dart';

@JsonSerializable()
class ZoneInsightsModel {
  @JsonKey(name: 'zoneId')
  final int zoneId;

  @JsonKey(name: 'aiInsightText')
  final String? aiInsightText;

  @JsonKey(name: 'demandGrowthPercentage')
  final double? demandGrowthPercentage;

  @JsonKey(name: 'recommendedAction')
  final String? recommendedAction;

  ZoneInsightsModel({
    required this.zoneId,
    this.aiInsightText,
    this.demandGrowthPercentage,
    this.recommendedAction,
  });

  factory ZoneInsightsModel.fromJson(Map<String, dynamic> json) => _$ZoneInsightsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneInsightsModelToJson(this);
}
