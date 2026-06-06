import 'package:json_annotation/json_annotation.dart';

part 'zone_insights_model.g.dart';

@JsonSerializable()
class ZoneInsightsModel {
  @JsonKey(name: 'avgWaitTimeMinutes')
  final int avgWaitTimeMinutes;

  @JsonKey(name: 'peakPeriodName')
  final String peakPeriodName;

  @JsonKey(name: 'driverEfficiencyScore')
  final double driverEfficiencyScore;

  ZoneInsightsModel({
    required this.avgWaitTimeMinutes,
    required this.peakPeriodName,
    required this.driverEfficiencyScore,
  });

  factory ZoneInsightsModel.fromJson(Map<String, dynamic> json) => _$ZoneInsightsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneInsightsModelToJson(this);
}
