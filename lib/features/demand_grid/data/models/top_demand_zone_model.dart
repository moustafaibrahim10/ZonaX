import 'package:json_annotation/json_annotation.dart';

part 'top_demand_zone_model.g.dart';

@JsonSerializable()
class TopDemandZoneModel {
  final int zoneId;
  final String zoneName;
  final double centerLatitude;
  final double centerLongitude;
  final int demandPrediction;
  final double percentageOfTotalPredicted;

  TopDemandZoneModel({
    required this.zoneId,
    required this.zoneName,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.demandPrediction,
    required this.percentageOfTotalPredicted,
  });

  factory TopDemandZoneModel.fromJson(Map<String, dynamic> json) =>
      _$TopDemandZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$TopDemandZoneModelToJson(this);
}
