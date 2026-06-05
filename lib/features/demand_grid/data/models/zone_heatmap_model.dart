import 'package:json_annotation/json_annotation.dart';

part 'zone_heatmap_model.g.dart';

@JsonSerializable()
class ZoneHeatmapModel {
  final int zoneId;
  final String zoneName;
  final double centerLatitude;
  final double centerLongitude;
  final int predictedTripCount;
  final double predictedStockoutProbability;
  final double demandPrediction;
  final double revenuePrediction;
  final double surgeMultiplier;
  final String demandLevel;

  ZoneHeatmapModel({
    required this.zoneId,
    required this.zoneName,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.predictedTripCount,
    required this.predictedStockoutProbability,
    required this.demandPrediction,
    required this.revenuePrediction,
    required this.surgeMultiplier,
    required this.demandLevel,
  });

  factory ZoneHeatmapModel.fromJson(Map<String, dynamic> json) => _$ZoneHeatmapModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneHeatmapModelToJson(this);
}
