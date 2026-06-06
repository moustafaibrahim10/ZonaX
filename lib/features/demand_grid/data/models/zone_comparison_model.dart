import 'package:json_annotation/json_annotation.dart';

part 'zone_comparison_model.g.dart';

@JsonSerializable()
class ZoneComparisonModel {
  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  @JsonKey(name: 'expectedRevenue6H')
  final double expectedRevenue6H;

  @JsonKey(name: 'stockoutProbability')
  final double stockoutProbability;

  ZoneComparisonModel({
    required this.totalRevenue,
    required this.expectedRevenue6H,
    required this.stockoutProbability,
  });

  factory ZoneComparisonModel.fromJson(Map<String, dynamic> json) => _$ZoneComparisonModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneComparisonModelToJson(this);
}
