import 'package:json_annotation/json_annotation.dart';

part 'recommended_zone_model.g.dart';

@JsonSerializable()
class RecommendedZoneModel {
  @JsonKey(name: 'zoneName')
  final String zoneName;

  @JsonKey(name: 'recommendationScore')
  final double recommendationScore;

  @JsonKey(name: 'demandSupplyRatio')
  final double demandSupplyRatio;

  @JsonKey(name: 'predictedRevenueYield')
  final double predictedRevenueYield;

  @JsonKey(name: 'reason')
  final String reason;

  @JsonKey(name: 'avgFare')
  final double avgFare;

  @JsonKey(name: 'centerLatitude')
  final double centerLatitude;

  @JsonKey(name: 'centerLongitude')
  final double centerLongitude;

  RecommendedZoneModel({
    required this.zoneName,
    required this.recommendationScore,
    required this.demandSupplyRatio,
    required this.predictedRevenueYield,
    required this.reason,
    required this.avgFare,
    required this.centerLatitude,
    required this.centerLongitude,
  });

  factory RecommendedZoneModel.fromJson(Map<String, dynamic> json) => _$RecommendedZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedZoneModelToJson(this);
}
